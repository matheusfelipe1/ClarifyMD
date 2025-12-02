//
//  ClarifyViewModel.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import Foundation
import Combine

// MARK: - TermAnalysis (Modelo de Apresentação)

struct TermAnalysis {
    let term: String
    var explanation: String?
    var verificationStatus: String?
}

// MARK: - ClarifyViewModel (Lógica da UI e do Pipeline)

class ClarifyViewModel: ObservableObject {
    
    @Published var terms: [TermAnalysis] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var myMessage: MyMessages = MyMessages(text: "", textToPreview: "", previewImage: nil)
    
    private let medicalAnalysisService: MedicalAnalysisService
    
    init(medicalAnalysisService: MedicalAnalysisService) {
        self.medicalAnalysisService = medicalAnalysisService
    }
    
    
    @MainActor
    func startAnalysis(with input: MyMessages) {
        self.terms = []
        self.errorMessage = nil
        self.isLoading = true
        self.myMessage = input
        
        self.medicalAnalysisService.identifierTermAnalysis(texto: input.text) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let identifiedTerms):
                    if identifiedTerms.isEmpty {
                        self.errorMessage = "Nenhum termo médico identificado. Por favor, reformule o texto."
                        self.isLoading = false
                        return
                    }
                    
                    self.terms = identifiedTerms.map { TermAnalysis(term: $0) }
                    
                    self.processTermsSequentially()
                    
                case .failure(let error):
                    self.errorMessage = "Erro ao identificar termos: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func processTermsSequentially() {
        let dispatchGroup = DispatchGroup()
        
        let termsToProcess = self.terms
        
        for (index, analysis) in termsToProcess.enumerated() {
            
            dispatchGroup.enter()
            
            self.medicalAnalysisService.generateExplanation(termo: analysis.term) { resultExplanation in
                
                var currentAnalysis = analysis
                
                switch resultExplanation {
                case .success(let explanation):
                    currentAnalysis.explanation = explanation
                    
                    self.medicalAnalysisService.checkAnswer(termo: analysis.term, explicacao: explanation) { resultVerification in
                        
                        DispatchQueue.main.async {
                            switch resultVerification {
                            case .success(let verification):
                                currentAnalysis.verificationStatus = verification
                                
                            case .failure(let error):
                                currentAnalysis.verificationStatus = "ERRO: Falha na Verificação."
                                print("Erro na verificação para \(analysis.term): \(error.localizedDescription)")
                            }
                            
                            self.terms[index] = currentAnalysis
                            dispatchGroup.leave()
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        currentAnalysis.explanation = "Erro ao gerar explicação."
                        currentAnalysis.verificationStatus = "ERRO"
                        self.terms[index] = currentAnalysis
                        self.errorMessage = "Falha ao processar termo '\(analysis.term)': \(error.localizedDescription)"
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            print("=== Processamento de todos os termos concluído ===")
        }
    }
}
