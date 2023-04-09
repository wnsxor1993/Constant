//
//  HomeTitleView.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit
import Then
import SnapKit

final class HomeTitleView: UIView {
    
    private let logoImageView: UIImageView = .init().then {
        $0.image = .init(named: "constantLogo")
        $0.contentMode = .scaleAspectFit
    }
    
    private let incImageView: UIImageView = .init().then {
        $0.image = .init(named: "constantInc")
        $0.contentMode = .scaleAspectFit
    }
    
    init() {
        super.init(frame: .zero)
        
        self.configureLayouts()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This initializer doesn't use")
    }
}

private extension HomeTitleView {
    
    func configureLayouts() {
        self.addSubviews(with: logoImageView, incImageView)
        
        self.logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(52)
            $0.height.equalTo(40)
        }
        
        self.incImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(52)
            $0.height.equalTo(10)
        }
    }
}
