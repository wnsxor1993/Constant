//
//  SceneCoordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

final class SceneCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator? = nil
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(_ navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    func start() {
        let homeCoor: HomeCoordinator = .init(navigationController, with: self)
        self.childCoordinators.append(homeCoor)

        homeCoor.start()
    }
}
