//
//  ComputerVision.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import Vision
import UIKit


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
}
