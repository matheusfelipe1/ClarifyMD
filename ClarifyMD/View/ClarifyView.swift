//
//  ClarifyView.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//
import SwiftUI


struct ClarifyView: View {
    
    @StateObject var viewModel: ClarifyViewModel
    @State private var inputText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextEditor(text: $inputText)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .padding()
                    .multilineTextAlignment(.leading)
                    .background(Color(.systemGray6))
                
                if viewModel.isLoading {
                    ProgressView("Analisando termos médicos...")
                        .padding()
                } else {
                    Button("Analisar Texto") {
                        viewModel.startAnalysis(with: inputText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(inputText.isEmpty)
                }

                Divider().padding(.vertical)
                if let error = viewModel.errorMessage {
                    Text("⚠️ Erro: \(error)")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                if !viewModel.terms.isEmpty {
                    List {
                        Text("Termos Identificados (\(viewModel.terms.count))")
                            .font(.headline)
                            .listRowSeparator(.hidden)
                        
                        ForEach(viewModel.terms, id: \.term) { analysis in
                            AnalysisRowView(analysis: analysis)
                        }
                    }
                    .listStyle(.plain)
                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                    ContentUnavailableView("Cole ou digite seu texto médico.",
                                           systemImage: "doc.text.magnifyingglass")
                }
            }
            .navigationTitle("ClarifyMD Analyser")
        }
    }
}
