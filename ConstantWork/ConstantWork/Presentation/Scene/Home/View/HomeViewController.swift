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
import ReactorKit

class HomeViewController: UIViewController {

    private let titleView: HomeTitleView = .init()
    
    private let listTitleLabel: UILabel = .init().then {
        $0.text = "Piscum Photos"
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.sizeToFit()
    }
    
    private let listCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init()).then {
        guard let compositionalLayout: UICollectionViewCompositionalLayout = CollectionLayout().makeCompositionalLayout(which: .home) else { return }

        $0.collectionViewLayout = compositionalLayout
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<DiffableDataSection, PiscumDTO>?
    private weak var coordinatorDelegate: HomeCoordinator?
    
    var disposeBag: DisposeBag = .init()
    
    init(with coordinatorDelegate: HomeCoordinator) {
        self.coordinatorDelegate = coordinatorDelegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This initializer does not use")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.configureLayouts()
        self.configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reactor?.action.onNext(.fetchPageList)
    }
}

extension HomeViewController: View {
    
    func bind(reactor: HomeReactor) {
        reactor.state.map(\.pageLists)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { (owner, lists) in
                guard !(lists.isEmpty) else { return }
                
                owner.makeSnapShotAndApply(data: lists)
            }
            .disposed(by: disposeBag)
    }
}

private extension HomeViewController {
    
    func configureLayouts() {
        self.view.addSubviews(with: titleView, listTitleLabel, listCollectionView)
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(55)
        }
        
        listTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        listCollectionView.snp.makeConstraints {
            $0.top.equalTo(listTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: CollectionView
private extension HomeViewController {
    
    func configureDataSource() {
        self.dataSource = .init(collectionView: self.listCollectionView) { (collectionView, index, piscumDTO) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: index) as? HomeCell else { return .init() }
            
            let image: UIImage = .init(named: "demoImage")!
            cell.configure(with: image)
            
            return cell
        }
        
        self.listCollectionView.dataSource = self.dataSource
    }
    
    func makeSnapShotAndApply(data: [PiscumDTO]) {
        let snapshot: NSDiffableDataSourceSnapshot<DiffableDataSection, PiscumDTO> = SnapShotService.makeSnapShot(with: data, section: DiffableDataSection.home)
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
}
