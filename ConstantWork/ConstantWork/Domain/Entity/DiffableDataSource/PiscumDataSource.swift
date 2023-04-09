//
//  PiscumDataSource.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation

struct PiscumDataSource: Hashable {
    
    let id: String
    let width, height: Int
    let imageURL: URL
    var imageData: Data?
}
