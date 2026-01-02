# HemuLock

Send notify and run script when system lock/unlock and sleep/wake.

![screenshots](https://s3.bmp.ovh/imgs/2022/08/15/7e2ec3c59efbf3e4.png)

这里有一份[中文文档](https://github.com/liopoos/HemuLock/blob/main/README_CN.md)。

## Requirements

- macOS 10.15 or later

## Installation

- Download DMG file from [Releases](https://github.com/liopoos/HemuLock/releases)
- Drop the .app to Application folder

Signature issue ⚠️

HemuLock is open source software and is safe, but due to Apple's strict inspection mechanism, you may encounter warning interception when opening it.

If you cannot open it, please refer to the Apple manual [Open a Mac app from an unidentified developer](https://support.apple.com/en-us/guide/mac-help/mh40616/mac), or perform local code signing.


Local code signing for macOS

Install Command Line Tools:

```shell
xcode-select --install
```

Open the terminal and execute:

```shell
sudo codesign --force --deep --sign - /Applications/HemuLock.app/
```

"replacing existing signature" indicates successful local signing.

## Event

HemuLock can listening system events:

- Screen sleep
- Screen wake
- System sleep
- System wake
- System lock
- System unlock

### Historical event

Starting from version 2.0.0, HemuLock supports historical events, and all events will be stored **locally**. You can view the recent history events through the "Historical Events" menu.

Currently, only viewing the latest 12 historical records is supported.

## Notify Support

When the event is activated, HemuLock will take a request to notify servers, support notify is  :

- [Pushover](https://pushover.net/)
- [Server Sauce](https://sc.ftqq.com/9.version)
- [Bark](https://github.com/Finb/Bark)

If you need other notify, take an issue or try to pull requests. :)

## Script

When open **Script** option, HemuLock can run a script at the same time, the script file located the:

```
~/Library/Application Scripts/com.cyberstack.HemuLock/script
```

**notice**: This is a file, not a folder.

**This is a examle to send Pushover notify:**

```bash
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
        push "System locked"
        ;;
    SYSTEM_UNLOCK)
        push "System unlocked"
        ;;
    SYSTEM_SLEEP)
        push "System is sleep"
        ;;
esac
```

`Case` block is the system event, All arguments type is:

| Event         | Argument      |
| ------------- | ------------- |
| Screen Wake   | SCREEN_WAKE   |
| Screen Sleep  | SCREEN_SLEEP  |
| System Wake   | SYSTEM_WAKE   |
| System Sleep  | SYSTEM_SLEEP  |
| System Lock   | SYSTEM_LOCK   |
| System Unlock | SYSTEM_UNLOCK |

## Do-Not-Disturb Mode

If you don't want to listening system events for a certain period of time, you can take **Enable Do Not Disturb** open. When the time is in the Do Not Disturb time, no notification will be sent or script no t be execution.

Please modify the Do Not Disturb time setting in **Preferences**.

#### Status

| STATUS | INSTRUCTION         |
| ------ | ------------------- |
| 🟢      | Runing              |
| 🟡      | Do-Not-Disturb Mode |

## License

©MIT
