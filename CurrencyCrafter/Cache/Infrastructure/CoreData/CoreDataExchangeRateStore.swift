//
//  CoreDataExchangeRateStore.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import CoreData

/// CoreData-based implementation of the ExchangeRateStore protocol.
/// This class manages the lifecycle of the Core Data stack and provides methods to execute operations
/// such as inserting, retrieving, and deleting exchange rate data in a background context.
final class CoreDataExchangeRateStore {
  private static let modelName = "ExchangeRateStore"
  private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataExchangeRateStore.self))

  private let container: NSPersistentContainer
  private let context: NSManagedObjectContext

  enum StoreError: Error {
    case modelNotFound
    case failedToLoadPersistentContainer(Error)
  }

  /// Initializes the CoreDataExchangeRateStore with a store URL.
  /// - Parameter storeURL: The location where the persistent store will be saved.
  /// - Throws: `StoreError` if the model is not found or the container fails to load.
  init(storeURL: URL) throws {
    guard let model = CoreDataExchangeRateStore.model else {
      throw StoreError.modelNotFound
    }
    do {
      container = try NSPersistentContainer.load(name: CoreDataExchangeRateStore.modelName, model: model, url: storeURL)
      context = container.newBackgroundContext()
    } catch {
      throw StoreError.failedToLoadPersistentContainer(error)
    }
  }

  /// Executes a given action in the store's background context.
  /// - Parameter action: A closure containing Core Data operations.
  func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
    let context = self.context
    context.perform { action(context) }
  }
}


