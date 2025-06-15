//
//  CoreDataHelpers.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import CoreData

extension NSPersistentContainer {

  enum LoadingError: Swift.Error {
          case modelNotFound
          case failedToLoadPersistenceStores(Swift.Error)
      }

  /// Loads a persistent container with a specified model and store URL.
  /// - Parameters:
  ///   - name: The name of the Core Data model.
  ///   - model: The managed object model.
  ///   - url: The URL for the persistent store.
  /// - Returns: A fully configured `NSPersistentContainer`.
  /// - Throws: An error if loading the persistent stores fails.
  static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
    let description = NSPersistentStoreDescription(url: url)
    let container = NSPersistentContainer(name: name, managedObjectModel: model)
    container.persistentStoreDescriptions = [description]

    var loadError: Swift.Error?
    container.loadPersistentStores { loadError = $1 }
    //try loadError.map { throw $0 }

    try loadError.map { throw LoadingError.failedToLoadPersistenceStores($0) }

    return container
  }
}

extension NSManagedObjectModel {
  /// Loads a managed object model from a specified bundle.
  /// - Parameters:
  ///   - name: The name of the Core Data model file (without extension).
  ///   - bundle: The bundle where the model is located.
  /// - Returns: An optional `NSManagedObjectModel`.
  static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
    return bundle
      .url(forResource: name, withExtension: "momd")
      .flatMap { NSManagedObjectModel(contentsOf: $0) }
  }
}

