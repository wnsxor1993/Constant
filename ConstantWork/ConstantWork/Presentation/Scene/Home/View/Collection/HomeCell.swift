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
        $0.contentMode = .scaleAspectFill
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
        
        cellImageView.image = nil
    }
    
//    func configure(data: SearchedStation) {
//
//    }
}

private extension HomeCell {
    
    func configureLayouts() {
        self.addSubview(cellImageView)
        
        cellImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
