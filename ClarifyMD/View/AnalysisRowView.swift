//
//  AnalysisRowView.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import SwiftUI

struct AnalysisRowView: View {
    let analysis: TermAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text("**\(analysis.term)**")
                    .font(.title3)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(statusText(for: analysis.verificationStatus))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: analysis.verificationStatus).opacity(0.2))
                    .foregroundColor(statusColor(for: analysis.verificationStatus))
                    .cornerRadius(6)
            }
            
            if let explanation = analysis.explanation {
                Text(explanation)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                Text("Gerando explicação...")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func statusColor(for status: String?) -> Color {
        guard let status = status else { return .gray }
        switch status.uppercased() {
        case "CORRETO": return .green
        case "AJUSTAR": return .orange
        case "INCORRETO", "ERRO": return .red
        default: return .gray
        }
    }
    
    private func statusText(for status: String?) -> String {
        guard let status = status else { return "Processando" }
        return status.uppercased()
    }
}
