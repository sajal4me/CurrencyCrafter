//
//  ManagedRates+CoreDataClass.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//
//

import Foundation
import CoreData

@objc(ManagedRates)
final class ManagedRates: NSManagedObject {
  @NSManaged var currencyCode: String
  @NSManaged var exchangeRate: Double
  @NSManaged var exchange: ManagedCurrencyExchange

  var local: [String: Double] {
    return [currencyCode: exchangeRate]
  }

  static func rates(from localRates: LocalExchangeRates, in context: NSManagedObjectContext) -> NSSet {
    return NSSet(array: localRates.rates.map { (currencyCode, exchangeRate) in
      let managed = ManagedRates(context: context)
      managed.currencyCode = currencyCode
      managed.exchangeRate = exchangeRate
      return managed
    })
  }
}
