//
//  LaunchViewController.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/10.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class LaunchViewController: UIViewController {
    
    private let logoImageView: UIImageView = .init().then {
        $0.image = .init(named: "constantLogo")
        $0.contentMode = .scaleAspectFit
    }
    
    private let incImageView: UIImageView = .init().then {
        $0.image = .init(named: "constantInc")
        $0.contentMode = .scaleAspectFit
    }
    
    private weak var coordinatorDelegate: LaunchCoordinateDelegate?
    
    var disposeBag: DisposeBag = .init()
    
    init(with coordinatorDelegate: LaunchCoordinateDelegate) {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateLayouts()
        self.reactor?.action.onNext(.fetchDefaultList)
    }
}

extension LaunchViewController: View {
    
    func bind(reactor: LaunchReactor) {
        reactor.state.map(\.piscumDataSource)
            .asDriver { _ in return .never() }
            .drive(with: self) { (owner, dataSource) in
                guard dataSource.count == 20 else { return }
                
                owner.coordinatorDelegate?.moveToHome(with: dataSource)
            }
            .disposed(by: disposeBag)
    }
}

private extension LaunchViewController {
    
    func configureLayouts() {
        self.view.addSubviews(with: logoImageView, incImageView)
        
        self.logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-150)
            $0.width.equalTo(130)
            $0.height.equalTo(100)
        }
        
        self.incImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(39)
            $0.width.equalTo(130)
            $0.height.equalTo(26)
        }
    }
    
    func updateLayouts() {
        UIView.animate(withDuration: 1, animations:  {
            self.logoImageView.snp.updateConstraints {
                $0.centerY.equalToSuperview().offset(-50)
            }
            
            self.incImageView.snp.updateConstraints {
                $0.centerY.equalToSuperview().offset(13)
            }
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
}
