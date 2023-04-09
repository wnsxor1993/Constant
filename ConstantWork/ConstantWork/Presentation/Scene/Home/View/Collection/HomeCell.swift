//
//  HomeCell.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit
import Then
import SnapKit

final class HomeCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "HomeCell"
    
    private let cellImageView: UIImageView = .init().then {
        $0.image = .init(named: "defaultImage")
        $0.contentMode = .scaleToFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.configureLayouts()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.image = .init(named: "defaultImage")
    }
    
    func configure(with data: Data) {
        self.cellImageView.image = .init(data: data)
    }
}

private extension HomeCell {
    
    func configureLayouts() {
        self.addSubview(cellImageView)
        
        cellImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
