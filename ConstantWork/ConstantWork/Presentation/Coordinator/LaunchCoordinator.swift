//
//  LaunchCoordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/10.
//

import UIKit

protocol LaunchCoordinateDelegate: AnyObject {
    
    func moveToHome(with defaultData: [PiscumDataSource])
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
        let listManager: ListManager = .init(with: 1)
        let launchReactor: LaunchReactor = .init(with: listManager)
        let launchVC: LaunchViewController = .init(with: self)
        launchVC.reactor = launchReactor
        
        self.navigationController.navigationBar.isHidden = true
        self.childViewControllers.append(launchVC)
        
        self.navigationController.setViewControllers([launchVC], animated: false)
    }
}

extension LaunchCoordinator: LaunchCoordinateDelegate {
    
    func moveToHome(with defaultData: [PiscumDataSource]) {
        guard let sceneCoorDelegate = parentCoordinator as? SceneCoordinateDelegate else { return }
        
        sceneCoorDelegate.moveToHome(from: self, with: defaultData)
    }
}
