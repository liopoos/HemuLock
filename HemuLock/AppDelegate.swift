//
//  AppDelegate.swift
//  hemu
//
//  Created by hades on 2021/3/31.
//

import Cocoa
import DefaultsKit
import LaunchAtLogin
import ServiceManagement
import Settings
import SwiftUI
import UserNotifications
import Logging

/// Global application state container accessible throughout the app
var appState = AppStateContainer()

/**
 AppDelegate is the main application delegate for HemuLock.
 
 This class manages the entire application lifecycle, including:
 - Menu bar status item creation and management
 - Settings window controller
 - System event observation
 - User notification handling
 - Menu state synchronization with app configuration
 
 The app runs as an accessory app (menu bar only) without a dock icon.
 */
@main
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSMenuDelegate {
    private let logger = LogManager.shared.logger(for: "AppDelegate")
    
    /// The main menu displayed in the menu bar
    private var mainMenu: NSMenu!
    
    /// The status bar item that hosts the menu
    private var statusItem: NSStatusItem!
    
    /// Event observer for system lock/unlock and sleep/wake events
    private var observer: EventObserver?
    
    /// Main window reference (unused in menu bar app)
    private var window: NSWindow!

    /// Controller for building the menu structure
    private let menuController = MenuController()

    /// Settings window controller with all preference panes
    private lazy var settingsWindowController = SettingsWindowController(
        panes: [
            GeneraPanelViewController(),
            EventPanelViewController(),
            NotifyPanelViewController(),
            WebhookPanelViewController(),
            DoNotDisturbPanelViewController(),
            HistoryPanelViewController(),
        ],
        style: .toolbarItems,
        animated: false
    )

    // MARK: - NSMenuDelegate
    
    /**
     Called before the menu is opened.
     
     Updates all menu items to reflect current application state, including:
     - Event record history
     - Checkbox states for toggleable items
     - Submenu selections
     */
    func menuWillOpen(_ menu: NSMenu) {
        updateRecordsMenu()
        updateMenuState(menu)
        updateSubMenu(menu)
    }

    /**
     Called after the menu is closed.
     
     Clears the menu reference to allow the menu to be rebuilt on next open.
     */
    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }

    // MARK: - Menu State Management
    
    /**
     Update menu item states based on current configuration.
     
     This method updates the checkmark states for:
     - Script execution toggle
     - Do Not Disturb mode toggle
     - Launch at login toggle
     - Event recording toggle
     
     - Parameter menu: The menu to update
     */
    func updateMenuState(_ menu: NSMenu) {
        if let item = menu.item(withTag: MenuItem.setScript.tag) {
            item.state = appState.appConfig.isExecScript ? .on : .off
        }

        if let item = menu.item(withTag: MenuItem.setDoNotDisturb.tag) {
            item.state = appState.appConfig.isDoNotDisturb ? .on : .off
        }
        
        if let item = menu.item(withTag: MenuItem.setWebhook.tag) {
            item.state = appState.appConfig.webhookConfig.enabled ? .on : .off
        }

        if let item = menu.item(withTag: MenuItem.setLaunchAtLogin.tag) {
            item.state = appState.appConfig.isLaunchAtLogin ? .on : .off
        }

        if let item = menu.item(withTag: MenuItem.setEventRecord.tag) {
            item.state = appState.appConfig.isRecordEvent ? .on : .off
        }
    }

    /**
     Update submenu items based on current configuration.
     
     This method updates:
     - App status icon (normal/disturb mode)
     - Event selection checkmarks
     - Notification service selection
     - Test notification button visibility
     
     - Parameter menu: The menu to update
     */
    func updateSubMenu(_ menu: NSMenu) {
        if let infoItem = menu.item(withTag: MenuItem.appInfo.tag) {
            let appStatusImg = NSImage(named: DisturbModeManager.shared.inDisturb() ? "AppStatus_Disturb" : "AppStatus_Run")
            appStatusImg?.size = NSSize(width: 15, height: 15)
            infoItem.image = appStatusImg
        }

        if let eventItem = menu.item(withTag: MenuItem.event.tag) {
            let eventList = appState.appConfig.activeEvents
            for item in eventItem.submenu!.items {
                if eventList.contains(item.tag) {
                    item.state = .on
                } else {
                    item.state = .off
                }
            }
        }

        if let notifyItem = menu.item(withTag: MenuItem.notify.tag) {
            for item in notifyItem.submenu!.items {
                item.state = item.tag == appState.appConfig.notifyType ? .on : .off
            }
        }

        if let notifyTestItem = menu.item(withTag: MenuItem.notifyTest.tag) {
            notifyTestItem.isHidden = appState.appConfig.notifyType == Notify.none.tag
        }
    }

    /**
     Update the event records submenu with recent history.
     
     This method:
     - Removes existing record menu items
     - Fetches up to 12 recent event records from the database
     - Creates formatted menu items showing event type and timestamp
     - Inserts the records submenu at position 8 in the main menu
     */
    func updateRecordsMenu() {
        let itemTag = MenuItem.eventRecord.tag
        let records = RecordRepository.shared.getRecords(limit: 12)

        // Remove all associated Tag items first.
        for item in mainMenu.items where item.tag == itemTag {
            mainMenu.removeItem(item)
        }

        if records.count <= 0 {
            return
        }

        // Add event records to main menu.
        let recordSubMenu = NSMenu()
        for record in records {
            let recordSubMenuItem = NSMenuItem(title: record.event, action: nil, keyEquivalent: "")
            recordSubMenuItem.title = record.event

            let eventTitle = "EVENT_\(record.event)".localized
            let eventTime = record.time.toLocalString()
            let attributedString = NSMutableAttributedString(string: "\(eventTitle)\n\(eventTime)")
            attributedString.addAttributes([.font: NSFont.systemFont(ofSize: 12)], range: NSRange(location: 0, length: eventTitle.count))
            attributedString.addAttributes([.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.gray], range: NSRange(location: eventTitle.count + 1, length: eventTime.description.count))
            recordSubMenuItem.attributedTitle = attributedString

            recordSubMenu.addItem(recordSubMenuItem)
            recordSubMenu.addItem(NSMenuItem.separator())
        }

        let recordMenuItem = NSMenuItem(title: "EVENT_RECORDS".localized, action: nil, keyEquivalent: "")
        recordMenuItem.tag = itemTag
        recordMenuItem.submenu = recordSubMenu
        mainMenu.insertItem(recordMenuItem, at: 8)
    }

    // MARK: - Menu Actions

    /**
     Lock the screen immediately.
     
     Calls the C function sleepNow() via the bridging header.
     */
    @objc func lockNow() {
        return sleepNow()
    }

    /**
     Launch the screen saver.
     
     Uses NSWorkspace to open the ScreenSaverEngine application.
     */
    @objc func runScreenSaver() {
        let appPath = "/System/Library/CoreServices/ScreenSaverEngine.app"
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: appPath),
                                          configuration: NSWorkspace.OpenConfiguration(),
                                          completionHandler: nil)
    }

    /**
     Send a test notification to verify configuration.
     
     Delegates to the event observer's sendNotify method.
     */
    @objc func sendNotifyTest() {
        observer?.sendNotify()
    }

    /**
     Update and display the menu.
     
     Assigns the menu to the status item and programmatically clicks it.
     */
    @objc func updateMenu() {
        statusItem.menu = mainMenu
        statusItem.button?.performClick(nil)
    }

    // MARK: - Configuration Toggles

    /**
     Toggle script execution on/off.
     
     - Parameter menuItem: The menu item that triggered this action
     */
    @objc func setScript(_ menuItem: NSMenuItem) {
        appState.appConfig.isExecScript = !appState.appConfig.isExecScript
        menuItem.state = appState.appConfig.isExecScript ? .on : .off
    }

    /**
     Set the notification service type.
     
     Updates the configuration to use the selected notification service.
     
     - Parameter menuItem: The menu item with the notification type tag
     */
    @objc func setNotify(_ menuItem: NSMenuItem) {
        appState.appConfig.notifyType = menuItem.tag
    }

    /**
     Toggle an event type on/off.
     
     Adds or removes the event type from the active events list.
     
     - Parameter menuItem: The menu item with the event type tag
     */
    @objc func setEvent(_ menuItem: NSMenuItem) {
        var eventList = appState.appConfig.activeEvents
        if eventList.contains(menuItem.tag) {
            eventList = eventList.filter { $0 != menuItem.tag }
        } else {
            eventList.append(menuItem.tag)
        }
        appState.appConfig.activeEvents = eventList
    }

    /**
     Toggle event recording on/off.
     
     - Parameter menuItem: The menu item that triggered this action
     */
    @objc func recordEvent(_ menuItem: NSMenuItem) {
        appState.appConfig.isRecordEvent = !appState.appConfig.isRecordEvent
        menuItem.state = appState.appConfig.isRecordEvent ? .on : .off
    }

    /**
     Toggle Do Not Disturb mode on/off.
     
     - Parameter menuItem: The menu item that triggered this action
     */
    @objc func setDoNotDisturb(_ menuItem: NSMenuItem) {
        appState.appConfig.isDoNotDisturb = !appState.appConfig.isDoNotDisturb
        menuItem.state = appState.appConfig.isDoNotDisturb ? .on : .off
    }

    /**
     Toggle webhook on/off.
     
     - Parameter menuItem: The menu item that triggered this action
     */
    @objc func setWebhook(_ menuItem: NSMenuItem) {
        appState.appConfig.webhookConfig.enabled = !appState.appConfig.webhookConfig.enabled
        menuItem.state = appState.appConfig.webhookConfig.enabled ? .on : .off
    }

    /**
     Toggle launch at login on/off.
     
     Updates both the app configuration and the system launch agent.
     
     - Parameter menuItem: The menu item that triggered this action
     */
    @objc func setLaunchLogin(_ menuItem: NSMenuItem) {
        appState.appConfig.isLaunchAtLogin = !appState.appConfig.isLaunchAtLogin
        LaunchAtLogin.isEnabled = appState.appConfig.isLaunchAtLogin
        menuItem.state = appState.appConfig.isLaunchAtLogin ? .on : .off
    }

    /**
     Open the preferences window.
     
     Shows the settings window and sets it to floating level to keep it on top.
     
     - Parameter menuItem: The menu item that triggered this action
     */
    @objc func openPreferences(_ menuItem: NSMenuItem) {
        settingsWindowController.show()
        
        // Set window to floating level to keep it on top
        if let window = settingsWindowController.window {
            window.level = .floating
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - NSApplicationDelegate
    
    /**
     Called when the application has finished launching.
     
     This method performs initial setup:
     - Sets app as accessory (menu bar only, no dock icon)
     - Closes the default window
     - Requests notification authorization
     - Creates menu bar status item with icon
     - Initializes event observer to monitor system events
     
     - Parameter notification: The launch notification
     */
    func applicationDidFinishLaunching(_: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // Hide Main view.
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        // Initialize logging system
        _ = LogManager.shared
        
        // Request notification authorization
        SystemNotificationManager.shared.requestAuthorization()
        SystemNotificationManager.shared.setDelegate(self)

        mainMenu = menuController.getMenu()
        mainMenu.delegate = self

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = mainMenu

        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
            button.image?.size = NSSize(width: 20, height: 20)
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(updateMenu)
        }

        observer = EventObserver()
    }

    /**
     Called when the application is about to terminate.
     
     - Parameter notification: The termination notification
     */
    func applicationWillTerminate(_ notification: Notification) {
        print("good night!")
    }
}
