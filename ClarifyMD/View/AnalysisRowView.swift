//
//  AnalysisRowView.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//
import AVFoundation
import SwiftUI
import Combine

struct AnalysisRowView: View {
    let analysis: TermAnalysis
    @State private var isExpanded = false
    @StateObject private var ttsService = TextToSpeechService()
    
    var body: some View {
        if analysis.term == "desconsiderar" {
            Text("Termo desconsiderado, não será analisado.")
                .font(.title3)
                .foregroundColor(.primary)
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let explanation = analysis.explanation {
                    HStack(spacing: 30) {
                        Button {
                            ttsService.read(text: explanation)
                        } label: {
                            Image(systemName: "play.circle.fill")
                            Text("Ler Texto")
                        }
                        .buttonStyle(.borderedProminent)
                        Button {
                            ttsService.stopReading()
                        } label: {
                            Image(systemName: "stop.circle.fill")
                            Text("Parar")
                        }
                        .buttonStyle(.bordered)
                    }
                    Text(renderMarkdown(explanation))
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                } else {
                    Text("Gerando explicação...")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            } label: {
                
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
            }
            .padding(.vertical, 4)
        }
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
    
    private func renderMarkdown(_ markdownString: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdownString)
        } catch {
            print("Erro ao parsear Markdown: \(error.localizedDescription)")
            return AttributedString(markdownString)
        }
    }
}




class TextToSpeechService: NSObject, ObservableObject {
    // O sintetizador é responsável por processar e reproduzir a fala
    private let synthesizer = AVSpeechSynthesizer()
    
    // Opcional: Adicionar um delegate para saber quando a fala termina
    override init() {
        super.init()
        // Opcionalmente, pode configurar o delegate aqui
        // synthesizer.delegate = self
    }

    func read(text: String, languageCode: String = "pt-BR") {
        do {
            // Define a categoria como .playback (reprodução),
            // que reproduz áudio mesmo quando o toque lateral do telefone está no modo silencioso.
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [] // Nenhuma opção específica é necessária
            )
            // Ativa a sessão de áudio
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("❌ Erro ao configurar a sessão de áudio para TTS: \(error.localizedDescription)")
        }
        // 1. Cria o enunciado (utterance) com o texto a ser lido
        let utterance = AVSpeechUtterance(string: text)
        
        // 2. Define a voz (opcional: escolha uma voz específica ou a padrão do idioma)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        
        // 3. Define a taxa de fala (velocidade)
        utterance.rate = 0.5 // Valor entre 0.0 (muito lento) e 1.0 (muito rápido), 0.5 é o padrão

        // 4. Define o tom (pitch)
        utterance.pitchMultiplier = 1.0 // Valor entre 0.5 e 2.0
        
        // 5. Inicia a leitura
        synthesizer.speak(utterance)
    }
    
    func stopReading() {
        // Interrompe imediatamente qualquer leitura em andamento
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // Opcional: pausar e resumir
    func pauseReading() {
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    func continueReading() {
        synthesizer.continueSpeaking()
    }
}
