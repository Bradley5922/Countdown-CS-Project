//
//  DatabaseConnector.swift
//  Countdown Widget
//
//  Created by Bradley Cable on 19/09/2020.
//

import Foundation
import SQLite
import SwiftUI
import WatchConnectivity

struct eventObject: Identifiable {
    var id = UUID()
    var name: String
    var date: Date = Date(timeIntervalSinceNow: 7884000)
    var colors: [Color] = [.red, .orange]
    var bgIMG: String? = ""
    var databaseID: Int64?
}

public class databaseConnector {
    
    //global vars most functions need
    let eventsTable = Table("events")
    let id = Expression<Int64>("id")
    let eventName = Expression<String>("name")
    let date = Expression<String>("date")
    let color1 = Expression<String>("color1")
    let color2 = Expression<String>("color2")
    let bgIMG = Expression<String>("bgIMG")
    
    //where the databse is stored in ‘Documents and Data’
//    #if os(iOS)
    let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.widgetShareData.countdown")!.absoluteString
//    #endif
//    #if os(watchOS)
//    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//    #endif
    
    func createTable() -> Bool {
        do {
            let db = try Connection("\(path)/events.sqlite3")
            
            // create table
            try db.run(eventsTable.create { t in
                t.column(id, primaryKey: true)
                t.column(eventName)
                t.column(date)
                t.column(color1)
                t.column(color2)
                t.column(bgIMG)
            })
                
            //table make successfully
            return true
        } catch {
            //idk what went wrong
            return false
        }
    }
    
    func importCountDowns(file: URL, doneProcessing: @escaping (_ done: Bool) -> Void) {
        do {
            let db = try Connection(file.absoluteString)
            
            var eventsNeedImport: [eventObject] = []
            
            for event in try db.prepare(eventsTable) {
                //convert string date to Date object
                let dateFormate = DateFormatter()
                dateFormate.dateFormat = "yyyy-MM-dd"
                let dateObject = dateFormate.date(from: "\(event[date])")
                
                //convert string to color
                let colorOneArray = event[color1].components(separatedBy: ",")
                let colorOne = Color(red: (colorOneArray[0] as NSString).doubleValue, green: (colorOneArray[1] as NSString).doubleValue, blue: (colorOneArray[2] as NSString).doubleValue)
                
                let colorTwoArray = event[color2].components(separatedBy: ",")
                let colorTwo = Color(red: (colorTwoArray[0] as NSString).doubleValue, green: (colorTwoArray[1] as NSString).doubleValue, blue: (colorTwoArray[2] as NSString).doubleValue)
                
                //add to temp array and return
                eventsNeedImport.append(eventObject(name: "\(event[eventName])", date: dateObject!, colors: [colorOne, colorTwo], bgIMG: event[bgIMG], databaseID: event[id]))
            }
            
            for event in eventsNeedImport {
                print("Event added - import: \(addToDB(data: event))")
            }
            
            doneProcessing(true)
        } catch {
            print(error)
            
            doneProcessing(false)
        }
    }
    
    func deleteEverything() -> Bool {
        do {
            let db = try Connection("\(path)/events.sqlite3")
            
            try db.run(eventsTable.delete())
            
            return true
        } catch {
            return false
        }
    }
    
    func fetchEvents() -> [eventObject]? {
        do {
            
            let db = try Connection("\(path)/events.sqlite3")
            var tempArray = [eventObject]()
            
            for event in try db.prepare(eventsTable.order(date)) {
                //convert string date to Date object
                let dateFormate = DateFormatter()
                dateFormate.dateFormat = "yyyy-MM-dd"
                let dateObject = dateFormate.date(from: "\(event[date])")
                
                //convert string to color
                let colorOneArray = event[color1].components(separatedBy: ",")
                let colorOne = Color(red: (colorOneArray[0] as NSString).doubleValue, green: (colorOneArray[1] as NSString).doubleValue, blue: (colorOneArray[2] as NSString).doubleValue)
                
                let colorTwoArray = event[color2].components(separatedBy: ",")
                let colorTwo = Color(red: (colorTwoArray[0] as NSString).doubleValue, green: (colorTwoArray[1] as NSString).doubleValue, blue: (colorTwoArray[2] as NSString).doubleValue)
                
                //add to temp array and return
                tempArray.append(eventObject(name: "\(event[eventName])", date: dateObject!, colors: [colorOne, colorTwo], bgIMG: event[bgIMG], databaseID: event[id]))
            }
            
            return tempArray
        } catch {
            print(error)

            return nil
        }
    }
    
    func fetchEventWidgetChoice() -> [eventObject]? {
        do {
            
            let db = try Connection("\(path)/events.sqlite3")
            // init an arry that contains event object
            var tempArray = [eventObject]()
            
            // select only the two fields
            for event in try db.prepare(eventsTable.select(id, eventName)) {
                // loop though all the events
                
                // add to temp array and return
                tempArray.append(eventObject(name: "\(event[eventName])", databaseID: event[id]))
            }
            
            // return the finshed array
            return tempArray
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetchEventsID(filterID: Int64) -> eventObject {
        do {
            
            let db = try Connection("\(path)/events.sqlite3")
            var temp = eventObject(name: "Select Event", date: Date(), colors: [.red, .blue])
            
            for event in try db.prepare(eventsTable.where(id == filterID)) {
                //convert string date to Date object
                let dateFormate = DateFormatter()
                dateFormate.dateFormat = "yyyy-MM-dd"
                let dateObject = dateFormate.date(from: "\(event[date])")
                
                //convert string to color
                let colorOneArray = event[color1].components(separatedBy: ",")
                let colorOne = Color(red: (colorOneArray[0] as NSString).doubleValue, green: (colorOneArray[1] as NSString).doubleValue, blue: (colorOneArray[2] as NSString).doubleValue)
                
                let colorTwoArray = event[color2].components(separatedBy: ",")
                let colorTwo = Color(red: (colorTwoArray[0] as NSString).doubleValue, green: (colorTwoArray[1] as NSString).doubleValue, blue: (colorTwoArray[2] as NSString).doubleValue)
                
                //add to temp and return
                temp = eventObject(name: "\(event[eventName])", date: dateObject!, colors: [colorOne, colorTwo], bgIMG: event[bgIMG], databaseID: event[id])
            }
            
            return temp
        } catch {
            print(error)
            return eventObject(name: "Select Event", date: Date(), colors: [.red, .blue])
        }
    }
    
    func addToDB(data: eventObject) -> Bool {
        do {
            let db = try Connection("\(path)/events.sqlite3")
                
            //convert date object to string
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "yyyy-MM-dd"
            let stringDate = dateFormate.string(from: data.date)
                
            //convert swiftUI color to string color array
            let colorString1 = "\(data.colors[0].components.red),\(data.colors[0].components.green),\(data.colors[0].components.blue)"
            //adds 0.1 to other string to stop same color error
            let colorString2 = "\(data.colors[1].components.red + 0.1),\(data.colors[1].components.green + 0.1),\(data.colors[1].components.blue + 0.1)"
                
            try db.run(eventsTable.insert(eventName <- data.name, date <- stringDate, color1 <- colorString1, color2 <- colorString2, bgIMG <- data.bgIMG ?? ""))
                
            return true
        } catch {
            return false
        }
    }
    
    func deleteEntry(idValue: Int64) -> Bool {
        do {
            let db = try Connection("\(path)/events.sqlite3")
            
            let event = eventsTable.filter(id == idValue)
            try db.run(event.delete())
            
            return true
        } catch {
            return false
        }
    }
    
    func updateEntry(idValue: Int64, data: eventObject) -> Bool {
        do {
            let db = try Connection("\(path)/events.sqlite3")
            
            //convert date object to string
            let dateFormate = DateFormatter()
            dateFormate.dateFormat = "yyyy-MM-dd"
            let stringDate = dateFormate.string(from: data.date)
                
            //convert swiftUI color to string color array
            let colorString1 = "\(data.colors[0].components.red),\(data.colors[0].components.green),\(data.colors[0].components.blue)"
            let colorString2 = "\(data.colors[1].components.red + 0.1),\(data.colors[1].components.green + 0.1),\(data.colors[1].components.blue + 0.1)"
            
            let event = eventsTable.filter(id == idValue)
            
            try db.run(event.update(eventName <- data.name, date <- stringDate, color1 <- colorString1, color2 <- colorString2, bgIMG <- data.bgIMG ?? ""))
            
            return true
        } catch {
            return false
        }
    }

}

class DateConverter {
    
    func DateToString(dateObject: Date, type: CounterTypeEnum) -> [String: String] {
        
        let startOfDay = Calendar(identifier: .gregorian).startOfDay(for: Date())
        
        let toDays = Calendar.current.dateComponents([.day], from: startOfDay, to: dateObject)
        let toMonth = Calendar.current.dateComponents([.month], from: startOfDay, to: dateObject)
        let toYear = Calendar.current.dateComponents([.year], from: startOfDay, to: dateObject)

        var returnResult = [String:String]()
        
        if (type == .dynamic || type == .binary || type == .unknown) {
            if toDays.day! > 99 {
                if toMonth.month! > 12 {
                    returnResult["value"] = String(toYear.year!)
                    returnResult["type"] = "Years"
                } else {
                    returnResult["value"] = String(toMonth.month!)
                    returnResult["type"] = "Months"
                }
            } else {
                returnResult["value"] = String(toDays.day!)
                returnResult["type"] = "Days"
            }
            
            if type == .binary {
                let num = Int(returnResult["value"]!)
                returnResult["value"] = String(num!, radix: 2)
            }
        } else {
            if type == .days {
                returnResult["value"] = String(toDays.day!)
                returnResult["type"] = "Days"
            }
            if type == .months {
                returnResult["value"] = String(toMonth.month!)
                returnResult["type"] = "Months"
            }
            if type == .years {
                returnResult["value"] = String(toYear.year!)
                returnResult["type"] = "Years"
            }
        }
        
        if (toDays.day! < 1) {
            if toDays.day! < 0 {
                returnResult["value"] = "🕒"
                returnResult["type"] = "Past"
            } else {
                returnResult["value"] = "🎉"
                returnResult["type"] = "Now"
            }
        }
        
        if (Int(returnResult["value"]!) == 1 && (returnResult["value"]! != "Past" || returnResult["value"]! != "Now")) {
            returnResult["type"]!.removeLast()
        }
        
        return returnResult
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }
}

///send data to apple watch
//class watchCom: NSObject, WCSessionDelegate {
//
//    var session: WCSession
//
//    init(session: WCSession = .default){
//        self.session = session
//        super.init()
//        session.delegate = self
//        session.activate()
//    }
//
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        #if os(iOS)
//        print("WC ession active - iPhone")
//        #endif
//
//        #if os(watchOS)
//        print("WC ession active - Apple Watch")
//        #endif
//    }
//
//    func session(_ session: WCSession, didReceive file: WCSessionFile) {
//        print("recevied file - \(file.fileURL.absoluteURL)")
//
//        databaseConnector().importCountDowns(file: file.fileURL.absoluteURL, doneProcessing: {_ in
//            print("imported data")
//        })
//    }
//
//    #if os(iOS)
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("Session now inactive")
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("Session has been deactivated")
//    }
//    #endif
//
//}
