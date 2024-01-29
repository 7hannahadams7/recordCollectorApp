//
//  ImagePicker.swift
//  test3
//
//  Created by Hannah Adams on 1/9/24.
//

import SwiftUI

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct ClearBackgroundViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .background(ClearBackgroundView())
    }
}

extension View {
    func clearModalBackground()->some View {
        self.modifier(ClearBackgroundViewModifier())
    }
}

struct PhotoSourceSelectionPopup: View {
    @Binding var isPhotoSourcePopupPresented: Bool
    var onLibrarySelected: () -> Void
    var onCameraSelected: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack{
//                Text("Choose Photo Source")
//                    .font(.headline)
//                    .padding(.bottom, 20)
                
                Button("Photo Library") {
                    onLibrarySelected()
                }
                .padding()
                .foregroundColor(decorBlack)
                .cornerRadius(8)
                Rectangle().frame(height:2).aspectRatio(contentMode: .fit).foregroundStyle(decorWhite)
                Button("Camera") {
                    onCameraSelected()
                }
                .padding()
                .foregroundColor(decorBlack)
                .cornerRadius(8)
                
            }.padding().frame(width:3*screenWidth/4).background(iconWhite).clipShape(RoundedRectangle(cornerRadius: 25.0))
            VStack{
                Button("Cancel") {
                    isPhotoSourcePopupPresented = false
                }
                .padding()
                .foregroundColor(pinkRed)
                .cornerRadius(8)
                
            }.padding().frame(width:3*screenWidth/4).background(decorWhite).clipShape(RoundedRectangle(cornerRadius: 25.0))
            
        }
        .padding().clearModalBackground()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var imageCallback: (UIImage?) -> Void

    enum SourceType {
        case camera
        case photoLibrary
    }

    var sourceType: SourceType

    func makeUIViewController(context: Context) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator

        switch sourceType {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }

        imagePicker.allowsEditing = true // Enable cropping
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var selectedImage: UIImage?

            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            }
            print("Finished picking")
            parent.imageCallback(selectedImage)
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("Finished picking")
            parent.isPresented = false
        }
    }
}
