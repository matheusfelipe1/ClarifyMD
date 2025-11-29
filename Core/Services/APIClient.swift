//
//  APIClient.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import Foundation


class APIClient {
    
    func performRequest<Request: Encodable, Response: Decodable>(
        url: URL,
        method: String,
        body: Request?,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            do {
                let data = try JSONEncoder().encode(body)
                request.httpBody = data
            } catch {
                completion(.failure(APIError.encodingError(error)))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                let responseString = String(data: data, encoding: .utf8) ?? "Erro desconhecido"
                completion(.failure(APIError.decodingError(responseString)))
            }
        }.resume()
    }
}


// MARK: - APIError
enum APIError: Error {
    case invalidURL
    case encodingError(Error)
    case decodingError(String)
    case noData
    case emptyResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "URL da API inválida."
        case .encodingError(let error): return "Erro ao codificar a requisição: \(error.localizedDescription)"
        case .decodingError(let rawResponse): return "Erro ao decodificar a resposta: \(rawResponse)"
        case .noData: return "Nenhum dado retornado pela API."
        case .emptyResponse: return "Resposta da API vazia ou inesperada."
        }
    }
}

// MARK: - AnyEncodable
struct AnyEncodable: Encodable {
    let value: Encodable
    
    init(_ value: Encodable) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

