//
//  ClarifyView.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//
import SwiftUI


struct ClarifyView: View {
    @FocusState private var isTextFieldFocused: Bool
    @State var input: String = ""
    @StateObject var viewModel: ClarifyViewModel
    
    var body: some View {
            VStack(spacing: 0) {
                Image("clarifyText")
                Spacer().frame(height: 8)
                if let error = viewModel.errorMessage, viewModel.terms.isEmpty {
                    Text("⚠️ Erro: \(error)")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    
                }
                ZStack {
                    VStack(spacing: 0) {
                        
                    if !viewModel.terms.isEmpty {
                        List {
                            HStack {
                                Spacer()
                                VStack {
                                    if viewModel.myMessage.previewImage != nil {
                                        Image(uiImage: viewModel.myMessage.previewImage!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 200)
                                            .cornerRadius(4)
                                        Spacer().frame(height: 16)
                                    }
                                    
                                    Text(viewModel.myMessage.textToPreview)
                                        .font(.headline)
                                        .listRowSeparator(.hidden)
                                    
                                }.padding(16)
                                    .background(Color.blue)
                                    .cornerRadius(16)
                            }
                            
                            Text("Termos Identificados (\(viewModel.terms.count))")
                                .font(.headline)
                                .listRowSeparator(.hidden)
                            
                            ForEach(viewModel.terms, id: \.term) { analysis in
                                AnalysisRowView(analysis: analysis)                        }
                        }
                        .listStyle(.plain)
                    } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                        ContentUnavailableView("Cole ou digite seu texto médico.",
                                               systemImage: "doc.text.magnifyingglass")
                    }
                    Spacer()
                }
                
                if isTextFieldFocused {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.isTextFieldFocused = false
                        }
                }
            }
                
                Divider().padding(.vertical)
                
                ClarifyTextEditor(
                    inputText: $input,
                    isLoading: $viewModel.isLoading,
                    isTextFocused: $isTextFieldFocused
                ) { myMessage in
                    
                    viewModel.startAnalysis(with: myMessage)
                }
                
            }
            .edgesIgnoringSafeArea(.top)
            
    }
}


struct MyMessages {
    let text: String
    let textToPreview: String
    let previewImage: UIImage?
}
