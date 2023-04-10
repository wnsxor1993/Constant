//
//  SceneCoordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

protocol SceneCoordinateDelegate: AnyObject {
    
    func moveToHome(from coor: Coordinator, with defaultData: [PiscumDataSource])
}

final class SceneCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator? = nil
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(_ navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    func start() {
        let launchCoor: LaunchCoordinator = .init(navigationController, with: self)
        self.childCoordinators.append(launchCoor)

        launchCoor.start()
    }
}

extension SceneCoordinator: SceneCoordinateDelegate {
    
    func moveToHome(from coor: Coordinator, with defaultData: [PiscumDataSource]) {
        let homeCoor: HomeCoordinator = .init(navigationController, with: self, by: defaultData)
        homeCoor.start()
        
        self.childCoordinators.append(homeCoor)
        self.remove(which: coor)
    }
}

private extension SceneCoordinator {
    
    func remove(which coordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: { coor in
            return coor === coordinator
        }) else { return }
        
        self.childCoordinators.remove(at: index)
    }
}
