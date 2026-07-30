# Token Tea

[简体中文](README.zh-CN.md)

Token Tea is a lightweight native macOS menu-bar app that turns your remaining
Codex allowance into a colorful cup of tea. A full green cup means plenty of
usage remains; as the allowance falls, the cup drains and changes to orange or
red.

**Just want to use the app?** See the
[step-by-step installation guide](INSTALL.md).

## Highlights

- Shows general Codex usage remaining directly in the macOS menu bar
- Uses a fill-level teacup instead of another number-heavy status widget
- Matches Codex's core allowance summary and ignores separate model-specific
  allowances such as Codex Spark
- Displays the active allowance window and reset countdown
- Shows fresh input, cached input, and output token activity from local sessions
- Refreshes usage automatically every 30 seconds
- Launches silently as a menu-bar-only app
- Built with SwiftUI and AppKit, with no third-party runtime dependencies

## Requirements

- macOS 14 or later
- An Apple-silicon Mac for the current build
- Codex installed and signed in on the same Mac
- Xcode Command Line Tools when building from source

## Build and run

```bash
git clone https://github.com/tggxai/token-tea.git
cd token-tea
./scripts/build-app.sh
open "dist/Token Tea.app"
```

The build script creates an ad-hoc-signed app at:

```text
dist/Token Tea.app
```

Because development builds are not notarized, macOS may ask you to confirm the
first launch. Control-click the app, select **Open**, and confirm once.

## Use

Token Tea launches without opening a normal window:

- Click the teacup to see the exact percentage remaining, allowance reset time,
  and current token activity.
- Use the refresh button to update usage immediately.
- Click **Quit** to stop the app.

To launch Token Tea automatically, open **System Settings → General → Login
Items**, click the plus button, and select `Token Tea.app`.

## How usage is calculated

Token Tea reads your existing Codex login from `~/.codex/auth.json` in memory
and requests the same general usage data displayed by Codex. It compares the
core usage windows and displays the one with the highest percentage used.

For example, when Codex reports 21% used, Token Tea displays a 79%-full green
cup. Additional model-specific allowances are deliberately excluded so the
number matches the general Codex usage summary.

The fresh input, cached input, and output breakdown is calculated from
`token_count` fields in the current day's local Codex session logs.

## Privacy

- Your Codex credentials remain on your Mac.
- Credentials are read only in memory and are never logged or copied elsewhere.
- Token Tea never reads prompt or response text.
- Only numerical `token_count` fields are read from local session logs.

## Development

Run the tests with:

```bash
swift test
```

Project layout:

```text
Sources/TokenTea/     App source
Tests/TokenTeaTests/  Parsing and data-model tests
scripts/              App packaging scripts
support/              macOS bundle metadata
```

## Distribution notes

The included build script creates an Apple-silicon, ad-hoc-signed development
build. A public binary release should be signed with a Developer ID certificate,
built with the Hardened Runtime, and notarized by Apple.

Token Tea is an independent community project and is not affiliated with or
endorsed by OpenAI.
