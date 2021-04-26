# HemuLock

当系统解锁、锁定的时候发送通知或执行脚本。

![screenshots](https://ftp.bmp.ovh/imgs/2021/04/5a9c780e2a361615.png)

This document is also available in [English](https://github.com/mayuko2012/HemuLock).

## 运行环境

macOS 10.15 或更高

## 安装

- 从 [Releases](https://github.com/mayuko2012/HemuLock/releases) 下载DMG文件
- 将 .app 文件拖入到 Application 文件夹

## 事件

HemuLock 可以监听系统以下事件：

- 屏幕睡眠
- 屏幕唤醒
- 系统睡眠
- 系统唤醒
- 系统锁定
- 系统解锁

## 支持的通知

当事件被激活时，HemuLock 将会发送一个通知到某个通知服务器，HemuLock 支持的通知服务器有：

- [Pushover](https://pushover.net/)
- [Server酱](https://sc.ftqq.com/9.version)

如果需要其他通知类型，请发起一个 issue 或者提交一个 Pr。:)

## 脚本

如果打开「执行脚本」，当事件被激活时，HemuLock 将执行一个 Shell 脚本，脚本文件位于：

```
~/Library/Application Scripts/com.ch.hades.HemuLock/script
```

**注意：**这是一个可编辑文件，而不是文件夹。

**一个发送 Pushover 的脚本示例：**

```shell
#!/bin/bash
PUSHOVER_TOKEN="xxx"
API_TOKEN="xxx"

push() {
    curl -s \
    --form-string "sk=$API_TOKEN" \
    --form-string "token=$PUSHOVER_TOKEN" \
    --form-string "user=xx" \
    --form-string "title=HemuLock's Notify" \
    --form-string "content=$1" \
    https://api.mayuko.cn/v1/push.message
}

case $1 in
    SYSTEM_LOCK)
        push "系统锁定"
        ;;
    SYSTEM_UNLOCK)
        push "系统解锁"
        ;;
    SYSTEM_SLEEP)
        push "系统进入睡眠模式"
        ;;
esac
```

`case`方法的参数是系统事件，所有的参数有：

| Event    | Argument      |
| -------- | ------------- |
| 屏幕唤醒 | SCREEN_WAKE   |
| 屏幕睡眠 | SCREEN_SLEEP  |
| 系统唤醒 | SYSTEM_WAKE   |
| 系统睡眠 | SYSTEM_SLEEP  |
| 系统锁定 | SYSTEM_LOCK   |
| 系统解锁 | SYSTEM_UNLOCK |

## 勿扰模式

如果希望某段时间内不监听系统事件，可以勾选**开启勿扰**。当时间在勿扰时间段时，将不会发送通知或执行事件。

勿扰时间设置请在「偏好设置」中进行修改。

#### 状态

| 状态 | 说明 |
| ---- | ---- |
| <span style="color: #63CA56">●</span>  | 正在运行 |
| <span style="color: #F6C744">●</span>     | 勿扰模式 |

## License

MIT

