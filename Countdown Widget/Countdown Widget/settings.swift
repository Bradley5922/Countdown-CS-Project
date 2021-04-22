//
//  settings.swift
//  Countdown Widget
//
//  Created by Bradley Cable on 21/11/2020.
//

import SwiftUI
import MessageUI
import SafariServices
import AVKit
import WidgetKit
import StoreKit

struct AlertItem: Identifiable {
    var id = UUID()
    var title = Text("")
    var message: Text?
    var dismissButton: Alert.Button? = nil
    var primaryButton: Alert.Button? = nil
    var secondaryButton: Alert.Button? = nil
}

struct settings: View {
    
    //update parent view
    @Binding var updateList: Bool
    @State var alertData: AlertItem?
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                ExportCountdowns()
                    .padding([.leading,.trailing])
                
                ImportCountdowns(updateList: $updateList, alertData: $alertData)
                    .padding([.leading,.trailing])
                
                Divider()
                
                ShowHowTo()
                    .padding([.leading,.trailing])
                
                Divider()
                
                ContactTheDev(alertData: $alertData)
                    .padding([.leading,.trailing])
                
                BuyMeACoffee()
                    .padding([.leading,.trailing])
                
                Divider()
                
                
            })
            DeleteDataButton(updateList: $updateList, alertData: $alertData)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Settings")
        
        .alert(item: $alertData) { data in
            if data.dismissButton != nil {
                return Alert(title: data.title, message: data.message!, dismissButton: data.dismissButton)
            } else {
                return Alert(title: data.title, message: data.message!, primaryButton: data.primaryButton!, secondaryButton: data.secondaryButton!)
            }
        }
    }
}

struct CDPremium: View {
    
    @State var startPurchase: Bool = false
    
    var body: some View {
        Button(action: {
            startPurchase.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray4))
                    .frame(height: 60, alignment: .center)
                
                HStack {
                    Text("Countdown ✨Premium✨")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        .sheet(isPresented: $startPurchase, content: {
            //
        })
    }
}

struct DeleteDataButton: View {
    
    @Binding var updateList: Bool
    @Binding var alertData: AlertItem?
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State var areYouSure: Bool = false
    
    var body: some View {
        Button(action: {
            print("Delete all CountDowns: \(databaseConnector().deleteEverything())")
            updateList.toggle()
            
            alertData = AlertItem(title: Text("Are you sure?"), message: Text("This action will delete all your countdowns, there is no undo."), dismissButton: nil, primaryButton: .destructive(Text("Delete"), action: {
                
                print("Delete all CountDowns: \(databaseConnector().deleteEverything())")
                updateList.toggle()
                
                self.mode.wrappedValue.dismiss()
                
                WidgetCenter.shared.reloadAllTimelines()
            }), secondaryButton: .cancel())
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.red)
                    .frame(height: 60, alignment: .center)
                
                HStack {
                    Text("Delete All Countdowns")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .italic()
                }
            }
        }
    }
}

struct ExportCountdowns: View {
    
    @State var saveFile: Bool = false
    
    let dbPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.widgetShareData.countdown")?.appendingPathComponent("events.sqlite3")
    
    var body: some View {
        Button(action: {
            saveFile.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray4))
                    .frame(height: 60, alignment: .center)
                
                HStack {
                    Text("Export CountDowns 📆")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        .sheet(isPresented: $saveFile, content: {
            ActivityViewController(activityItems: [dbPath!])
                .ignoresSafeArea(edges: .bottom)
        })
    }
}

struct ImportCountdowns: View {
    
    @Binding var updateList: Bool
    
    @State var fetchFile: Bool = false
    
    @State var fileURL: URL?
    
    @Binding var alertData: AlertItem?
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    let dbPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.widgetShareData.countdown")?.appendingPathComponent("events.sqlite3")
    
    var body: some View {
        Button(action: {
            fetchFile.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray4))
                    .frame(height: 60, alignment: .center)
                
                HStack {
                    Text("Import CountDowns 📲")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        
        .sheet(isPresented: $fetchFile, content: {
            FilePickerController(fileURL: $fileURL)
                .ignoresSafeArea(edges: .bottom)
        })
        
        .onChange(of: fileURL, perform: { path in
            databaseConnector().importCountDowns(file: path!) { done in
                if done {
                    updateList.toggle()
                    
                    alertData = AlertItem(title: Text("Import Successful"), message: Text("The app has imported your CountDowns successfully!"), dismissButton: .default(Text("Done"), action: {
                        
                        self.mode.wrappedValue.dismiss()
                        
                        WidgetCenter.shared.reloadAllTimelines()
                        
                    }), primaryButton: nil, secondaryButton: nil)
                    
                } else {
                    alertData = AlertItem(title: Text("Import Failed"), message: Text("Import has failed for some reason. If this keeps happening contact the developer at the support URL on the App Store."), dismissButton: .destructive(Text("Done"), action: {
                        
                        self.mode.wrappedValue.dismiss()
                        
                    }), primaryButton: nil, secondaryButton: nil)
                }
            }
        })
    }
}

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) { }

}

struct FilePickerController: UIViewControllerRepresentable {
    
    @Binding var fileURL: URL?

    func makeCoordinator() -> FilePickerController.Coordinator {
        return Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) { }

    func makeUIViewController(context: UIViewControllerRepresentableContext<FilePickerController>) -> UIDocumentPickerViewController {
        
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        
        controller.delegate = context.coordinator
        
        return controller
    }
}

extension FilePickerController {
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerController

        init(_ parent: FilePickerController) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.fileURL = urls[0]
        }
    }
}

struct ContactTheDev: View {
    
    @State var composeEmail: Bool = false
    
    @Binding var alertData: AlertItem?
    
    var body: some View {
        Button(action: {
            composeEmail.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray4))
                    .frame(height: 60, alignment: .center)
                
                HStack {
                    Text("Contact The Developer 👨‍💻")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        .sheet(isPresented: $composeEmail, content: {
            Email(alertData: $alertData)
                .ignoresSafeArea(edges: .bottom)
        })
    }
}

struct Email: UIViewControllerRepresentable {
    
    @Binding var alertData: AlertItem?

    func makeCoordinator() -> Email.Coordinator {
        return Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<Email>) { }

    func makeUIViewController(context: UIViewControllerRepresentableContext<Email>) -> MFMailComposeViewController {
        
        let view = MFMailComposeViewController()
        
        view.setSubject("CountDown Widget")
        view.setMessageBody("", isHTML: true)
        view.setToRecipients(["bradley5922@icloud.com"])
        
        view.mailComposeDelegate = context.coordinator
        
        return view
    }
}

extension Email {
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: Email

        init(_ parent: Email) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: {
                if result == .sent {
                    self.parent.alertData = AlertItem(title: Text("Thank You For The Email"), message: Text("Bradley will respond as quickly as he can 😊"), dismissButton: .default(Text("Done")))
                }
                print("email sent")
            })
        }
    }
}

struct BMACweb: UIViewControllerRepresentable {

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<BMACweb>) { }

    func makeUIViewController(context: UIViewControllerRepresentableContext<BMACweb>) -> SFSafariViewController {
        
        let view = SFSafariViewController(url: URL(string: "https://buymeacoff.ee/BradleyCable")!)
        view.dismissButtonStyle = .close
        
        return view
    }
}

struct BuyMeACoffee: View {
    
    @State var showWeb: Bool = false
    
    var body: some View {
        Button(action: {
            showWeb.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray4))
                    .frame(height: 60, alignment: .center)
                
                HStack {
                    Text("Buy Me A Coffee ☕️")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        .sheet(isPresented: $showWeb, content: {
            BMACweb()
                .ignoresSafeArea(edges: .bottom)
        })
    }
}

struct ShowHowTo: View {
    
    @State var showVideo: Bool = false
    let player = AVPlayer(url:  Bundle.main.url(forResource: "example", withExtension: "mp4")!)
    
    var body: some View {
        Button(action: {
            showVideo.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray4))
                    .frame(height: 60, alignment: .center)
                
                HStack {
                    Text("Widget How To 📺")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        .sheet(isPresented: $showVideo, content: {
            VideoPlayer(player: player)
                .onAppear() {
                    player.play()
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
        })
    }
}
