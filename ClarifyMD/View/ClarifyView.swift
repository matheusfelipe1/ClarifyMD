//
//  ClarifyView.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//
import SwiftUI


struct ClarifyView: View {
    @State var input: String = ""
    @StateObject var viewModel: ClarifyViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Image("clarifyText")
            Spacer().frame(height: 24)
            if let error = viewModel.errorMessage, viewModel.terms.isEmpty {
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
            Spacer()
            
            Divider().padding(.vertical)

            ClarifyTextEditor(inputText: $input, isLoading: $viewModel.isLoading) {
                viewModel.startAnalysis(with: $0)
            }

        }
        .edgesIgnoringSafeArea(.top)
    }
}
