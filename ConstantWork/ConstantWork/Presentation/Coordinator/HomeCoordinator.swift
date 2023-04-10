//
//  HomeCoordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

protocol HomeCoordinateDelegate: AnyObject {
    
    func presentAlertVC(with message: String, completion: @escaping () -> ())
    func push(with imageData: Data)
    func pop(which viewController: UIViewController)
}

final class HomeCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var childViewControllers: [UIViewController] = []
    private let defaultData: [PiscumDataSource]
    
    init(_ navigation: UINavigationController, with parent: Coordinator, by defaultData: [PiscumDataSource]) {
        self.navigationController = navigation
        self.parentCoordinator = parent
        self.defaultData = defaultData
    }
    
    func start() {
        let listManager: ListManager = .init(with: 2)
        let homeReactor: HomeReactor = .init(with: listManager, from: defaultData)
        let homeVC: HomeViewController = .init(with: self)
        homeVC.reactor = homeReactor
        
        self.navigationController.navigationBar.isHidden = true
        self.navigationController.interactivePopGestureRecognizer?.isEnabled = false
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
    
    func push(with imageData: Data) {
        let detailVC: DetailViewController = .init(with: self, imageData: imageData)
        self.childViewControllers.append(detailVC)
        
        self.navigationController.pushViewController(detailVC, animated: true)
    }
    
    func pop(which viewController: UIViewController) {
        guard let index: Int = childViewControllers.firstIndex(of: viewController) else { return }
        
        self.navigationController.popViewController(animated: true)
        self.childViewControllers.remove(at: index)
    }
}
