//
//  GeminiResponse.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//
import Foundation

struct GeminiResponse: Decodable {
    let candidates: [Candidate]
}

struct Candidate: Decodable {
    let content: Content
}

struct Content: Decodable {
    let parts: [Part]
}

struct Part: Decodable {
    let text: String
}
