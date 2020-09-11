//
//  RealmDatabase.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/09/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import RxSwift
import RxCocoa

class RealmDatabase: LocalDatabase{
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    var ratesRealm: Results<RateRealm>?
    var notificationToken: NotificationToken? = nil
    var notificationRunLoop: CFRunLoop? = nil
    
    init() {
        async {
            self.notificationRunLoop = CFRunLoopGetCurrent()
            CFRunLoopPerformBlock(self.notificationRunLoop, CFRunLoopMode.defaultMode.rawValue) {
                self.ratesRealm = self.realm.objects(RateRealm.self)
                self.notificationToken = self.ratesRealm!.observe { [weak self] (changes: RealmCollectionChange) in
                    if let ratesRealm = self?.ratesRealm{
                        self?.allRatesObservable.accept(ratesRealm.map{ $0.toRateEntity()})
                    }
                }
            }
            CFRunLoopRun()
        }
    }
    var ratesObservable: Observable<[RateEntity]> {
        get{
            allRatesObservable.asObservable()
        }
    }
    
    lazy var allRatesObservable: BehaviorRelay<[RateEntity]> = {
        return BehaviorRelay<[RateEntity]>(value: getRates())
    }()
    
    func getRates() -> [RateEntity]{
        return ratesRealm?.map{ $0.toRateEntity()} ?? []
    }
    func saveRates(rates: [RateEntity]){
        async {
            let realm = try! Realm()
            try! realm.write{
                realm.add(rates.map{
                    let record = RateRealm()
                    record.currencyCode = $0.currencyCode
                    record.baseCurrencyCode = $0.baseCurrencyCode
                    record.rate = $0.rate
                    return record
                }, update: .modified)
            }
            
        }
    }
    func saveRate(rate: RateEntity){
        async {
            try! self.realm.write{
                let record = RateRealm()
                record.currencyCode = rate.currencyCode
                record.baseCurrencyCode = rate.baseCurrencyCode
                record.rate = rate.rate
                self.realm.add(record, update: .modified)
            }
        }
    }
    
    
    func async(task: @escaping () -> Void){
        DispatchQueue.global(qos: .background).async {
            task()
        }
    }
    
    deinit {
        notificationToken?.invalidate()
        if let runloop = notificationRunLoop {
            CFRunLoopStop(runloop)
        }
    }
}
