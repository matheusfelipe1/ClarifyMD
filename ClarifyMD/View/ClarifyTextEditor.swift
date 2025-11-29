//
//  ClarifyTextEditor.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import SwiftUI

struct ClarifyTextEditor: View {
    @Binding private var isLoading: Bool
    @Binding private var inputText: String
    @State private var textEditorHeight: CGFloat = 40

    private var onAnalysisComplete: (String) -> Void
    
    init(inputText: Binding<String>, isLoading: Binding<Bool>, onAnalysisComplete: @escaping (String) -> Void) {
        _isLoading = isLoading
        _inputText = inputText
        self.onAnalysisComplete = onAnalysisComplete
    }
    
    
    var body: some View {
        HStack {
            Button {
                guard isLoading == false else { return }
                self.onAnalysisComplete(inputText)
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding(10)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
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
