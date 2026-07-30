# Token Tea

[English](README.md)

Token Tea 是一款轻量级原生 macOS 菜单栏应用，把 Codex 剩余额度变成一杯会随
使用量变化的茶。额度充足时茶杯是绿色且接近满杯；随着额度减少，茶水会逐渐下降，
颜色也会变为橙色或红色。

**只想直接使用？** 请查看[图文式安装与启动指南](INSTALL.zh-CN.md)。

## 主要功能

- 在 macOS 菜单栏直接显示 Codex 通用额度剩余情况
- 用茶杯液位表达剩余额度，不再增加一个只显示数字的状态组件
- 与 Codex 的核心额度摘要保持一致，并忽略 Codex Spark 等独立模型额度
- 显示当前额度周期和重置倒计时
- 从本地会话中统计新输入、缓存输入和输出 Token
- 每 30 秒自动刷新一次用量
- 静默启动，只常驻菜单栏，不弹出普通窗口
- 使用 SwiftUI 和 AppKit 构建，无第三方运行时依赖

## 运行要求

- macOS 14 或更高版本
- 当前构建版本需要 Apple 芯片 Mac
- 同一台 Mac 上已安装并登录 Codex
- 从源码构建时需要安装 Xcode Command Line Tools

## 构建与运行

```bash
git clone https://github.com/tggxai/token-tea.git
cd token-tea
./scripts/build-app.sh
open "dist/Token Tea.app"
```

构建脚本会生成一个临时签名的应用：

```text
dist/Token Tea.app
```

开发版本尚未经过 Apple 公证，因此 macOS 首次打开时可能会显示安全提示。可以按住
Control 点击应用，选择 **打开**，然后确认一次。

## 使用方法

Token Tea 启动时不会弹出普通窗口：

- 点击茶杯图标，查看准确的剩余百分比、额度重置时间和当前 Token 活动。
- 点击刷新按钮，可立即更新用量。
- 点击 **Quit** 即可退出应用。

如需开机自动启动，请打开 **系统设置 → 通用 → 登录项**，点击加号并选择
`Token Tea.app`。

## 用量计算方式

Token Tea 会在内存中读取 `~/.codex/auth.json` 里的现有 Codex 登录信息，并请求
Codex 所显示的通用用量数据。应用会比较核心额度周期，展示已使用比例最高的那个
周期。

例如，Codex 显示已使用 21% 时，Token Tea 会显示一杯 79% 满的绿色茶。Codex
Spark 等模型专属额度会被主动排除，因此菜单栏数据与 Codex 的通用用量摘要保持
一致。

新输入、缓存输入和输出统计来自当天本地 Codex 会话日志中的 `token_count` 数值
字段。

## 隐私说明

- Codex 登录凭据始终保留在你的 Mac 上。
- 凭据只在内存中读取，不会被记录或复制到其他位置。
- Token Tea 不会读取提示词或回复正文。
- 本地会话日志中只有数值形式的 `token_count` 字段会被读取。

## 开发

运行测试：

```bash
swift test
```

项目结构：

```text
Sources/TokenTea/     应用源码
Tests/TokenTeaTests/  解析与数据模型测试
scripts/              应用打包脚本
support/              macOS 应用包元数据
```

## 分发说明

当前构建脚本生成的是适用于 Apple 芯片的临时签名开发版本。正式公开发布二进制文件
时，建议使用 Developer ID 证书签名，开启 Hardened Runtime，并完成 Apple
公证。

Token Tea 是独立社区项目，与 OpenAI 没有关联，也未获得 OpenAI 官方认可。
