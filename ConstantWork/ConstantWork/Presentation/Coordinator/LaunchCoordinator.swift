//
//  LaunchCoordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/10.
//

import UIKit

protocol LaunchCoordinateDelegate: AnyObject {
    
    func moveToHome()
}

final class LaunchCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var childViewControllers: [UIViewController] = []
    
    init(_ navigation: UINavigationController, with parent: Coordinator) {
        self.navigationController = navigation
        self.parentCoordinator = parent
    }
    
    func start() {
        let launchVC: LaunchViewController = .init(with: self)
        
        self.navigationController.navigationBar.isHidden = true
        self.childViewControllers.append(launchVC)
        
        self.navigationController.setViewControllers([launchVC], animated: false)
    }
}

extension LaunchCoordinator: LaunchCoordinateDelegate {
    
    func moveToHome() {
        guard let sceneCoorDelegate = parentCoordinator as? SceneCoordinateDelegate else { return }
        
        sceneCoorDelegate.moveToHome(from: self)
    }
}
