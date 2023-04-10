//
//  LoadingFooter.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit
import Then
import SnapKit

final class LoadingFooter: UICollectionReusableView {

    static let reuseIdentifier = "LoadingFooter"

    private(set) var activityIndicator: UIActivityIndicatorView = .init().then {
        $0.style = .large
        $0.color = .black
        $0.stopAnimating()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        configureLayouts()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LoadingFooter {

    func configureLayouts() {
        self.addSubview(activityIndicator)

        self.activityIndicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
