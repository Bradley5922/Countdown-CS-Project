//
//  Countdown_WidgetApp.swift
//  Countdown Widget
//
//  Created by Bradley Cable on 19/09/2020.
//

import SwiftUI

@main
struct Countdown_WidgetApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            
            if UserDefaults.standard.bool(forKey: "First Launch") == false {
                
                //create table
                print("First launch db create: \(databaseConnector().createTable())")
                
                //add preset events
                
                //new years day
                var dateComponents = DateComponents()
                dateComponents.year = Calendar.current.component(.year, from: Date()).advanced(by: 1)
                dateComponents.month = 01
                dateComponents.day = 01
                dateComponents.hour = 0
                dateComponents.minute = 0
                
                print("Added NYE: \(databaseConnector().addToDB(data: eventObject(name: "New Years Day", date: Calendar.current.date(from: dateComponents)!, colors: [.red, .orange])))")
                
                UserDefaults.standard.set(true, forKey: "First Launch")
            } else {
                print("not first launch")
            }
            
            return true
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(events: databaseConnector().fetchEvents() ?? [eventObject]())
        }
    }
}
