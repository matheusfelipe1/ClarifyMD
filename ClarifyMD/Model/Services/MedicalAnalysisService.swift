//
//  MedicalAnalysisService.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import Foundation

class MedicalAnalysisService {
    
    private let geminiService: GeminiServiceProtocol
    
    init(geminiService: GeminiServiceProtocol) {
        self.geminiService = geminiService
    }
    
    
    func identifierTermAnalysis(texto: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let prompt = """
        Analise este texto e extraia os termos médicos principais: "\(texto)"
        Liste APENAS os termos separados por vírgula.
        Ressalto: Caso não houver um termo MEDICINAL TÉCNICO. Por favor, desconsiderar o envio do prompt
        Ressalto: Isso prompt é para analizar APENAS laudo médico, e o que não laudo médico, e até mesmo palavras soltas, por favor, desconsiderar o envio do prompt
        Resposta:
        """
        
        geminiService.generateContent(prompt: prompt) { result in
            switch result {
            case .success(let responseText):
                let termos = responseText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                completion(.success(termos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func generateExplanation(termo: String, completion: @escaping (Result<String, Error>) -> Void) {
        let prompt = """
        Aja como um médico experiente e didático. Explique o termo médico "\(termo)"
        para um paciente leigo de forma clara, simples e empática.
        
        Inclua:
        1. Definição simples
        2. Causas comuns (se aplicável)
        3. Importância para a saúde
        4. Um aviso: "Esta é uma explicação geral. Sempre siga as orientações do seu médico."
        
        Resposta:
        """
        
        geminiService.generateContent(prompt: prompt, completion: completion)
    }

    func checkAnswer(termo: String, explicacao: String, completion: @escaping (Result<String, Error>) -> Void) {
        let prompt = """
        Verifique se esta explicação médica está correta:
        
        Termo: \(termo)
        Explicação: \(explicacao)
        
        Responda APENAS com:
        - "CORRETO" se a explicação estiver precisa
        - "INCORRETO" se houver erros graves
        - "AJUSTAR" se precisar de pequenos ajustes
        
        Avaliação:
        """
        
        geminiService.generateContent(prompt: prompt) { result in
            switch result {
            case .success(let verification):
                completion(.success(verification.trimmingCharacters(in: .whitespacesAndNewlines)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
