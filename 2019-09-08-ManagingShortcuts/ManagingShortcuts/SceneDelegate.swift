//
//  SceneDelegate.swift
//  CoreData+DiffableDataSource
//
//  Created by Julian Schiavo on 24/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let navController = UINavigationController(rootViewController: AllShortcutsViewController())
        navController.navigationBar.prefersLargeTitles = true
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }

}

