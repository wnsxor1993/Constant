//
//  SnapShotService.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

struct SnapShotService {
    
    static func makeSnapShot<Section: Hashable, Item: Hashable>(with items: [Item], section: Section) -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot: NSDiffableDataSourceSnapshot<Section, Item> = .init()
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        
        return snapshot
    }
}
