# HemuLock

Send notify and run script when system lock/unlock and sleep/wake.

![screenshots](https://ftp.bmp.ovh/imgs/2021/04/5a9c780e2a361615.png)

这里有一份[中文文档](https://github.com/mayuko2012/HemuLock/blob/main/README_CN.md)。

## Requirements

- macOS 10.15 or later

## Installation

- Download DMG file from [Releases](https://github.com/mayuko2012/HemuLock/releases)
- Drop the .app to Application folder

## Event

HemuLock can listening system events:

- Screen sleep
- Screen wake
- System sleep
- System wake
- System lock
- System unlock

## Notify Support

When the event is activated, HemuLock will take a request to notify servers, support notify is  :

- [Pushover](https://pushover.net/)
- [Server Sauce](https://sc.ftqq.com/9.version)

If you need other notify, take an issue or try to pull requests. :)

## Script

When open **Script** option, HemuLock can run a script at the same time, the script file located the:

```
~/Library/Application Scripts/com.ch.hades.HemuLock/script
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

## License

MIT