//
//  HTTPMethod.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation

enum HTTPMethod: String {
    
    case get

    var value: String {
        self.rawValue.uppercased()
    }
}
