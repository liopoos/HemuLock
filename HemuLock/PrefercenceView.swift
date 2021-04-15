//
//  PrefercenceView.swift
//  Hemu
//
//  Created by hades on 2021/4/9.
//

import SwiftUI

struct PrefercenceView: View {
    let window: NSWindow?
    var windowDelegate: PreferenceWindowDelegate = PreferenceWindowDelegate()
    
    @State var config = Notify().getNotifyConfig()
    
    var body: some View {
        VStack() {
            Section {
                HStack {
                    Text(str("notify_pushover")).font(.title).multilineTextAlignment(.leading).padding(.leading)
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
                    Text(str("notify_servercat")).font(.title).multilineTextAlignment(.leading).padding(.leading)
                    Spacer()
                }
                HStack {
                    Text("SK Key").frame(width: 60, alignment: .bottomTrailing)
                    TextField(str("preference_filed") + "SK Key", text: $config.notify.servercat.sk)
                    Spacer()
                }.padding(5)
            }
            HStack {
                Spacer()
                Button(action: setNotifyConfig) {
                    Text(str("preference_save"))
                }.padding()
            }
        }.padding()
    }
    
    func setNotifyConfig() {
        Notify().setNotifyConfig(config: config)
        self.window!.close()
    }
}

#if DEBUG
struct PrefercenceView_Previews: PreviewProvider {
    static var previews: some View {
        PrefercenceView(window: nil)
    }
}
#endif

class PreferenceWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        print("Hey!")
    }
}
