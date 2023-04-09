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
    
    private lazy var listCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init()).then {
        guard let compositionalLayout: UICollectionViewCompositionalLayout = CollectionLayout().makeCompositionalLayout(which: .home) else { return }

        $0.collectionViewLayout = compositionalLayout
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
        $0.register(LoadingFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadingFooter.reuseIdentifier)
        $0.delegate = self
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<DiffableDataSection, PiscumDataSource>?
    private weak var coordinatorDelegate: HomeCoordinator?
    
    private var canUpdate: Bool = false
    private var footerCell: LoadingFooter?
    
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
                
                let filtered = lists.filter { $0.imageData != nil }
                
                if filtered.count == lists.count {
                    owner.canUpdate = true
                }
                
                owner.makeSnapShotAndApply(data: lists)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.alertMessage)
            .compactMap { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { (owner, message) in
                guard message != "" else { return }
                
                self.footerCell?.activityIndicator.stopAnimating()
                self.footerCell?.isHidden = true
                
                let alertVC: UIAlertController = .init(title: "Notice", message: message, preferredStyle: .alert)
                let confirmAction: UIAlertAction = .init(title: "확인", style: .cancel) { _ in
                    self.footerCell?.isHidden = false
                    self.reactor?.action.onNext(.resetAlertMessage)
                }
                alertVC.addAction(confirmAction)
                self.present(alertVC, animated: true)
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
        self.dataSource = .init(collectionView: self.listCollectionView) { [weak self] (collectionView, index, piscumDataSource) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: index) as? HomeCell else { return .init() }
            
            if let data: Data = piscumDataSource.imageData {
                cell.configure(with: data)
                
                return cell
            }
            
            self?.reactor?.action.onNext(.fetchPageImage(piscumDataSource))
            
            return cell
        }
        
        self.dataSource?.supplementaryViewProvider = .some({ collectionView, elementKind, indexPath in
            guard let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadingFooter.reuseIdentifier, for: indexPath) as? LoadingFooter else { return .init() }
            
            self.footerCell = cell
            
            return cell
        })
    }
    
    func makeSnapShotAndApply(data: [PiscumDataSource]) {
        let snapshot: NSDiffableDataSourceSnapshot<DiffableDataSection, PiscumDataSource> = SnapShotService.makeSnapShot(with: data, section: DiffableDataSection.home)
        
        DispatchQueue.global(qos: .background).async {
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollOffset = scrollView.contentOffset.y
        
        guard (scrollViewHeight - scrollOffset) < 0, self.canUpdate else { return }
        
        self.canUpdate = false
        
        self.footerCell?.activityIndicator.startAnimating()
        self.reactor?.action.onNext(.fetchPageList)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard let footer = view as? LoadingFooter else { return }
        
        footer.activityIndicator.stopAnimating()
    }
}
