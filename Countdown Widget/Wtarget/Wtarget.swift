//
//  Wtarget.swift
//  Wtarget
//
//  Created by Bradley Cable on 19/09/2020.
//

import WidgetKit
import SwiftUI
import Intents

// Timeline entry that contains extra data
struct SingleEventTimelineEntry: TimelineEntry {
    public let date: Date // this is to conform to the protocol
    public let event: eventObject
    public var textColor: Color = .white
    public var counterType: CounterTypeEnum = .dynamic
}

struct SingleCountdownProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SingleEventTimelineEntry {
        return SingleEventTimelineEntry(date: Date(), event: eventObject(name: "Holiday 🌴", date: Date(timeIntervalSinceNow: 7884000), colors: [.red,.orange]), textColor: .white, counterType: .dynamic)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SingleEventTimelineEntry) -> Void) {
        let entry = SingleEventTimelineEntry(date: Date(), event: eventObject(name: "Holiday 🌴", date: Date(timeIntervalSinceNow: 7884000), colors: [.red,.orange]), textColor: .white, counterType: .dynamic)
        
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SingleEventTimelineEntry>) -> Void) {
        
        print("refresh")
        
        var eventData: eventObject
        
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
//        if configuration.CountdownChoice?.identifier == "Auto" {
//            let events = databaseConnector().fetchEvents() ?? [eventObject]()
//            let nextEventArray = Array(events.prefix(1))
//            eventData = nextEventArray[0]
//        } else {
//            let eventID = configuration.CountdownChoice?.identifier ?? "0"
//            eventData = databaseConnector().fetchEventsID(filterID: Int64(eventID) ?? 0)
//        }
        
        let eventID = configuration.CountdownChoice?.identifier ?? "0"
        eventData = databaseConnector().fetchEventsID(filterID: Int64(eventID) ?? 0)
        
        let widgetTextColor = textColorConvert(for: configuration)
        
        let entry = SingleEventTimelineEntry(date: Date(), event: eventData, textColor: widgetTextColor, counterType: configuration.CounterType)
        
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            
        completion(timeline)
    }
    
}

struct SingleCountdownView: View {
    var entry: SingleCountdownProvider.Entry
    
    var body: some View {
        ZStack {
            if (entry.event.colors[1] != entry.event.colors[0]) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(LinearGradient(gradient: Gradient(colors: [entry.event.colors[0], entry.event.colors[1]]), startPoint: .topLeading, endPoint: .bottomTrailing))
            } else {
                //bug fix if user selects same colour
                RoundedRectangle(cornerRadius: 0)
                    .fill(LinearGradient(gradient: Gradient(colors: [.red,.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            }
    
            if (entry.event.bgIMG != "") {
                let dataDecoded = Data(base64Encoded: entry.event.bgIMG!, options: .ignoreUnknownCharacters)
                
                if (dataDecoded != nil) {
                    let decodedimage = Image(uiImage: UIImage(data: dataDecoded!)!)
                    
                    ZStack {
                        decodedimage
                            .resizable()
                        
                    }
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    EventTitleView(entry: entry)
                    
                    EventCounterView(entry: entry)
                        
                    Spacer()
                        
                    EventDateView(entry: entry)
                }
                .padding(10)
                
                Spacer()
            }
        }
    }
}

struct EventTitleView: View {
    var entry: SingleEventTimelineEntry
    
    var body: some View {
        Text(entry.event.name)
            .font(.title2)
            .bold()
            .padding(2)
            .foregroundColor(entry.textColor)
            .lineLimit(2)
    }
}

struct EventCounterView: View {
    var entry: SingleEventTimelineEntry
    
    var body: some View {
        let dateStringData =  DateConverter().DateToString(dateObject: entry.event.date, type: entry.counterType)
        Text("\(dateStringData["value"] ?? "Error") \(dateStringData["type"] ?? "Contact Dev")")
            .font(.title3)
            .fontWeight(.light)
            .foregroundColor(entry.textColor)
    }
}

struct EventDateView: View {
    var entry: SingleEventTimelineEntry
    
    var body: some View {
        Text(dateToCalString(dateConvert: entry.event.date))
            .font(.subheadline)
            .fontWeight(.ultraLight)
            .foregroundColor(entry.textColor)
    }
    
    func dateToCalString(dateConvert: Date) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateStyle = .medium
        let stringDate = dateFormate.string(from: dateConvert)
        
        return stringDate
    }
}

func textColorConvert(for configuration: ConfigurationIntent) -> Color {
    switch configuration.TextColor {
        case .unknown: return Color.white
        case .white: return Color.white
        case .black: return Color.black
        case .blue: return Color.blue
        case .gray: return Color.gray
        case .green: return Color.green
        case .orange: return Color.orange
        case .pink: return Color.pink
        case .purple: return Color.purple
        case .red: return Color.red
        case .yellow: return Color.yellow
    }
}

struct MutiEventTimelineEntry: TimelineEntry {
    public let date: Date // this is to conform to the protocol
    public let events: [eventObject]
}

struct MutiCountdownProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (MutiEventTimelineEntry) -> Void) {
        let events: [eventObject] = [eventObject(id: UUID(), name: "Day Off", date: Date(timeIntervalSinceNow: 259200), colors: [.red,.orange], bgIMG: ""),
                                     eventObject(id: UUID(), name: "🍻🍸 W/ Jamie", date: Date(timeIntervalSinceNow: 1555000), colors: [.pink,.purple], bgIMG: ""),
                                     eventObject(id: UUID(), name: "School Exam", date: Date(timeIntervalSinceNow: 5256000), colors: [.blue,.green], bgIMG: ""),
                                     eventObject(id: UUID(), name: "Holiday 🌴", date: Date(timeIntervalSinceNow: 7884000), colors: [.yellow,.orange], bgIMG: "")]
        
        let entry = MutiEventTimelineEntry(date: Date(), events: events)
        
        completion(entry)
    }
    
    func placeholder(in context: Context) -> MutiEventTimelineEntry {
        let events: [eventObject] = [eventObject(id: UUID(), name: "Day Off", date: Date(timeIntervalSinceNow: 259200), colors: [.red,.orange], bgIMG: ""),
                                     eventObject(id: UUID(), name: "🍻🍸 W/ Jamie", date: Date(timeIntervalSinceNow: 1555000), colors: [.pink,.purple], bgIMG: ""),
                                     eventObject(id: UUID(), name: "School Exam", date: Date(timeIntervalSinceNow: 5256000), colors: [.blue,.green], bgIMG: ""),
                                     eventObject(id: UUID(), name: "Holiday 🌴", date: Date(timeIntervalSinceNow: 7884000), colors: [.yellow,.orange], bgIMG: "")]
        
        let entry = MutiEventTimelineEntry(date: Date(), events: events)
        
        return entry
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MutiEventTimelineEntry>) -> Void) {
        print("refresh")
        
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        let events = databaseConnector().fetchEvents() ?? [eventObject]()
        let topEvents = Array(events.prefix(8))
        
        let entry = MutiEventTimelineEntry(date: Date(), events: topEvents)
        
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            
        completion(timeline)
    }
    
}

struct MutiCountdownView: View {
    var entry: MutiEventTimelineEntry
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.widgetFamily) var widgetSize
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(.init(.sRGB, white: (colorScheme == .dark) ? 0.12: 0.92, opacity: 1))
            
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    if entry.events.indices.contains(0) { SubCountdownView(entry: entry, MutiEventID: 0, PaddingType: [.top, .leading]) } else { emptuSub(text: "No Events") }
                    if entry.events.indices.contains(2) { SubCountdownView(entry: entry, MutiEventID: 2, PaddingType: [.bottom, .leading]) } else { emptuSub(text: "") }
                    
                    if (widgetSize == .systemLarge) {
                        if entry.events.indices.contains(4) { SubCountdownView(entry: entry, MutiEventID: 4, PaddingType: [.top, .trailing]) } else { emptuSub(text: "") }
                        if entry.events.indices.contains(6) { SubCountdownView(entry: entry, MutiEventID: 6, PaddingType: [.top, .trailing]) } else { emptuSub(text: "") }
                    }
                }
                VStack(spacing: 0) {
                    if entry.events.indices.contains(1) { SubCountdownView(entry: entry, MutiEventID: 1, PaddingType: [.top, .trailing]) } else { emptuSub(text: "") }
                    if entry.events.indices.contains(3) { SubCountdownView(entry: entry, MutiEventID: 3, PaddingType: [.bottom, .trailing]) } else { emptuSub(text: "") }
                    
                    if (widgetSize == .systemLarge) {
                        if entry.events.indices.contains(5) { SubCountdownView(entry: entry, MutiEventID: 5, PaddingType: [.top, .trailing]) } else { emptuSub(text: "") }
                        if entry.events.indices.contains(7) { SubCountdownView(entry: entry, MutiEventID: 7, PaddingType: [.top, .trailing]) } else { emptuSub(text: "") }
                    }
                }
            }
        }
    }
}

struct emptuSub: View {
    
    var text: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.init(white: (colorScheme == .dark) ? 0.20: 0.84))
                .shadow(radius: 4)
                .padding(6)
            
            VStack(alignment: .center) {
                Text(text)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.black)
            }
        }
    }
}

struct SubCountdownView: View {
    var entry: MutiEventTimelineEntry
    var MutiEventID: Int
    var PaddingType: Edge.Set
    
    var body: some View {
        ZStack {
            if (entry.events[MutiEventID].colors[0] != entry.events[MutiEventID].colors[1]) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(gradient: Gradient(colors: [entry.events[MutiEventID].colors[0], entry.events[MutiEventID].colors[1]]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 4)
                    .padding(6)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(gradient: Gradient(colors: [.red,.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 4)
                    .padding(6)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(entry.events[MutiEventID].name)
                        .font(.headline)
                        .bold()
                        .lineLimit(1)
                        .foregroundColor(.white)
                    
                    let dateStringData =  DateConverter().DateToString(dateObject: entry.events[MutiEventID].date, type: .dynamic)
                    Text("\(dateStringData["value"] ?? "") \(dateStringData["type"] ?? "")")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.white)
                    
                }
                .padding(12)

                
                Spacer()
            }
        }
    }
}

struct SingleCountdownWidget: Widget {
    private let kind: String = "Single Countdown Widget"

    public var body: some WidgetConfiguration {
            IntentConfiguration(kind: kind, intent: ConfigurationIntent.self,
                                provider: SingleCountdownProvider()) { entry in
                SingleCountdownView(entry: entry)
            }
            .configurationDisplayName("Single Countdown")
            .description("Display a single countdown")
            .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct MutiCountdownWidget: Widget {
    private let kind: String = "Muti Countdown Widget"

    public var body: some WidgetConfiguration {
            StaticConfiguration(kind: kind, provider: MutiCountdownProvider()) { entry in
                MutiCountdownView(entry: entry)
            }
            .configurationDisplayName("Muti-Countdown")
            .description("See top four upcoming events all in one place (beta)")
            .supportedFamilies([.systemMedium, .systemLarge])
    }
}


@main
struct CountdownWidgets: WidgetBundle {
    var body: some Widget {
        SingleCountdownWidget()
//        MutiCountdownWidget()
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MutiCountdownView(entry: MutiEventTimelineEntry(date: Date(), events: [eventObject(id: UUID(), name: "Day Off", date: Date(timeIntervalSinceNow: 259200), colors: [.red,.orange], bgIMG: ""),
                                                                               eventObject(id: UUID(), name: "🍻🍸 W/ Jamie", date: Date(timeIntervalSinceNow: 1555000), colors: [.pink,.purple], bgIMG: ""),
                                                                               eventObject(id: UUID(), name: "School Exam", date: Date(timeIntervalSinceNow: 5256000), colors: [.blue,.green], bgIMG: ""),
                                                                               eventObject(id: UUID(), name: "Holiday 🌴", date: Date(timeIntervalSinceNow: 7884000), colors: [.yellow,.orange], bgIMG: "")]))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
