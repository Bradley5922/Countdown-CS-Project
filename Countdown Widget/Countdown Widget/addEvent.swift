//
//  addEvent.swift
//  Countdown Widget
//
//  Created by Bradley Cable on 19/09/2020.
//

import SwiftUI
import WidgetKit

struct addEvent: View {
    
    //edit mode stuff
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var editModeData: eventObject?
    @State var editMode: Bool = false
    @State var databaseID: Int64 = 0
    
    //data the user picks
    @State private var datePicked = Date()
    @State private var color1 = Color.gray
    @State private var color2 = Color.primary
    @State private var eventTitle: String = ""
    @State private var pickedPhotoData: String = ""
    
    //update parent view
    @Binding var updateList: Bool
    
    //staged event creation
    @State var creationStage: Int = 0

    var body: some View {
        VStack(alignment: .center) {
            if creationStage == 0 {
                TitleEvent(text: $eventTitle)
    
                DatePickerCell(datePicked: $datePicked)
            } else {
                DateCircle(color1: $color1, color2: $color2, pickedPhotoData: $pickedPhotoData, datePicked: $datePicked)
                
                ColorPickerCell(color1: $color1, color2: $color2)
                
                Picture(pickedPhotoData: $pickedPhotoData)
            }
                
            Spacer()
            
            loadingBar(creationStage: $creationStage, editMode: $editMode)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            
            Button(action: {
                if creationStage == 1 {
                    if eventTitle == "" {
                        eventTitle = "Untitled Event"
                    }
                    
                    if editMode {
                        print("Update event (ID): \(databaseID)")
                        
                        if databaseConnector().updateEntry(idValue: databaseID, data: eventObject(name: eventTitle, date: datePicked, colors: [color1, color2], bgIMG: pickedPhotoData)) {
                            
                            updateList.toggle()
                            self.presentationMode.wrappedValue.dismiss()
                            print("updated successfully")
                            
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    } else {
                        if databaseConnector().addToDB(data: eventObject(name: eventTitle, date: datePicked, colors: [color1, color2], bgIMG: pickedPhotoData)) {
                            
                            updateList.toggle()
                            self.presentationMode.wrappedValue.dismiss()
                            
                            print("event added")
                            
                            WidgetCenter.shared.reloadAllTimelines()
                            
                            //MARK: Where add is toggled
                            
                        }
                        
                    }
                } else {
                    creationStage = 1
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(editMode ? .yellow: .green)
                        .frame(height: 60, alignment: .center)
                    
                    HStack {
                        if creationStage == 1 {
                            Text(editMode ? "Finish Edting": "Create Event")
                                .foregroundColor(.white)
                                .font(.title)
                        } else {
                            Text(editMode ? "Continue Edit": "Continue Creation")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                    }
                    .animation(.none)
                }
                .padding([.bottom,.leading,.trailing])
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .navigationBarTitle((eventTitle == "") ? "Create An Event": eventTitle)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                    Button(action: {
                        if creationStage == 0 {
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            creationStage = 0
                        }
                    }) {
                        HStack(alignment: .center, spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                            Text("Back")
                        }
                })
        .onAppear() {
            if editModeData != nil {
                editMode.toggle()
                
                eventTitle = "\(editModeData!.name)"
                datePicked = editModeData!.date
                color1 = editModeData!.colors[0]
                color2 = editModeData!.colors[1]
                databaseID = editModeData!.databaseID!
                pickedPhotoData = editModeData?.bgIMG ?? ""
                
                editModeData = nil
            }
        }
        .animation(.default)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct TitleEvent: View {
    
    @State var enableEdit: Bool = false
    @Binding var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(.systemGray5))
                .frame(height: 58, alignment: .center)
                
            HStack {
                TextField("Tap To Edit Event Name", text: $text)
                    .padding(.leading, 10)
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
            }
        }
        .padding([.trailing, .leading])
    }
    
    func limitText(_ upper: Int) {
        if text.count > upper {
            text = String(text.prefix(upper))
        }
    }
}

struct loadingBar: View {
    
    @Binding var creationStage: Int
    @Binding var editMode: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< 2) { index in
                Rectangle()
                    .foregroundColor(index < (creationStage + 1) ? (editMode ? .yellow: .green) : Color(.systemGray6))
            }
        }
        .frame(maxHeight: 10)
        .clipShape(Capsule())
        .padding([.leading, .trailing])
        .padding([.bottom], 4)
    }
}

struct DateCircle: View {
    
    @Binding var color1: Color
    @Binding var color2: Color
    
    @Binding var pickedPhotoData: String
    
    @Binding var datePicked: Date
    
    @State private var isAnimating = false
    
    @State var countdownInfo: [String: String] = ["": ""]
    
    var body: some View {
        ZStack {
            if (pickedPhotoData != "") {
                let dataDecoded = Data(base64Encoded: pickedPhotoData, options: .ignoreUnknownCharacters)
                
                if (dataDecoded != nil) {
                    let decodedimage = Image(uiImage: UIImage(data: dataDecoded!)!)
                    
                    decodedimage
                        .resizable()
                        .clipShape(Circle())
                }
            } else {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                    .animation(self.isAnimating ? Animation.linear(duration: 12).repeatForever(autoreverses: false) : .linear)
                                    .onAppear { self.isAnimating = true }
            }
            
            VStack {
                Text(countdownInfo["value"] ?? "--")
                    .font(.system(size: 80))
                    .bold()
                    .foregroundColor(.white)
                                    
                Text(countdownInfo["type"] ?? "Preview")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .italic()
                    .offset(x: 0, y: -3)
            }
            .animation(.none)
        }
        .frame(width: 225, height: 225, alignment: .center)
        .padding()
        .shadow(radius: 8)
        
        .onAppear() {
            countdownInfo = DateConverter().DateToString(dateObject: datePicked, type: .dynamic)
        }
    }
}

struct DatePickerCell: View {
    
    @Binding var datePicked: Date
    
    var body: some View {
        ZStack { // Z Axis (bottom to top)
            // rounded rec for base
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(.systemGray5))
                // systemGrey means it changes with state (dark / light mode)
                .frame(height: 58, alignment: .center)
                
            HStack { // H Axis (left to right)
                Text("Select A Date")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                // Text on the left describing what thing is for
                    
                Spacer()
                // gap
                    
                DatePicker(selection: $datePicked, in: Date()..., displayedComponents: .date) {}
                    .padding(.trailing, 10)
                // Swift UI built in date picker
            }
        }
        .padding([.trailing, .leading])
    }
}

struct ColorPickerCell: View {
    
    @Binding var color1: Color
    @Binding var color2: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(.systemGray5))
                .frame(height: 58, alignment: .center)
                        
            HStack {
                Text("Primary Colour")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
            
                            
                ColorPicker("", selection: $color1, supportsOpacity: false)
                    .padding(.trailing, 10)
            }
        }
        .padding([.trailing, .leading])
        
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(.systemGray5))
                .frame(height: 58, alignment: .center)
                        
            HStack {
                Text("Second Colour")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
            
                            
                ColorPicker("", selection: $color2, supportsOpacity: false)
                    .padding(.trailing, 10)
            }
        }
        .padding([.trailing, .leading])
    }
}

//Change background picture
struct Picture: View {
    
    @State private var showImagePicker: Bool = false
    
    @Binding var pickedPhotoData: String
    
    var body: some View {
        
        Button(action: {
            //clicked change image button
            if pickedPhotoData == "" {
                showImagePicker.toggle()
            } else {
                pickedPhotoData = ""
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color(.systemGray5))
                    .frame(height: 58, alignment: .center)
                            
                HStack {
                    Text("Background Image")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    if pickedPhotoData == "" {
                        Image(systemName: "photo")
                            .padding(.trailing, 10)
                            .font(.title3)
                    } else {
                        Image(systemName: "trash")
                            .padding(.trailing, 10)
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding([.trailing, .leading])
        }
        //show image picker, ether camera roll or camera depending on action sheet
        .sheet(isPresented: $showImagePicker, content: {
            ImagePicker(pickedPhotoData: $pickedPhotoData, isShowingPicker: $showImagePicker)
        })
    }
}

//The image picker it self
struct ImagePicker : UIViewControllerRepresentable {
    
    @Binding var pickedPhotoData: String
    
    @Binding var isShowingPicker: Bool
    
    var sourceSelected: UIImagePickerController.SourceType = .photoLibrary
    
    func makeCoordinator() -> ImagePickerCordinator {
        return ImagePickerCordinator(isShowingPicker: $isShowingPicker, pickedPhotoData: _pickedPhotoData)
       }
    
    //Image picker is only UIKit not SwiftUI therefore need to use
    //UIViewControllerRepresentable
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        
        picker.sourceType = sourceSelected
        
        return picker
   }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //not needed but protocol so required anyway
    }
}

class ImagePickerCordinator : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @Binding var pickedPhotoData: String
    
    @Binding var isShowingPicker: Bool
    
    init(isShowingPicker : Binding<Bool>, pickedPhotoData: Binding<String>) {
            _isShowingPicker = isShowingPicker
            _pickedPhotoData = pickedPhotoData
    }

    //Selected Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        let imageData = imageSelected.pngData()
        let strBase64 = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        self.pickedPhotoData = strBase64
    
        self.isShowingPicker = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShowingPicker = false
    }
}

//struct addEvent_Previews: PreviewProvider {
//    static var previews: some View {
//        addEvent(updateList: $updateList)
//    }
//}
