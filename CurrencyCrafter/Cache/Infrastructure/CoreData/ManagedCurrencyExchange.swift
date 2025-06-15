//
//  ManagedCurrencyExchange+CoreDataClass.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//
//

import Foundation
import CoreData

@objc(ManagedCurrencyExchange)
final class ManagedCurrencyExchange: NSManagedObject {
  
  @NSManaged var timestamp: Date
  @NSManaged var rates: NSSet

  var localRates: [String: Double] {
    return rates.compactMap { ($0 as? ManagedRates)?.local }.reduce([:]) { partialResult, dict in
      partialResult.merging(dict) { _, new in new }
    }
  }

  static func find(in context: NSManagedObjectContext) throws -> ManagedCurrencyExchange? {
    let request = NSFetchRequest<ManagedCurrencyExchange>(entityName: entity().name!)
    request.returnsObjectsAsFaults = false
    return try context.fetch(request).first
  }

  static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCurrencyExchange {
    try find(in: context).map(context.delete)
    return ManagedCurrencyExchange(context: context)
  }
}
