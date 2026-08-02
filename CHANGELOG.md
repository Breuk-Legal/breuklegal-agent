# Changelog

Curated version history of Breuk Agent. Entries are written for users; one entry may cover several patch releases.

## 0.1.22 – 0.1.25

Installation fixes on all three systems.

macOS archives are now named after the architecture they actually contain. Until 0.1.21 the published file said `x86_64` but held an Apple Silicon binary, so Apple Silicon Macs got a download error and Intel Macs got a binary that would not run — there was no Mac where installation worked.

On Windows, `breuk` now talks to the console that started it. Before this, the application installed correctly and then appeared to do nothing: `breuk login` printed no sign-in code and `breuk` waited invisibly for a sign-in nobody could complete.

Windows also gained a one-line installer, so all three systems now install with a single command. The installers check the system component the application needs in order to open, and stop with instructions when it is missing, instead of letting the download succeed and the application crash on first launch.

A fix keeps the official Legal Skills from going missing when their source repository is reorganised.

## 0.1.21

Breuk Agent reads documents and edits Word files. It can create and edit `.docx` while preserving the existing formatting, rather than producing a plain rewrite.

The coding surface inherited from the original fork was removed. Breuk Agent is a legal agent: it reasons over documents and matters, and no longer offers code editing or code navigation.

## 0.1.18 – 0.1.20

The interactive session moved from the terminal to a native desktop window. `breuk` now opens an application; sign-in still happens in the terminal with `breuk login`.

The window came with a real interface: readable typography and colour, keyboard and mouse throughout, and a model that can be chosen per conversation instead of globally. The message composer got an accessible equivalent of its autocomplete, usable without a pointer.

## 0.1.12 – 0.1.16

Several conversations at once, in tabs. Each tab keeps its own session, its own permission prompts and its own busy state, so a long-running answer in one no longer blocks the others. Closing the last tab exits, and a tab with work in progress asks before closing.

Also in these releases: mouse support on the model and connector badges, a `breuk skills` command that lists which Legal Skills are active and which are shadowed, a connector status dialog, and a configuration summary inside the model dialog.

## 0.1.9 – 0.1.11

Models are managed by Breuk. The catalogue is served by the Breuk gateway and kept up to date centrally, so the available models no longer depend on the version installed.

Bring-your-own-key was removed, along with the local model runtime. Access to models now goes through a Breuk account with an active subscription, which is what the licence always described. When the gateway rejects a request, the message says what to do about it.

## 0.1.4 – 0.1.8

Support for Agent Skills: reusable instructions in `SKILL.md` files. Official Legal Skills ship inside the binary, and your own skills — per project or per user — take precedence over them.

Connectors were modernised, with sessions that stay open across a conversation instead of reconnecting each time. Remote connectors that require authorisation are now supported: `breuk mcp` manages them, credentials are stored and refreshed, and a run without an interactive window fails clearly instead of hanging when one needs authorisation.

## 0.1.1 – 0.1.2

Initial public release of Breuk Agent: the terminal-based AI legal agent by Breuk Legal, for Linux, macOS and Windows.
