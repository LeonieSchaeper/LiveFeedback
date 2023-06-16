//
//  HapticFeedbackApp.swift
//  HapticFeedback
//
//  

import SwiftUI
import PusherSwift
import Foundation

class AppDelegate: NSObject, UIApplicationDelegate, PusherDelegate {
    var pusher: Pusher!
    let engine : HapticEngine  = {
        let h = HapticEngine()
        h.createEngine()
        return h
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {



        let options = PusherClientOptions(
             host: .cluster("eu")
           )

        pusher = Pusher(
         key: "83885cd25c3967f3c24c",
         options: options
        )

        pusher.delegate = self

        // subscribe to channel
        let channel = pusher.subscribe("my-channel")

        // bind a callback to handle an event
        let _ = channel.bind(eventName: "my-event", eventCallback: { (event: PusherEvent) in
           if let data = event.data {
             // you can parse the data as necessary
             print(data)
               
               self.playHaptic (data:data)
           }
        })

        pusher.connect()



        return true
    }
    
    func playHaptic (data : String) {
        struct Message  : Codable{
            var message : String
        }
        
        
        let decoder = JSONDecoder()
        let jsonData = data.data(using: .utf8)!
        if let messageResponse = try? decoder.decode (Message.self, from: jsonData) {

            guard let soundInt = Int(messageResponse.message) else {
                return
            }
            
            print ("▶️\(soundInt)")
            engine.playHapticsFile(named: String(soundInt))
            
        }
    }
    func debugLog(message: String) {
      print(message)
    }
}

@main
struct HapticFeedbackApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
