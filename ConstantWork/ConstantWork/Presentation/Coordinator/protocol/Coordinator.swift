//
//  Coordinator.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var parentCoordinator: Coordinator? { get }
    var childCoordinators: [Coordinator] { get }
    var navigationController: UINavigationController { get set }
    
    func start()
}
