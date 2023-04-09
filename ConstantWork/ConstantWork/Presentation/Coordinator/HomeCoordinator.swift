//
//  HomeCoordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

final class HomeCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var childViewControllers: [UIViewController] = []
    
    init(_ navigation: UINavigationController, with parent: Coordinator) {
        self.navigationController = navigation
        self.parentCoordinator = parent
    }
    
    func start() {
        let listManager: ListManager = .init()
        let homeReactor: HomeReactor = .init(with: listManager)
        let homeVC: HomeViewController = .init(with: self)
        homeVC.reactor = homeReactor
        
        self.navigationController.navigationBar.isHidden = true
        self.childViewControllers.append(homeVC)
        
        self.navigationController.setViewControllers([homeVC], animated: false)
    }
}