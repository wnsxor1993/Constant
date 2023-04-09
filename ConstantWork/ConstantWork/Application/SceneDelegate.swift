//
//  SceneDelegate.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var sceneCoordinator: Coordinator?
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        let navigation: UINavigationController = .init()
        
        self.sceneCoordinator = SceneCoordinator(navigation)
        self.sceneCoordinator?.start()
        
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
    }
}

