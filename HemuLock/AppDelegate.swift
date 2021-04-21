//
//  AppDelegate.swift
//  hemu
//
//  Created by hades on 2021/3/31.
//

import Cocoa
import ServiceManagement
import SwiftUI

func str(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let config = UserDefaults.standard
    let notify = Notify()
    let event = Event()
    let mainMenu = NSMenu()
    var window: NSWindow!
    
    var notifyMenu = NSMenu()
    var eventMenu = NSMenu()
    var appStatusMenu = NSMenuItem()
    var notifyTestMenu = NSMenuItem()
    
    func menuWillOpen(_ menu: NSMenu) {
        // render menu
        if menu == notifyMenu {
            for item in menu.items {
                if item.tag == notify.type {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        } else if menu == eventMenu {
            let eventList = event.list
            for item in menu.items {
                if eventList.contains(item.tag) {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        self.statusItem.menu = nil
    }
    
    // event
    @objc func lockNow() {
        return sleepNow()
    }
    
    @objc func runScreenSaver() {
        NSWorkspace.shared.launchApplication("ScreenSaverEngine")
    }
    
    @objc func sendNotifyTest() {
        runNotify(message: str("notify_test_message"), isAlert: true)
    }
    
    @objc func updateMenu() {
        let appStatusImg = NSImage(named: inDisturb(config: appConfig.do_no_disturb) ? "AppStatus_Disturb" : "AppStatus_Run")
        appStatusImg?.size = NSSize(width: 15, height: 15)
        appStatusMenu.image = appStatusImg
        
        statusItem.menu = mainMenu
        statusItem.button?.performClick(nil)
    }

    // set
    @objc func setScript(_ menuItem: NSMenuItem){
        let key = ConfigKey.action.script
        let value = !config.bool(forKey: key)
        config.set(value, forKey: key)
        menuItem.state = value ? .on : .off
    }
    
    @objc func setNotify(_ menuItem: NSMenuItem) {
        let value = menuItem.tag
        config.set(value, forKey: ConfigKey.notify.type)
        notify.type = value
        notifyTestMenu.isHidden = value == 0
    }
    
    @objc func setEvent(_ menuItem: NSMenuItem) {
        let key = ConfigKey.event.list
        var eventList = config.array(forKey: key) as? [Int] ?? [Int]()
        let value = menuItem.tag
        if eventList.contains(value) {
            eventList = eventList.filter{$0 != value}
        } else {
            eventList.append(value)
        }
        event.list = eventList
        config.set(eventList, forKey: key)
    }
    
    @objc func setDoNotDisturb(_ menuItem: NSMenuItem) {
        let key = ConfigKey.app.do_not_disturb
        let value = !config.bool(forKey: key)
        config.set(value, forKey: key)
        menuItem.state = value ? .on : .off
    }
    
    // launch login
    @objc func setLaunchLogin(_ menuItem: NSMenuItem) {
        let key = ConfigKey.app.login
        let value = !config.bool(forKey: key)
        config.set(value, forKey: key)
        menuItem.state = value ? .on : .off
        SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! + ".HemuLockHelper" as CFString, value)
    }
    
    @objc func setPreferences(_ menuItem: NSMenuItem) {
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 380),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        
        let contentView = PreferenceView(window: window)
        window.isReleasedWhenClosed = false
        window.title = str("preference_title")
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.delegate = contentView.windowDelegate
    }
    
    // observer
    func inEventList(_ tag: Int) -> Bool {
        return event.list.contains(tag)
    }
    
    @objc func onScreenSleep() {
        if !inEventList(Event.tag.screen_sleep) { return }
        print("Screen sleep.")
        self.runScript(Event.flag.screen_sleep)
        self.runNotify(message: str(Event.string.screen_sleep))
    }
    
    @objc func onScreenWake() {
        if !inEventList(Event.tag.screen_wake) { return }
        print("Screen wake.")
        self.runScript(Event.flag.screen_wake)
        self.runNotify(message: str(Event.string.screen_wake))
    }
    
    @objc func onSystemSleep() {
        if !inEventList(Event.tag.system_sleep) { return }
        print("System sleep.")
        self.runScript(Event.flag.system_sleep)
        self.runNotify(message: str(Event.string.system_sleep))
    }
    
    @objc func onSystemWake() {
        if !inEventList(Event.tag.system_wake) { return }
        print("System wake.")
        self.runScript(Event.flag.system_wake)
        self.runNotify(message: str(Event.string.system_wake))
    }
    
    @objc func onSystemLock() {
        if !inEventList(Event.tag.system_lock) { return }
        print("System locked.")
        self.runScript(Event.flag.system_lock)
        self.runNotify(message: str(Event.string.system_lock))
    }
    
    @objc func onSystemUnlock() {
        if !inEventList(Event.tag.system_unlock) { return }
        print("System unlocked.")
        self.runScript(Event.flag.system_unlock)
        self.runNotify(message: str(Event.string.system_unlock))
    }
    
    // hook
    func runScript(_ params: String) {
        if appConfig.do_no_disturb.type.script && inDisturb(config: appConfig.do_no_disturb) { return }
        
        let value = config.bool(forKey: ConfigKey.action.script)
        if !value { return }
        
        guard let directory = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        let file = directory.appendingPathComponent("script")
        let process = Process()
        process.executableURL = file
        process.arguments = [params]
        try? process.run()
    }
    
    func runNotify(message: String, isAlert: Bool = false) {
        if !isAlert && appConfig.do_no_disturb.type.notify && inDisturb(config: appConfig.do_no_disturb) { return }
        
        var title = str("notify_title")
        if let deviceName = Host.current().localizedName {
           title = deviceName + str("notify_title_device")
        }
        
        let notifyType = config.integer(forKey: ConfigKey.notify.type)
        let config = appConfig.notify
        
        
        if notifyType == 1 && isAlert && config.pushover.token.isEmpty {
            runSystemNotify(str("empty_pushover"))
        } else if notifyType == 2 && isAlert && config.servercat.sk.isEmpty {
            runSystemNotify(str("empty_servercat"))
        }
        
        switch notifyType {
        case 1:
            notify.sendPushover(config: config.pushover, title: title, message: message)
            break
        case 2:
            notify.sendServerCat(config: config.servercat, title: title, message: message)
            break
        default:
            break
        }
    }
    
    func runSystemNotify(_ message: String) {
        let notify = NSUserNotification()
        notify.title = str("notify_title")
        notify.informativeText = message
        notify.deliveryDate = Date().addingTimeInterval(1)
        NSUserNotificationCenter.default.scheduleNotification(notify)
    }
    
    func renderMenu() {
        // get notify type
        let notifyType = config.integer(forKey: ConfigKey.notify.type)
        if notifyType != 0 {
            notify.type = Int(notifyType)
        } else {
            config.set(notify.type, forKey: ConfigKey.notify.type)
        }
        // get event list
        let eventList = config.array(forKey: ConfigKey.event.list) as? [Int] ?? [Int]()
        if eventList != [] {
            event.list = eventList
        } else {
            config.set(event.list, forKey: ConfigKey.event.list)
        }
        
        let infoDictionary = Bundle.main.infoDictionary
        if let infoDictionary = infoDictionary {
            let appVersion = infoDictionary["CFBundleShortVersionString"]
            let appName = infoDictionary["CFBundleDisplayName"]
            let appBuild = infoDictionary["CFBundleVersion"]
            appStatusMenu = mainMenu.addItem(withTitle: (appName as! String) + " v\(appVersion!)(\(appBuild!))", action:  nil, keyEquivalent: "")
            mainMenu.addItem(NSMenuItem.separator())
        }
        
        
        mainMenu.addItem(withTitle: str("lock_now"), action:  #selector(lockNow), keyEquivalent: "L")
        mainMenu.addItem(NSMenuItem.separator())
        
        mainMenu.addItem(withTitle: str("run_screensaver"), action:  #selector(runScreenSaver), keyEquivalent: "S")
        mainMenu.addItem(NSMenuItem.separator())
        
        let EventMenuItem = mainMenu.addItem(withTitle: str("set_event"), action: nil, keyEquivalent: "")
        EventMenuItem.submenu = eventMenu
        eventMenu.addItem(withTitle: str("event_screen_sleep"), action: #selector(setEvent), keyEquivalent: "").tag = Event.tag.screen_sleep
        eventMenu.addItem(withTitle: str("event_screen_wake"), action: #selector(setEvent), keyEquivalent: "").tag = Event.tag.screen_wake
        eventMenu.addItem(NSMenuItem.separator())
        eventMenu.addItem(withTitle: str("event_system_sleep"), action: #selector(setEvent), keyEquivalent: "").tag = Event.tag.system_sleep
        eventMenu.addItem(withTitle: str("event_system_wake"), action: #selector(setEvent), keyEquivalent: "").tag = Event.tag.system_wake
        eventMenu.addItem(NSMenuItem.separator())
        eventMenu.addItem(withTitle: str("event_system_lock"), action: #selector(setEvent), keyEquivalent: "").tag = Event.tag.system_lock
        eventMenu.addItem(withTitle: str("event_system_unlock"), action: #selector(setEvent), keyEquivalent: "").tag = Event.tag.system_unlock
        eventMenu.delegate = self
        
        mainMenu.addItem(NSMenuItem.separator())
        
        var item = mainMenu.addItem(withTitle: str("set_script"), action:  #selector(setScript), keyEquivalent: "")
        item.state = config.bool(forKey: ConfigKey.action.script) ? .on : .off
        
        let NotifyMenuItem = mainMenu.addItem(withTitle: str("set_notify"), action: nil, keyEquivalent: "")
        NotifyMenuItem.submenu = notifyMenu
        notifyMenu.addItem(withTitle: str("notify_none"), action: #selector(setNotify), keyEquivalent: "").tag = 0
        notifyMenu.addItem(NSMenuItem.separator())
        notifyMenu.addItem(withTitle: str("notify_pushover"), action: #selector(setNotify), keyEquivalent: "").tag = 1
        notifyMenu.addItem(withTitle: str("notify_servercat"), action: #selector(setNotify), keyEquivalent: "").tag = 2
        notifyMenu.delegate = self
        
        notifyTestMenu = mainMenu.addItem(withTitle: str("notify_test"), action: #selector(sendNotifyTest), keyEquivalent: "")
        mainMenu.addItem(NSMenuItem.separator())
        
        item = mainMenu.addItem(withTitle: str("set_do_not_disturb"), action:  #selector(setDoNotDisturb), keyEquivalent: "")
        item.state = config.bool(forKey: ConfigKey.app.do_not_disturb) ? .on : .off
        mainMenu.addItem(NSMenuItem.separator())
        
        item = mainMenu.addItem(withTitle: str("launch_at_login"), action: #selector(setLaunchLogin), keyEquivalent: "")
        item.state = config.bool(forKey: ConfigKey.app.login) ? .on : .off
        
        item = mainMenu.addItem(withTitle: str("set_preferences"), action: #selector(setPreferences), keyEquivalent: "")
        item.state = config.bool(forKey: ConfigKey.app.preferences) ? .on : .off
        
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(withTitle: str("quit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q")
        
        mainMenu.delegate = self
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.renderMenu()
        
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
            button.action = #selector(updateMenu)
            button.sendAction(on: [.leftMouseUp])
        }
        
        let SystemObserver = NSWorkspace.shared.notificationCenter;
        SystemObserver.addObserver(self, selector: #selector(onScreenSleep), name: NSWorkspace.screensDidSleepNotification, object: nil)
        SystemObserver.addObserver(self, selector: #selector(onScreenWake), name: NSWorkspace.screensDidWakeNotification, object: nil)
        SystemObserver.addObserver(self, selector: #selector(onSystemSleep), name: NSWorkspace.willSleepNotification, object: nil)
        SystemObserver.addObserver(self, selector: #selector(onSystemWake), name: NSWorkspace.didWakeNotification, object: nil)
        
        let DistributeObserver = DistributedNotificationCenter.default
        DistributeObserver.addObserver(self, selector: #selector(onSystemLock), name: NSNotification.Name(rawValue: "com.apple.screenIsLocked"), object: nil)
        DistributeObserver.addObserver(self, selector: #selector(onSystemUnlock), name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print("bey!")
    }
}
