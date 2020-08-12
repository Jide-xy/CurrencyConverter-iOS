//
//  LocalDatabase.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 12/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

protocol LocalDatabase {
    var ratesObservable: Observable<[RateEntity]> {get}
    func getRates() -> [RateEntity]
    func saveRates(rates: [RateEntity])
    func saveRate(rate: RateEntity)
}

class LocalDatabaseImpl: NSObject, LocalDatabase {
    var ratesObservable: Observable<[RateEntity]> {
        get{
            allRatesObservable.asObservable()
        }
    }
    
    private let viewContext: NSManagedObjectContext
    
    let persistentContainer: NSPersistentContainer
    lazy var controller: NSFetchedResultsController<RatesCoreData> = {
        let fetchRequest: NSFetchRequest = RatesCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "currencyCode", ascending: true)]
        let _controller = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try _controller.performFetch()
            _controller.delegate = self
        } catch {}
        return _controller
    }()
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        viewContext = persistentContainer.viewContext
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    lazy var allRatesObservable: BehaviorRelay<[RateEntity]> = {
        return BehaviorRelay<[RateEntity]>(value: getRates())
    }()
    
    func getRates() -> [RateEntity] {
        self.controller.fetchedObjects?.map{
            $0.toRateEntity()
        } ?? []
    }
    
    func saveRates(rates: [RateEntity]) {
        _ = rates.map{
            let entity = RatesCoreData.init(entity: RatesCoreData.entity(), insertInto: viewContext)
            entity.baseCurrencyCode = $0.baseCurrencyCode
            entity.currencyCode = $0.currencyCode
            entity.rate = $0.rate
        }
        do {
            //try viewContext.obtainPermanentIDs(for: Array(viewContext.insertedObjects))
            try viewContext.save()
        } catch {}
    }
    
    func saveRate(rate: RateEntity) {
        let entity = RatesCoreData.init(entity: RatesCoreData.entity(), insertInto: viewContext)
        entity.baseCurrencyCode = rate.baseCurrencyCode
        entity.currencyCode = rate.currencyCode
        entity.rate = rate.rate
        do {
            try viewContext.save()
        } catch {}
    }
}

extension LocalDatabaseImpl: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange: Any, at: IndexPath?, for: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let result = controller.fetchedObjects as? [RatesCoreData]{
            allRatesObservable.accept(result.map{ $0.toRateEntity()})
        }
        
    }

    
}
