//
//  PrefercenceView.swift
//  Hemu
//
//  Created by hades on 2021/4/9.
//

import SwiftUI

struct PreferenceView: View {
    let window: NSWindow?
    var windowDelegate: PreferenceWindowDelegate = PreferenceWindowDelegate()
    @State var config = appConfig
    @State var do_not_disturb_start = formatDateByString(date: appConfig.do_no_disturb.start)
    @State var do_not_disturb_end = formatDateByString(date: appConfig.do_no_disturb.end)
    @State var tab_current = 1
    var body: some View {
        TabView(selection: $tab_current) {
            VStack() {
                Section {
                    HStack {
                        Text(str("notify_pushover")).font(.headline).multilineTextAlignment(.leading).padding(.leading)
                        Spacer()
                    }
                    HStack {
                        Text("User").frame(width: 60, alignment: .bottomTrailing)
                        TextField(str("preference_filed") + "User", text: $config.notify.pushover.user)
                        Spacer()
                    }.padding(5)
                    HStack {
                        Text("Token").frame(width: 60, alignment: .bottomTrailing)
                        TextField(str("preference_filed") + "Token", text: $config.notify.pushover.token)
                        Spacer()
                    }.padding(5)
                }
                Divider().padding()
                Section {
                    HStack {
                        Text(str("notify_servercat")).font(.headline).multilineTextAlignment(.leading).padding(.leading)
                        Spacer()
                    }
                    HStack {
                        Text("SK Key").frame(width: 60, alignment: .bottomTrailing)
                        TextField(str("preference_filed") + "SK Key", text: $config.notify.servercat.sk)
                        Spacer()
                    }.padding(5)
                }
                Spacer()
            }.tabItem { Text(str("preference_notify")) }.tag(1)
            VStack() {
                VStack {
                    HStack {
                        Text(str("do_not_disturb_start")).frame(width: 60, alignment: .bottomTrailing)
                        DatePicker(selection: $do_not_disturb_start , displayedComponents: [.hourAndMinute], label: {})
                        Spacer()
                        Text("-")
                        Text(str("do_not_disturb_end")).frame(width: 60, alignment: .bottomTrailing)
                        DatePicker(selection: $do_not_disturb_end, displayedComponents: [.hourAndMinute], label: {})
                    }
                    HStack {
                        Text(str("do_not_disturb_type")).frame(width: 60, alignment: .bottomTrailing)
                        HStack {
                            Toggle(str("set_notify"), isOn: $config.do_no_disturb.type.notify)
                            Toggle(str("set_script"), isOn: $config.do_no_disturb.type.script)
                        }
                        Spacer()
                    }
                    HStack {
                        Text(str("do_not_disturb_cycle")).frame(width: 60, alignment: .bottomTrailing)
                        HStack {
                            Toggle(str("do_not_disturb_cycle_sunday"), isOn: $config.do_no_disturb.cycle.sunday)
                            Toggle(str("do_not_disturb_cycle_monday"), isOn: $config.do_no_disturb.cycle.monday)
                            Toggle(str("do_not_disturb_cycle_tuesday"), isOn: $config.do_no_disturb.cycle.tuesday)
                            Toggle(str("do_not_disturb_cycle_wednesday"), isOn: $config.do_no_disturb.cycle.wednesday)
                            Toggle(str("do_not_disturb_cycle_thursday"), isOn: $config.do_no_disturb.cycle.thursday)
                            Toggle(str("do_not_disturb_cycle_firday"), isOn: $config.do_no_disturb.cycle.firday)
                            Toggle(str("do_not_disturb_cycle_saturday"), isOn: $config.do_no_disturb.cycle.saturday)
                        }
                        Spacer()
                    }
                }.padding(5)
                Spacer()
            }.tabItem { Text(str("preference_do_not_disturb")) }.tag(2)
        }.padding(.top, 10).frame(width: .infinity, height: 260, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        HStack {
            Spacer()
            Button(action: setNotifyConfig) {
                Text(str("preference_save"))
            }
        }.padding()
    }
    
    func setNotifyConfig() {
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        config.do_no_disturb.start = formatDateByDate(date: do_not_disturb_start)
        config.do_no_disturb.end = formatDateByDate(date: do_not_disturb_end)
        setPrefercenceConfig(config: config)
        self.window!.close()
    }
}

#if DEBUG
struct PrefercenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(window: nil)
    }
}
#endif

class PreferenceWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        print("Hey!")
    }
}
