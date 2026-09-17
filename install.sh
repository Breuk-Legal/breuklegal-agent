#!/usr/bin/env bash
set -euo pipefail

# Breuk Agent installer.
#
# Downloads the published desktop application, verifies it against the checksum
# the delivery publishes beside it, places it in the user's home and registers
# it with the desktop so it shows up in the applications menu.
#
# No administrator privileges are needed and nothing is written outside $HOME.

APP=breuk-agent
REPO=Breuk-Legal/breuklegal-agent
IMAGE=Breuk-Agent.AppImage

# The name never carries a version, on purpose: the application replaces this
# file in place when it updates itself, and the launcher, the menu entry and the
# icon all keep pointing at the same path.
INSTALL_DIR=$HOME/.local/bin
DESKTOP_DIR=$HOME/.local/share/applications
ICON_ROOT=$HOME/.local/share/icons/hicolor
TARGET="$INSTALL_DIR/$IMAGE"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[38;2;255;140;0m'
NC='\033[0m'

print_message() {
    local level=$1
    local message=$2
    local color=""
    case $level in
        info) color="${GREEN}" ;;
        warning) color="${YELLOW}" ;;
        error) color="${RED}" ;;
    esac
    echo -e "${color}${message}${NC}"
}

requested_version=${VERSION:-}

os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)

# Only Linux x86_64 is published today. Anything else is refused here, by name,
# rather than left to die as a 404 that explains nothing.
case "$os" in
    linux)
        if [[ "$arch" != "x86_64" ]]; then
            print_message error "Breuk Agent is not published for Linux $arch yet."
            print_message info "Only Linux x86_64 is available today. Write to us at breuklegal.com if you need $arch — knowing how many people ask is what moves the date."
            exit 1
        fi
    ;;
    darwin)
        print_message error "Breuk Agent is not published for macOS yet."
        print_message info "It is coming. Write to us at breuklegal.com if you need it — knowing how many people ask is what moves the date."
        exit 1
    ;;
    mingw*|msys*|cygwin*)
        print_message error "Breuk Agent is not published for Windows yet."
        print_message info "It is coming. Write to us at breuklegal.com if you need it."
        exit 1
    ;;
    *)
        print_message error "Unsupported system: $os/$arch"
        exit 1
    ;;
esac

# The delivery ships its own runtime, so there is no system webview or toolkit
# to check for. It does need FUSE to mount itself; without it the file downloads
# fine and then refuses to start, which is the failure worth catching early.
if [[ ! -e /dev/fuse ]]; then
    print_message warning "FUSE does not appear to be available on this system."
    print_message info "If Breuk Agent does not start, install it with your package manager:"
    print_message info "  Debian/Ubuntu:  sudo apt install libfuse2"
    print_message info "  Fedora:         sudo dnf install fuse-libs"
    print_message info "  Arch:           sudo pacman -S fuse2"
fi

# Verification is not optional: this downloads an executable from the internet.
if ! command -v openssl >/dev/null 2>&1; then
    print_message error "openssl is required to verify the download and was not found."
    print_message info "Install it with your package manager and run this again."
    exit 1
fi

if [ -z "$requested_version" ]; then
    # Deliveries are published as prereleases, so /releases/latest does not see
    # them. The full listing comes back newest first; the first entry whose tag
    # is a version is the one to install. The filter matters: the rolling
    # development copy lives under a tag that is not a version, and it is the
    # newest thing in the repository right after every publication.
    specific_version=$(curl -fsSL "https://api.github.com/repos/$REPO/releases?per_page=20" \
        | awk -F'"' '/"tag_name": "v[0-9]/ {gsub(/^v/, "", $4); print $4; exit}')

    if [[ -z "$specific_version" ]]; then
        print_message error "No published version was found."
        print_message info "See https://github.com/$REPO/releases — if it is empty, the first delivery has not been published yet."
        exit 1
    fi
else
    specific_version=$requested_version
fi

base="https://github.com/$REPO/releases/download/v${specific_version}"

if [[ -x "$TARGET" ]]; then
    # The version is read out of the installed file itself, which takes a few
    # milliseconds and stays true after the application updates itself. It is
    # NOT obtained by running it: a packaged Electron application does not
    # answer --version, it opens a window — so asking would launch the product
    # in the middle of an install and wait for someone to close it.
    probe=$(mktemp -d)
    installed_version=$( (cd "$probe" && "$TARGET" --appimage-extract '*.desktop' >/dev/null 2>&1 \
        && awk -F= '/^X-AppImage-Version=/ {print $2; exit}' "$probe"/squashfs-root/*.desktop) 2>/dev/null || true)
    rm -rf "$probe"
    if [[ -n "$installed_version" && "$installed_version" == "$specific_version" ]]; then
        print_message info "Version ${YELLOW}$specific_version${GREEN} is already installed"
        exit 0
    elif [[ -n "$installed_version" ]]; then
        print_message info "Installed version: ${YELLOW}$installed_version${GREEN}"
    fi
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

print_message info "Downloading ${ORANGE}Breuk Agent ${GREEN}version ${YELLOW}$specific_version${GREEN} ..."
curl -# -fL -o "$tmpdir/$IMAGE" "$base/$IMAGE"

# The checksum travels in the update metadata the delivery publishes beside the
# image — the same file the installed application reads to find newer versions,
# so there is one published statement of what this release contains rather than
# two that can disagree. It holds a base64 SHA-512.
if ! curl -fsSL -o "$tmpdir/metadata.yml" "$base/latest-linux.yml"; then
    print_message error "The delivery is missing its update metadata, so the download cannot be verified."
    exit 1
fi

expected=$(awk '/^sha512:/ {print $2; exit}' "$tmpdir/metadata.yml")
if [[ -z "$expected" ]]; then
    print_message error "No checksum was found in the delivery's update metadata."
    exit 1
fi

actual=$(openssl dgst -sha512 -binary "$tmpdir/$IMAGE" | openssl base64 -A)
if [[ "$actual" != "$expected" ]]; then
    print_message error "Checksum verification failed for $IMAGE"
    print_message error "  expected: $expected"
    print_message error "  actual:   $actual"
    exit 1
fi
print_message info "Checksum OK"

chmod +x "$tmpdir/$IMAGE"
mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR"
mv -f "$tmpdir/$IMAGE" "$TARGET"

# The icon is drawn inside the image. Pulling it out is what makes the menu
# entry and the taskbar button show the product rather than a blank square.
#
# Nothing here may abort the install: the application is already in place and
# usable, and a missing icon is cosmetic. The path is deliberate — at the root
# of the image the icon is a symlink into usr/share, so extracting only the
# root leaves a link pointing at nothing.
icon_line="Icon=$TARGET"
if (cd "$tmpdir" && "$TARGET" --appimage-extract 'usr/share/icons/hicolor/*/apps/*.png' >/dev/null 2>&1); then
    # -L resolves links and -type f then keeps only what really exists.
    icon=$(find -L "$tmpdir/squashfs-root/usr/share/icons/hicolor" -name '*.png' -type f -print -quit 2>/dev/null || true)
    if [[ -n "$icon" ]]; then
        # Installed under the size it actually is, which is where the desktop
        # looks for it by name.
        size=$(basename "$(dirname "$(dirname "$icon")")")
        if mkdir -p "$ICON_ROOT/$size/apps" && cp -f "$icon" "$ICON_ROOT/$size/apps/$APP.png"; then
            icon_line="Icon=$APP"
        fi
    fi
fi

# Written here rather than taken from the copy inside the image: that one
# carries an Exec that only works from inside the mounted image, and a comment
# describing the shell's internals rather than what the product is. The window
# class is copied from it, though — it has to match what the running window
# reports or the taskbar shows a second, iconless entry.
cat > "$DESKTOP_DIR/$APP.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Breuk Agent
Comment=AI legal agent by Breuk Legal
Exec=$TARGET %U
$icon_line
Terminal=false
Categories=Office;
StartupWMClass=breuk-agent
DESKTOP

# Without this the entry can take until the next login to appear in the menu.
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

print_message info "Installed ${ORANGE}Breuk Agent ${GREEN}to ${YELLOW}$TARGET${NC}"
print_message info "Open it from your applications menu, or run:"
print_message info "  $TARGET"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_message warning "$INSTALL_DIR is not on your \$PATH."
    print_message info "The applications menu entry works regardless; add it to your shell profile if you also want to start it from a terminal:"
    print_message info "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

print_message info "Breuk Agent updates itself: it checks for new versions while open and applies them when you close the window."
