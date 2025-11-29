//
//  GeminiRequest.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

struct GeminiRequest: Encodable {
    let contents: [[String: AnyEncodable]]
    let config: [String: String]?
    
    init(prompt: String) {
        self.contents = [
            ["role": AnyEncodable("user"), "parts": AnyEncodable([["text": AnyEncodable(prompt)]])]
        ]
        self.config = nil
    }
}
