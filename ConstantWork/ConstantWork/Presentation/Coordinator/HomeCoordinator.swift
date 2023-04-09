//
//  HomeCoordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

protocol HomeCoordinateDelegate: AnyObject {
    
    func presentAlertVC(with message: String, completion: @escaping () -> ())
}

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

extension HomeCoordinator: HomeCoordinateDelegate {
    
    func presentAlertVC(with message: String, completion: @escaping () -> ()) {
        let alertVC: UIAlertController = .init(title: "Notice", message: message, preferredStyle: .alert)
        let confirmAction: UIAlertAction = .init(title: "확인", style: .cancel) { _ in
            self.childViewControllers.removeLast()
            completion()
        }
        
        alertVC.addAction(confirmAction)
        
        self.childViewControllers.last?.present(alertVC, animated: true)
        self.childViewControllers.append(alertVC)
    }
}
