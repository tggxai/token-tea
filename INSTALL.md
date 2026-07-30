# Install and start Token Tea

[简体中文](INSTALL.zh-CN.md)

This guide is for people who want to use Token Tea without building it from
source.

## Before you begin

You need:

- An Apple-silicon Mac running macOS 14 or later
- Codex installed and signed in on the same Mac
- The packaged
  [`Token-Tea-0.2.0-macOS-arm64.zip`](https://github.com/tggxai/token-tea/raw/refs/heads/main/downloads/Token-Tea-0.2.0-macOS-arm64.zip)

Token Tea uses your existing local Codex login. It does not ask for or store a
separate password.

## Install

1. Download
   [`Token-Tea-0.2.0-macOS-arm64.zip`](https://github.com/tggxai/token-tea/raw/refs/heads/main/downloads/Token-Tea-0.2.0-macOS-arm64.zip).
2. Double-click the ZIP file to extract `Token Tea.app`.
3. Drag `Token Tea.app` into your **Applications** folder.
4. Open **Applications** in Finder.
5. Control-click `Token Tea`, choose **Open**, then confirm **Open**.

The Control-click step may be required because the current community build is
not notarized by Apple. You only need to confirm it once.

## Start using it

Token Tea opens silently. It does not create a normal app window.

Look at the right side of the macOS menu bar:

- The **teacup** shows your remaining general Codex allowance. Click it for the
  exact percentage, reset time, and token activity.

If you cannot see the icons, check behind the MacBook notch or temporarily close
another menu-bar app to make space.

## Start automatically after login

1. Open **System Settings**.
2. Choose **General → Login Items**.
3. Under **Open at Login**, click the plus button.
4. Select `Token Tea` from the Applications folder.

## Troubleshooting

### “Codex login was not found”

Open Codex, sign in, and then use the refresh button in Token Tea.

### “Codex login needs to be refreshed”

Open Codex and sign in again, then refresh Token Tea.

### The teacup is missing

Make sure Token Tea is running, then create space on the menu bar by closing or
hiding another menu-bar item. Token Tea is intentionally menu-bar-only, so it
does not appear in the Dock.

### Quit or restart

Click the Token Tea menu-bar icon and choose **Quit**. Reopen it from the
Applications folder.
