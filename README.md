# HemuLock

Send notifications and run scripts when system events occur (lock/unlock, sleep/wake, boot, shutdown).

![screenshots](https://s3.bmp.ovh/imgs/2022/08/15/7e2ec3c59efbf3e4.png)

这里有一份[中文文档](https://github.com/liopoos/HemuLock/blob/main/README_CN.md)。

## Requirements

- macOS 11 or later

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

## Events

HemuLock can listen to the following system events:

| Event         | Argument        |
| ------------- | --------------- |
| App Boot      | APP_BOOT        |
| Screen Sleep  | SCREEN_SLEEP    |
| Screen Wake   | SCREEN_WAKE     |
| System Sleep  | SYSTEM_SLEEP    |
| System Wake   | SYSTEM_WAKE     |
| System Lock   | SYSTEM_LOCK     |
| System Unlock | SYSTEM_UNLOCK   |
| System Shutdown | SYSTEM_SHUTDOWN |

### Historical Events

Starting from version 2.0.0, HemuLock supports historical events. All events are stored **locally** and can be viewed through the "Historical Events" menu item.

Currently, only the latest 12 historical records are displayed.

## Notifications

When an event is triggered, HemuLock can send a notification to the following services:

- [Pushover](https://pushover.net/)
- [Bark](https://github.com/Finb/Bark)

You can configure whether notifications are sent for system events and/or when Keep Awake is activated, separately.

If you need support for other notification services, please open an issue or submit a PR. :)

## Webhook

HemuLock supports sending HTTP POST webhooks to a custom URL when events are triggered. You can:

- Configure a custom webhook URL
- Select which events trigger the webhook
- Optionally include system information in the payload
- Set a custom request timeout

Webhook settings can be configured in **Preferences → Webhook**.

## Script

When **Execute Script** is enabled, HemuLock runs a shell script each time an event is triggered. The script file must be located at:

```
~/Library/Application Scripts/com.cyberstack.HemuLock/script
```

**Note**: This is a **file**, not a folder.

The event name is passed as the first argument (`$1`) to the script.

**Example script:**

```bash
#!/bin/bash

case $1 in
    SYSTEM_LOCK)
        echo "System locked"
        ;;
    SYSTEM_UNLOCK)
        echo "System unlocked"
        ;;
    SYSTEM_SLEEP)
        echo "System is sleeping"
        ;;
    SYSTEM_WAKE)
        echo "System woke up"
        ;;
    SCREEN_SLEEP)
        echo "Screen sleeping"
        ;;
    SCREEN_WAKE)
        echo "Screen woke up"
        ;;
    APP_BOOT)
        echo "HemuLock started"
        ;;
    SYSTEM_SHUTDOWN)
        echo "System shutting down"
        ;;
esac
```

## Keep Awake

HemuLock can prevent your Mac from sleeping using the system `caffeinate` utility. You can activate Keep Awake from the menu bar with the following duration options:

- 30 minutes
- 1 hour
- 4 hours
- 8 hours
- Permanent (until manually stopped)

When Keep Awake is active, a notification can optionally be sent (configurable in Preferences).

## Do-Not-Disturb Mode

If you don't want HemuLock to react to system events during a certain time period, enable **Do Not Disturb**. While active, no notifications will be sent and no scripts will be executed.

The Do Not Disturb time range can be configured in **Preferences**.

#### Status

| Status | Description         |
| ------ | ------------------- |
| 🟢      | Running              |
| 🟡      | Do-Not-Disturb Mode |

## License

©MIT
