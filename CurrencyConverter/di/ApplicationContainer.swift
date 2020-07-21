//
//  ApplicationContainer.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import Swinject
import CoreData

class ApplicationContainer{
    
    static func build(in container: Container, persistentContainer: NSPersistentContainer) {
        
        container.register(NSPersistentContainer.self){ _ in
            return persistentContainer
        }
        
        container.register(RatesService.self){ _ in
            return RatesServiceImpl()
        }
        
        container.register(LocalDatabase.self){ resolver in
            return LocalDatabaseImpl(persistentContainer: resolver.resolve(NSPersistentContainer.self)!)
        }
        
        container.register(RatesViewModel.self){ resolver in
            return RatesViewModel(repository: resolver.resolve(Repository.self)!)
        }
        
        container.register(Repository.self){ resolver in
            return RepositoryImpl(apiService: resolver.resolve(RatesService.self)!, localDB: resolver.resolve(LocalDatabase.self)!)
        }
    }
}
