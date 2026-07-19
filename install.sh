#!/usr/bin/env bash
set -euo pipefail
APP=breuk
REPO=Breuk-Legal/breuklegal-agent

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[38;2;255;140;0m'
NC='\033[0m' # No Color

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
if [[ "$os" == "darwin" ]]; then
    os="mac"
fi
arch=$(uname -m)

if [[ "$arch" == "aarch64" ]]; then
  arch="arm64"
fi

filename="$APP-$os-$arch.tar.gz"


case "$filename" in
    *"-linux-"*)
        [[ "$arch" == "x86_64" || "$arch" == "arm64" || "$arch" == "i386" ]] || exit 1
    ;;
    *"-mac-"*)
        [[ "$arch" == "x86_64" || "$arch" == "arm64" ]] || exit 1
    ;;
    *)
        print_message error "Unsupported OS/Arch: $os/$arch"
        exit 1
    ;;
esac

INSTALL_DIR=$HOME/.breuk/bin
mkdir -p "$INSTALL_DIR"

if [ -z "$requested_version" ]; then
    # /releases/latest ignora prereleases; mientras el canal sea prerelease se
    # toma la release más reciente del listado completo.
    specific_version=$(curl -fsSL "https://api.github.com/repos/$REPO/releases?per_page=1" | awk -F'"' '/"tag_name": "/ {gsub(/^v/, "", $4); print $4; exit}')

    if [[ -z "$specific_version" ]]; then
        print_message error "Failed to fetch version information"
        exit 1
    fi
else
    specific_version=$requested_version
fi

url="https://github.com/$REPO/releases/download/v${specific_version}/$filename"
checksums_url="https://github.com/$REPO/releases/download/v${specific_version}/checksums.txt"

check_version() {
    if command -v breuk >/dev/null 2>&1; then
        installed_version=$(breuk version 2>/dev/null | awk '{print $NF}' || true)

        if [[ -n "$installed_version" && "$installed_version" == "$specific_version" ]]; then
            print_message info "Version ${YELLOW}$specific_version${GREEN} already installed"
            exit 0
        elif [[ -n "$installed_version" ]]; then
            print_message info "Installed version: ${YELLOW}$installed_version."
        fi
    fi
}

download_and_install() {
    print_message info "Downloading ${ORANGE}breuk ${GREEN}version: ${YELLOW}$specific_version ${GREEN}..."
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    cd "$tmpdir"

    curl -# -fL -o "$filename" "$url"
    curl -fsSL -o checksums.txt "$checksums_url"

    expected=$(awk -v f="$filename" '$2 == f {print $1}' checksums.txt)
    if [[ -z "$expected" ]]; then
        print_message error "Checksum for $filename not found in checksums.txt"
        exit 1
    fi

    if command -v sha256sum >/dev/null 2>&1; then
        actual=$(sha256sum "$filename" | awk '{print $1}')
    else
        actual=$(shasum -a 256 "$filename" | awk '{print $1}')
    fi

    if [[ "$actual" != "$expected" ]]; then
        print_message error "Checksum verification failed for $filename"
        print_message error "  expected: $expected"
        print_message error "  actual:   $actual"
        exit 1
    fi
    print_message info "Checksum OK"

    tar xzf "$filename"
    mv breuk "$INSTALL_DIR"
    cd - >/dev/null
}

check_version
download_and_install


add_to_path() {
    local config_file=$1
    local command=$2

    if [[ -w $config_file ]]; then
        echo -e "\n# breuk" >> "$config_file"
        echo "$command" >> "$config_file"
        print_message info "Successfully added ${ORANGE}breuk ${GREEN}to \$PATH in $config_file"
    else
        print_message warning "Manually add the directory to $config_file (or similar):"
        print_message info "  $command"
    fi
}

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

current_shell=$(basename "$SHELL")
case $current_shell in
    fish)
        config_files="$HOME/.config/fish/config.fish"
    ;;
    zsh)
        config_files="$HOME/.zshrc $HOME/.zshenv $XDG_CONFIG_HOME/zsh/.zshrc $XDG_CONFIG_HOME/zsh/.zshenv"
    ;;
    bash)
        config_files="$HOME/.bashrc $HOME/.bash_profile $HOME/.profile $XDG_CONFIG_HOME/bash/.bashrc $XDG_CONFIG_HOME/bash/.bash_profile"
    ;;
    ash)
        config_files="$HOME/.ashrc $HOME/.profile /etc/profile"
    ;;
    sh)
        config_files="$HOME/.ashrc $HOME/.profile /etc/profile"
    ;;
    *)
        # Default case if none of the above matches
        config_files="$HOME/.bashrc $HOME/.bash_profile $XDG_CONFIG_HOME/bash/.bashrc $XDG_CONFIG_HOME/bash/.bash_profile"
    ;;
esac

config_file=""
for file in $config_files; do
    if [[ -f $file ]]; then
        config_file=$file
        break
    fi
done

if [[ -z $config_file ]]; then
    print_message error "No config file found for $current_shell. Checked files: ${config_files[@]}"
    exit 1
fi

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    case $current_shell in
        fish)
            add_to_path "$config_file" "fish_add_path $INSTALL_DIR"
        ;;
        zsh|bash|ash|sh)
            add_to_path "$config_file" "export PATH=$INSTALL_DIR:\$PATH"
        ;;
        *)
            print_message warning "Manually add the directory to $config_file (or similar):"
            print_message info "  export PATH=$INSTALL_DIR:\$PATH"
        ;;
    esac
fi

if [ -n "${GITHUB_ACTIONS-}" ] && [ "${GITHUB_ACTIONS}" == "true" ]; then
    echo "$INSTALL_DIR" >> $GITHUB_PATH
    print_message info "Added $INSTALL_DIR to \$GITHUB_PATH"
fi
