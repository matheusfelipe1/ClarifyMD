//
//  GeminiClient.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//


// MARK: - GeminiService

import Foundation

class GeminiService: GeminiServiceProtocol {
    private let apiKey: String
    private let baseURL: String
    private let apiClient: APIClient
    private let environment = ProcessInfo.processInfo.environment
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        self.baseURL = environment["base_url"] ?? ""
        self.apiKey = environment["api_key"] ?? ""
    }
    
    func generateContent(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let geminiRequest = GeminiRequest(prompt: prompt)
        
        apiClient.performRequest(url: url, method: "POST", body: geminiRequest) { (result: Result<GeminiResponse, Error>) in
            
            switch result {
            case .success(let geminiResponse):
                if let text = geminiResponse.candidates.first?.content.parts.first?.text {
                    completion(.success(text))
                } else {
                    completion(.failure(APIError.emptyResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}



