//
//  UIView +.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

extension UIView {
    
    func addSubviews(with views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
