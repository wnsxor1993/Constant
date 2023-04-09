//
//  HomeViewController.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    private let titleView: HomeTitleView = .init()
    
    private let listTitleLabel: UILabel = .init().then {
        $0.text = "Piscum Photos"
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.sizeToFit()
    }
    
    private let listCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init()).then {
//        guard let compositionalLayout: UICollectionViewCompositionalLayout = MainCollectionLayout().compositionalLayoutSection else { return }
//
//        $0.collectionViewLayout = compositionalLayout
        $0.backgroundColor = .clear
//        $0.register(StationCell.self, forCellWithReuseIdentifier: StationCell.reuseIdentifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.configureLayouts()
    }


}

private extension HomeViewController {
    
    func configureLayouts() {
        self.view.addSubviews(with: titleView, listTitleLabel, listCollectionView)
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaInsets.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(70)
        }
        
        listTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        listCollectionView.snp.makeConstraints {
            $0.top.equalTo(listTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.bottom.equalToSuperview()
        }
    }
}
