//
//  ClarifyTextEditor.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import PDFKit

struct ClarifyTextEditor: View {
    private var isTextFocused: FocusState<Bool>.Binding
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showDocumentPicker = false
    @State private var documentWasProcessed: Bool = false
    @State private var selectedImage: UIImage?
    @State private var previewImage: UIImage?
    @State private var selectedPDFURL: URL?
    @Binding private var isLoading: Bool
    @Binding private var inputText: String
    @State private var documentExtracted: String = ""
    @State private var textEditorHeight: CGFloat = 40

    private var onAnalysisComplete: (MyMessages) -> Void
    
    let computerVision = ComputerVision()
    
    init(inputText: Binding<String>,
         isLoading: Binding<Bool>,
         isTextFocused: FocusState<Bool>.Binding,
         onAnalysisComplete: @escaping (MyMessages) -> Void) {
        
        _isLoading = isLoading
        _inputText = inputText
        self.isTextFocused = isTextFocused
        self.onAnalysisComplete = onAnalysisComplete
    }
    
    
    var body: some View {
        VStack {
            if let preview = previewImage {
                HStack {
                    ZStack(alignment: .center) {
                        Image(uiImage: preview)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 90)
                            .cornerRadius(4)
                        if !documentWasProcessed {
                            Color.black.opacity(0.5)
                                .scaledToFit()
                                .frame(width: 60, height: 90)
                                .cornerRadius(4)
                                    .onAppear {
                                        ProgressView().foregroundColor(.blue)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Anexo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(selectedPDFURL?.lastPathComponent ?? "Documento")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button("X") {
                        self.selectedPDFURL = nil
                        self.previewImage = nil
                        self.selectedImage = nil
                        self.documentWasProcessed = false
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            HStack {
                Menu {
                    Button("PDF") { self.showDocumentPicker = true }
                    Button("Galeria") { self.showImagePicker = true }
                    Button("Camera") { self.showCamera = true }
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding(10)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }.padding(.leading, 8)
                
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
                    
                    TextEditor(text: $inputText)
                        .focused(isTextFocused)
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
                        .overlay(alignment: .leading) {
                            if inputText.isEmpty {
                                Text("Digite sua nota ou termo médico")
                                    .foregroundColor(Color(.placeholderText))
                                    .font(.system(size: 14.0))
                                    .multilineTextAlignment(.leading)
                                    .allowsHitTesting(false)
                                    .padding(.leading, 8)
                            }
                        }
                    
                }
                .background(Color(.darkGray))
                .padding(.vertical, 8)
                
                if !inputText.isEmpty || self.documentWasProcessed {
                    Button {
                        guard isLoading == false else { return }
                        
                        let myMessage = MyMessages(
                            text: self.documentExtracted + inputText,
                            textToPreview: inputText,
                            previewImage: self.previewImage
                        )
                        
                        self.onAnalysisComplete(myMessage)
                        
                        self.inputText = ""
                        self.documentExtracted = ""
                        self.selectedPDFURL = nil
                        self.previewImage = nil
                        self.selectedImage = nil
                        self.documentWasProcessed = false
                        
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .padding(10)
                            .padding(.trailing, 8)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        
                    }
                    .padding(.trailing, 10)
                } else if inputText.isEmpty, self.isLoading {
                    ProgressView().padding(.trailing, 8)
                }
                
            }.sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showCamera) {
                CameraView(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedPDFURL: $selectedPDFURL)
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    self.documentWasProcessed = false
                    self.previewImage = image
                    computerVision.extractTextFromImage(image) { text in
                        self.documentWasProcessed = true
                        self.documentExtracted = text
                    }
                }
            }
            .onChange(of: selectedPDFURL) { pdf in
                if let newPDF = pdf {
                    self.documentWasProcessed = false
                    self.previewImage = getPDFThumbnail(from: newPDF)
                    if let text = computerVision.extractText(from: newPDF) {
                        self.documentWasProcessed = true
                        self.documentExtracted = text
                    }
                    newPDF.stopAccessingSecurityScopedResource()
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
    // Alterado para aceitar a URL do PDF
    @Binding var selectedPDFURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // AQUI: Usando apenas .pdf
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
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
            guard let url = urls.first else {
                parent.dismiss()
                return
            }
            
            _ = url.startAccessingSecurityScopedResource()
            
            parent.selectedPDFURL = url
            
            parent.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}


func getPDFThumbnail(from pdfURL: URL, size: CGSize = CGSize(width: 80, height: 120)) -> UIImage? {
    let isAccessing = pdfURL.startAccessingSecurityScopedResource()
    
    defer {
        if isAccessing {
            pdfURL.stopAccessingSecurityScopedResource()
        }
    }
    
    guard let pdfDocument = PDFDocument(url: pdfURL),
          let page = pdfDocument.page(at: 0) else {
        return nil
    }
    
    let thumbnail = page.thumbnail(of: size, for: .cropBox)
    
    return thumbnail
}
