//
//  MainCoordinator.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import UIKit
import CoreData

protocol Coordinator {
  var navigationController: UINavigationController { get }

  func start()
}

final class MainCoordinator: Coordinator {
  private(set) var navigationController: UINavigationController
  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()

  private lazy var store: ExchangeRateStore = {
    try! CoreDataExchangeRateStore(
      storeURL: NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("rate-store.sqlite"))
  }()

  private lazy var localLoader: LocalExchangeRateLoader = {
    LocalExchangeRateLoader(store: store, currentDate: Date.init)
  }()

  init() {
    navigationController = UINavigationController()
  }

  func start() {
    navigationController.viewControllers = [createMainViewController()]
  }

  // This method follows the Abstract Factory pattern to build and configure the necessary dependencies
  // for the CurrencyCrafterViewController. It creates both remote and local loaders, applies a caching
  // decorator, and returns the fully initialized view controller.

  // The caching logic follows a flexible composition pattern:
  // - The DefaultExchangeRateRepository requires the same type of loader for both its primary and fallback sources.
  // - In this configuration, the repository first tries to fetch data from the local cache.
  //   If the data isn't available locally, it falls back to the remote loader.
  // - The caching decorator ensures that any data fetched remotely is saved to the local cache
  //   for future use, minimizing unnecessary network calls.

  // This design is easy to modify:
  // - If future requirements change, we can switch the implementation to prioritize fetching from the remote loader first.
  //   If the remote fetch fails, the app can gracefully fall back to showing cached data.
  private func createMainViewController() -> UIViewController {
    // This URL will be refactored later. Due to time constraints, it is kept as-is for now.
      let remoteURL = URL(string: "https://openexchangerates.org/api/latest.json?app_id=dc55b7b16da240f3931c8c7796229eed")!
      let remoteLoader = RemoteExchangeRateLoader(url: remoteURL, client: httpClient)

      // Apply the caching decorator to the remote loader.
      let decorator = ExchangeRateLoaderCacheDecorator(
          decoratee: remoteLoader,
          cache: localLoader
      )

      // Set up the DefaultExchangeRateRepository to first try local loading.
      // If it fails, it uses the decorated remote loader as a fallback.
      let defaultExchangeRateRepository = DefaultExchangeRateRepository(
          primary: localLoader,
          fallback: decorator
      )

      // Create the view model with the repository as its loader.
      let viewModel = CurrencyCrafterViewModel(loader: defaultExchangeRateRepository)
      let viewController = CurrencyCrafterViewController(viewModel: viewModel)

      return viewController
  }
}
