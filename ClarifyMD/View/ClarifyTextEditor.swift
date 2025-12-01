//
//  ClarifyTextEditor.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import SwiftUI
import PhotosUI

struct ClarifyTextEditor: View {
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showDocumentPicker = false
    @State private var selectedImage: UIImage? {
        didSet {
                if let image = selectedImage {
                    computerVision.extractTextFromImage(image) { text in
                        onAnalysisComplete(text)
                    }
                }
            }
    }
    
    @Binding private var isLoading: Bool
    @Binding private var inputText: String
    @State private var textEditorHeight: CGFloat = 40

    private var onAnalysisComplete: (String) -> Void
    
    let computerVision = ComputerVision()
    
    init(inputText: Binding<String>, isLoading: Binding<Bool>, onAnalysisComplete: @escaping (String) -> Void) {
        _isLoading = isLoading
        _inputText = inputText
        self.onAnalysisComplete = onAnalysisComplete
    }
    
    
    var body: some View {
        HStack {
            Menu {
                Button("Tirar foto", action: { self.showCamera = true})
                Button("Galeria", action:  { self.showImagePicker = true })
                Button("PDF", action:  { self.showDocumentPicker = true })
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(10)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
                       .padding()
            ZStack(alignment: .topLeading) {
                Text(inputText)
                    .foregroundColor(.clear)
                    .background(GeometryReader { geometry in
                        Color(.darkGray)
                            .onAppear {
                                textEditorHeight = max(40, geometry.size.height)
                            }
                            .onChange(of: inputText) { _ in
                                textEditorHeight = max(40, geometry.size.height)
                            }
                    })
                    .padding(.top, 8)
                    .padding(.leading, 5)
                
                TextEditor(text: $inputText)
                    .foregroundColor(Color.white)
                    .scrollContentBackground(.hidden)
                    .background(Color(.darkGray))
                    .frame(height: textEditorHeight)
                    .background(GeometryReader { geometry in
                        Color(.darkGray)
                            .onAppear {
                                textEditorHeight = geometry.size.height
                            }
                    })
                    .overlay {
                        if inputText.isEmpty {
                            Text("Digite sua nota ou termo médico...")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.leading, 8)
                                .allowsHitTesting(false)
                        }
                    }
                
            }
            .background(Color(.darkGray))
            .padding(.vertical, 16)
                
            
            Button {
                guard isLoading == false else { return }
                self.onAnalysisComplete(inputText)
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .disabled(inputText.isEmpty)
            .padding(.trailing, 10)
            
        }.sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                computerVision.extractTextFromImage(image) { text in
                    onAnalysisComplete(text)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkGray), lineWidth: 1)
        )
        .background(Color(.darkGray))
        .clipShape(.buttonBorder)
        .padding(.all, 16)
        
       
    }
}


// MARK: Camera
    struct CameraView: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        @Environment(\.dismiss) private var dismiss
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .camera
            picker.allowsEditing = false
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: CameraView
            
            init(_ parent: CameraView) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                }
                parent.dismiss()
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.dismiss()
            }
        }
    }

// MARK: Galeria
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        @Environment(\.dismiss) private var dismiss
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                }
                parent.dismiss()
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.dismiss()
            }
        }
    }

    // MARK: Documentos de PDF
    struct DocumentPicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        @Environment(\.dismiss) private var dismiss
        
        func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image])
            picker.delegate = context.coordinator
            picker.allowsMultipleSelection = false
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIDocumentPickerDelegate {
            let parent: DocumentPicker
            
            init(_ parent: DocumentPicker) {
                self.parent = parent
            }
            
            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
                guard let url = urls.first else { return }
                
                // Aqui você pode processar o PDF ou imagem selecionada
                print("Documento selecionado: \(url)")
                
                // Se for uma imagem, você pode carregar
                if url.pathExtension.lowercased() == "jpg" ||
                   url.pathExtension.lowercased() == "jpeg" ||
                   url.pathExtension.lowercased() == "png" {
                    
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        parent.selectedImage = image
                    }
                }
                
                parent.dismiss()
            }
            
            func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
                parent.dismiss()
            }
        }
    }
