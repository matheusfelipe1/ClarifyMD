//
//  ComputerVision.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import Vision
import UIKit
import PDFKit

class ComputerVision{
    func extractTextFromImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Erro no reconhecimento: \(error)")
                completion("")
                return
            }
            
            var extractedText = ""
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                extractedText += topCandidate.string + "\n"
            }
            
            completion(extractedText)
        }
        
        // Configurações para melhor precisão
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["pt-BR", "en-US"] // Português e Inglês
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Erro ao processar imagem: \(error)")
                completion("")
            }
        }
    }
    
    func extractText(from pdfURL: URL) -> String? {
        // 1. Tentar criar um objeto PDFDocument a partir da URL
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            print("❌ Erro: Não foi possível carregar o documento PDF da URL.")
            return nil
        }
        
        let fullText = NSMutableString()
        
        // 2. Iterar por todas as páginas do documento
        for i in 0..<pdfDocument.pageCount {
            // Obter a página atual
            guard let pdfPage = pdfDocument.page(at: i) else {
                continue
            }
            
            // 3. Extrair o texto da página
            if let pageText = pdfPage.string {
                fullText.append(pageText)
                
                // Opcional: Adicionar uma quebra de linha ou separador entre as páginas
                fullText.append("\n\n--- Página \(i + 1) ---\n\n")
            }
        }
        
        // 4. Retornar a string completa
        return fullText as String
    }
}
