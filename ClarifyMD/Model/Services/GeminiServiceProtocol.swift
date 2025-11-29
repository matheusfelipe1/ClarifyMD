//
//  GeminiServiceProtocol.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import Foundation

public protocol GeminiServiceProtocol {
    func generateContent(prompt: String, completion: @escaping (Result<String, Error>) -> Void)
}
