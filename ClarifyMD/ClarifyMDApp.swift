//
//  ClarifyMDApp.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

import SwiftUI

@main
struct ClarifyMDApp: App {
    
    let serviceLocator = ServiceLocator()
    
    func registerDependencies() {
        serviceLocator.registerSingleton(type: APIClient.self, service: APIClient())
        
        serviceLocator.registerSingleton(
            type: GeminiServiceProtocol.self,
            service: GeminiService(apiClient: serviceLocator.resolve()!)
        )
        
        serviceLocator.registerSingleton(
            type: MedicalAnalysisService.self,
            service: MedicalAnalysisService(geminiService: serviceLocator.resolve()!)
        )
        
        serviceLocator.registerFactory(type: ClarifyViewModel.self) {
            let analysisService: MedicalAnalysisService = self.serviceLocator.resolve()!
            return ClarifyViewModel(medicalAnalysisService: analysisService)
        }
    }
    
    init() {
        self.registerDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ClarifyView(
                viewModel: serviceLocator.resolve()!
            ).preferredColorScheme(.dark)
        }
    }
}
