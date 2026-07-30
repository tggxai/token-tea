# 安装并启动 Token Tea

[English](INSTALL.md)

本指南适合只想使用 Token Tea、不需要从源码构建的用户。

## 开始之前

你需要：

- 运行 macOS 14 或更高版本的 Apple 芯片 Mac
- 已在同一台 Mac 上安装并登录 Codex
- 下载已打包的
  [`Token-Tea-0.2.0-macOS-arm64.zip`](https://github.com/tggxai/token-tea/raw/refs/heads/main/downloads/Token-Tea-0.2.0-macOS-arm64.zip)

Token Tea 会使用你现有的本地 Codex 登录状态，不会要求或保存单独的密码。

## 安装

1. 下载
   [`Token-Tea-0.2.0-macOS-arm64.zip`](https://github.com/tggxai/token-tea/raw/refs/heads/main/downloads/Token-Tea-0.2.0-macOS-arm64.zip)。
2. 双击 ZIP 文件，解压得到 `Token Tea.app`。
3. 将 `Token Tea.app` 拖入 **应用程序** 文件夹。
4. 在 Finder 中打开 **应用程序**。
5. 按住 Control 点击 `Token Tea`，选择 **打开**，再确认一次 **打开**。

当前社区构建版本尚未经过 Apple 公证，因此可能需要通过 Control 点击的方式确认首次
启动。这个步骤通常只需要操作一次。

## 开始使用

Token Tea 会静默启动，不会打开普通应用窗口。

请查看 macOS 菜单栏右侧：

- **茶杯**显示 Codex 通用额度剩余情况。点击后可以查看准确百分比、重置时间和
  Token 活动。

如果看不到图标，请检查图标是否被 MacBook 刘海遮挡，或暂时关闭其他菜单栏应用，
为 Token Tea 腾出空间。

## 登录后自动启动

1. 打开 **系统设置**。
2. 进入 **通用 → 登录项**。
3. 在 **登录时打开** 下方点击加号。
4. 从应用程序文件夹中选择 `Token Tea`。

## 常见问题

### 显示 “Codex login was not found”

打开 Codex 并完成登录，然后在 Token Tea 中点击刷新按钮。

### 显示 “Codex login needs to be refreshed”

打开 Codex 重新登录，然后刷新 Token Tea。

### 菜单栏看不到茶杯

先确认 Token Tea 正在运行，然后关闭或隐藏一个其他菜单栏项目来腾出空间。Token
Tea 是纯菜单栏应用，因此不会显示在 Dock 中。

### 退出或重新启动

点击 Token Tea 菜单栏图标并选择 **Quit**。需要重新启动时，从应用程序文件夹再次
打开即可。
