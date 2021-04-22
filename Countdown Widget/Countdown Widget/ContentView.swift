//
//  ContentView.swift
//  Countdown Widget
//
//  Created by Bradley Cable on 19/09/2020.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
//    var AppleWatchCom = watchCom()
    
    @State var events: [eventObject]
    
    @Environment(\.colorScheme) var colorScheme

    @State var updateList: Bool = false
    
    @State var infoScreen: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false, content: {
                if events.count < 1 {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(height: 100, alignment: .center)
                            .foregroundColor(.init(.sRGB, white: (colorScheme == .dark) ? 0.12: 0.92, opacity: 1))
                        
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .center) {
                                Text("No Events? 🥺")
                                    .bold()
                                    .font(.system(size: 25))
                                
                                Text("Create some with the button below")
                                    .fontWeight(.light)
                                    .font(.system(size: 15))
                            }
                            
                            Spacer()
                        }
                    }
                    .padding([.leading, .trailing])
                } else {
                    ForEach(events) { event in
                        NavigationLink(destination: addEvent(editModeData: event, updateList: $updateList)) {
                            CardView(event: event, updateList: $updateList)
                                .padding([.leading, .trailing])
                        }
                    }
                    .onDelete(perform: delete)
                }
                
                NavigationLink(destination: addEvent(editModeData: nil, updateList: $updateList)) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(height: 100, alignment: .center)
                            .foregroundColor(.init(.sRGB, white: (colorScheme == .dark) ? 0.12: 0.92, opacity: 1))
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Create An Event")
                                    .bold()
                                    .font(.system(size: 25))
                                    .foregroundColor(.primary)
                                
                                Text("Create here to create your custom countdown! 👍")
                                    .fontWeight(.light)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 55))
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                    .padding([.leading, .trailing])
                }
                
            })
            .navigationTitle("Countdown To...")
            .navigationBarItems(leading: EditButton(),
                                trailing:
                                    HStack {
                                            NavigationLink(destination: addEvent(editModeData: nil, updateList: $updateList)) {
                                                Image(systemName: "calendar.badge.plus")
                                                    .font(.title3)
                                            }
                                            .padding(.trailing, 6)

                                            NavigationLink(destination: settings(updateList: $updateList)) {
                                                Image(systemName: "gear")
                                                    .font(.title3)
                                            }
                                        })
        }
        .onChange(of: updateList) { changed in
            print("updated required")
            events = databaseConnector().fetchEvents() ?? events
        }
        .sheet(isPresented: $infoScreen, content: {
            infoScreenPopup(infoScreen: $infoScreen)
        })
        
        .onAppear() {
            if UserDefaults.standard.bool(forKey: "infoScreen") == false {
                infoScreen.toggle()
            }
            
//            if self.AppleWatchCom.session.isReachable {
//                self.AppleWatchCom.session.transferFile(URL(fileURLWithPath: "\(databaseConnector().path)/events.sqlite3"), metadata: nil)
//            }
        }
    }
    
    //list edit function
    func delete(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
    }

}

struct CardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.editMode) var mode
    
    @State var event: eventObject
    
    @State var stringDate: String = ""
    @State var bubblePreview: [String: String] = ["": ""]
    
    @Binding var updateList: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .frame(height: 100, alignment: .center)
                .foregroundColor(.init(.sRGB, white: (colorScheme == .dark) ? 0.12: 0.92, opacity: 1))
            
            HStack(alignment: .center) {
                
                ZStack {
                    if (event.bgIMG != "") {
                        let dataDecoded = Data(base64Encoded: event.bgIMG!, options: .ignoreUnknownCharacters)
                        
                        if (dataDecoded != nil) {
                            let decodedimage = Image(uiImage: UIImage(data: dataDecoded!)!)
                            
                            decodedimage
                                .resizable()
                                .clipShape(Circle())
                        }
                    } else {
                        if (event.colors[1] != event.colors[0]) {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [event.colors[0], event.colors[1]]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        } else {
                            //bug fix if user selects same colour
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
                    
                    VStack {
                        Text(bubblePreview["value"] ?? "--")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                                            
                        Text(bubblePreview["type"] ?? "-----")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .italic()
                            .offset(x: 0, y: -3)
                    }
                }
                .frame(width: 85, height: 85, alignment: .center)
                .shadow(radius: 3)
                .padding(8)
                
                VStack(alignment: .leading) {
                    Text(event.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text(stringDate)
                        .font(.subheadline)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                    
                }
                
                if self.mode?.wrappedValue == .active {
                    Spacer()
                    
                    Button(action: {
                        print("Deleted Event (\(event.databaseID!)) \(databaseConnector().deleteEntry(idValue: event.databaseID!))")
                        updateList.toggle()
                        
                        WidgetCenter.shared.reloadAllTimelines()
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 55))
                            .foregroundColor(.red)
                            .padding()
                    }
                } else {
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .onAppear() {
            let toString = DateFormatter()
            toString.dateStyle = .long
            stringDate = toString.string(from: event.date)
            
            bubblePreview = DateConverter().DateToString(dateObject: event.date, type: .dynamic)
        }
    }
}

struct infoScreenPopup: View {
    
    @Binding var infoScreen: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("CountDown")
                .font(.system(size: 50))
                .bold()
                .padding(.bottom, 25)
                .padding(.top)
            
            
            HStack(alignment: .center, spacing: 18, content: {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 78))
                    .gradientForeground(colors: [.blue,.white], startPoint: .topLeading, endPoint: .bottomTrailing)
                
                Text("Create countdown's to your favourite events, keeping track in them in a fun and personal way.")
                    .font(.title3)
                    .minimumScaleFactor(0.75)
            })
            .padding(.bottom, 22)
            
            HStack(alignment: .center, spacing: 18, content: {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 78))
                    .gradientForeground(colors: [.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                
                Text("Add your CountDown widget's directly to your home screen, then hold down and 'Edit Widget' to select the countdown you want.")
                    .font(.title3)
                    .minimumScaleFactor(0.75)
            })
            .padding(.bottom, 22)
            
            HStack(alignment: .center, spacing: 18, content: {
                Image(systemName: "timer")
                    .font(.system(size: 78))
                    .gradientForeground(colors: [.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                
                Text("Change how your CountDown is displayed on your widget: days, months, years or dynamic.")
                    .font(.title3)
                    .minimumScaleFactor(0.75)
            })
            .padding(.bottom, 22)

            
            HStack(alignment: .center, spacing: 18, content: {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 78))
                    .gradientForeground(colors: [.white,.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                
                Text("Personalise your countdown widget with a picture to make it even more personal.")
                    .font(.title3)
                    .minimumScaleFactor(0.75)
            })
            .padding(.bottom, 22)
            
            Spacer()
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "infoScreen")
                infoScreen.toggle()
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                    
                    Text("Continue")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                }
            })
        }
        .padding()
    }
}

extension View {
    public func gradientForeground(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
            .mask(self)
    }
}
