# HemuLock

当系统发生锁定/解锁、睡眠/唤醒、启动、关机等事件时，发送通知或执行脚本。

![screenshots](https://s3.bmp.ovh/imgs/2022/08/15/7e2ec3c59efbf3e4.png)

This document is also available in [English](https://github.com/liopoos/HemuLock).

## 运行环境

macOS 11 或更高

## 安装

- 从 [Releases](https://github.com/liopoos/HemuLock/releases) 下载 DMG 文件
- 将 .app 文件拖入到 Application 文件夹

⚠️ 签名问题

HemuLock 是开源软件，本身是安全的，但由于苹果严格的检查机制，打开时可能会遇到警告拦截。

如果无法打开，请参考苹果使用手册 [打开来自身份不明开发者的 Mac App](https://support.apple.com/zh-cn/guide/mac-help/mh40616/mac)，或者进行本地代码签名。

macOS 本地代码签名

安装 Command Line Tools：

```shell
xcode-select --install
```

打开终端并执行：

```shell
sudo codesign --force --deep --sign - /Applications/HemuLock.app/
```

出现 「replacing existing signature」 即本地签名成功。

## 事件

HemuLock 可以监听以下系统事件：

| 事件       | 参数              |
| ---------- | ----------------- |
| 应用启动   | APP_BOOT          |
| 屏幕睡眠   | SCREEN_SLEEP      |
| 屏幕唤醒   | SCREEN_WAKE       |
| 系统睡眠   | SYSTEM_SLEEP      |
| 系统唤醒   | SYSTEM_WAKE       |
| 系统锁定   | SYSTEM_LOCK       |
| 系统解锁   | SYSTEM_UNLOCK     |
| 系统关机   | SYSTEM_SHUTDOWN   |

### 历史事件

从 2.0.0 开始，HemuLock 支持历史事件，所有的事件将存储在**本地**，你可以通过「历史事件」菜单栏查看最近的历史事件。

目前仅支持查看最近 12 条历史记录。

## 支持的通知

当事件被激活时，HemuLock 将会发送通知到以下服务：

- [Pushover](https://pushover.net/)
- [Bark](https://github.com/Finb/Bark)

可以在偏好设置中分别配置是否为系统事件、以及保持唤醒激活时发送通知。

如果需要其他通知类型，请发起一个 issue 或者提交一个 PR。:)

## Webhook

HemuLock 支持在事件触发时向自定义 URL 发送 HTTP POST 请求。你可以：

- 配置自定义 Webhook URL
- 选择哪些事件触发 Webhook
- 可选在请求体中包含系统信息
- 设置自定义请求超时时间

Webhook 相关设置请在「偏好设置 → Webhook」中配置。

## 脚本

如果打开「执行脚本」，当事件被激活时，HemuLock 将执行一个 Shell 脚本，脚本文件位于：

```
~/Library/Application Scripts/com.cyberstack.HemuLock/script
```

**注意：** 这是一个可编辑**文件**，而不是文件夹。

脚本将以事件名称作为第一个参数（`$1`）被调用。

**脚本示例：**

```bash
#!/bin/bash

case $1 in
    SYSTEM_LOCK)
        echo "系统锁定"
        ;;
    SYSTEM_UNLOCK)
        echo "系统解锁"
        ;;
    SYSTEM_SLEEP)
        echo "系统进入睡眠"
        ;;
    SYSTEM_WAKE)
        echo "系统唤醒"
        ;;
    SCREEN_SLEEP)
        echo "屏幕睡眠"
        ;;
    SCREEN_WAKE)
        echo "屏幕唤醒"
        ;;
    APP_BOOT)
        echo "HemuLock 已启动"
        ;;
    SYSTEM_SHUTDOWN)
        echo "系统正在关机"
        ;;
esac
```

## 保持唤醒

HemuLock 可以通过系统的 `caffeinate` 工具阻止 Mac 进入睡眠状态。你可以在菜单栏中选择以下持续时间来激活保持唤醒：

- 30 分钟
- 1 小时
- 4 小时
- 8 小时
- 永久（直到手动停止）

保持唤醒激活时，可选向通知服务发送一条通知（在偏好设置中配置）。

## 勿扰模式

如果希望某段时间内不监听系统事件，可以勾选**开启勿扰**。当时间在勿扰时间段内时，将不会发送通知或执行脚本。

勿扰时间设置请在「偏好设置」中进行修改。

#### 状态

| 状态 | 说明         |
| ---- | ------------ |
| 🟢   | 正在运行     |
| 🟡   | 勿扰模式     |

## License

©MIT

