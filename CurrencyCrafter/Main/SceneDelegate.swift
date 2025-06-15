//
//  SceneDelegate.swift
//  CurrencyCrafter
//
//  Created by Sajal Gupta on 12/10/24.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private var coordinator: Coordinator!

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)

    coordinator = createCoordinator()
    window.rootViewController = coordinator.navigationController

    self.window = window
    window.makeKeyAndVisible()
  }

  private func createCoordinator() -> Coordinator {
    let coordinator = MainCoordinator()
    coordinator.start()

    return coordinator
  }
}
