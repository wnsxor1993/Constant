//
//  CollectionLayout.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

struct CollectionLayout {
    
    enum LayoutCase {
        case home
    }
    
    func makeCompositionalLayout(which layoutCase: LayoutCase) -> UICollectionViewCompositionalLayout? {
        switch layoutCase {
        case .home:
            guard let collectionLayout = self.createHomeLayout() else { return nil }
            
            return .init(section: collectionLayout)
        }
    }
}

private extension CollectionLayout {
    
    func createHomeLayout() -> NSCollectionLayoutSection? {
        let itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(0.48), heightDimension: .fractionalWidth(0.3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.34))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1
        
        return section
    }
}
