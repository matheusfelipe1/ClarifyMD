//
//  ServiceLocator.swift
//  ClarifyMD
//
//  Created by Matheus Santos  on 29/11/25.
//

// MARK: - ServiceLocator.swift (Container de Dependências)

import Foundation

typealias Service = Any

class ServiceLocator {
    
    private lazy var services: [String: Service] = [:]
    private lazy var factories: [String: () -> Service] = [:]
    
    private func key<T>(for type: T.Type) -> String {
        return String(describing: type)
    }
    
    // MARK: - Registro (Configuração)
    
    func registerSingleton<T>(type: T.Type, service: T) {
        let key = self.key(for: type)
        services[key] = service
    }
    
    func registerFactory<T>(type: T.Type, factory: @escaping () -> T) {
        let key = self.key(for: type)
        factories[key] = factory
    }
    
    // MARK: - Resolução (Uso)
    
    func resolve<T>() -> T? {
        let key = self.key(for: T.self)
        
        print(services)
        
        if let service = services[key] as? T {
            return service
        }
        
        if let factory = factories[key] {
            let newService = factory()
            return newService as? T
        }
        
        return nil
    }
}
