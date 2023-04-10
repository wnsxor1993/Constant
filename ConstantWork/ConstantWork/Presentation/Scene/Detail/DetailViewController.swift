//
//  DetailViewController.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/10.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class DetailViewController: UIViewController {
    
    private let backButton: UIButton = .init().then {
        $0.setTitle(nil, for: .normal)
        $0.setImage(.init(systemName: "chevron.backward"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private let piscumImageView: UIImageView = .init().then {
        $0.contentMode = .scaleToFill
    }
    
    private let downloadButton: UIButton = .init().then {
        $0.setTitle("사진첩 다운", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.backgroundColor = .blue
        $0.layer.cornerRadius = 10
    }
    
    private weak var coordinatorDelegate: HomeCoordinateDelegate?
    
    private let disposeBag: DisposeBag = .init()
    
    init(with coordinatorDelegate: HomeCoordinateDelegate, imageData: Data) {
        self.coordinatorDelegate = coordinatorDelegate
        
        super.init(nibName: nil, bundle: nil)
        
        self.piscumImageView.image = .init(data: imageData)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("This initializer does not use")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.configureLayouts()
        self.configureAction()
    }
}

private extension DetailViewController {
    
    func configureLayouts() {
        self.view.addSubviews(with: backButton ,piscumImageView, downloadButton)
        backButton.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().inset(15)
            $0.width.height.equalTo(25)
        }
        
        piscumImageView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.view.snp.width)
        }
        
        downloadButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(60)
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalTo(50)
        }
    }
    
    func configureAction() {
        self.backButton.rx.tap
            .asDriver()
            .drive(with: self) { (owner, _) in
                owner.coordinatorDelegate?.pop(which: self)
            }
            .disposed(by: disposeBag)
        
        downloadButton.rx.tap
            .flatMap { _ -> Single<UIImage?> in
                return .just(self.piscumImageView.image)
            }
            .compactMap { $0 }
            .asDriver { _ in return .never() }
            .drive(with: self) { (owner, image) in
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                
                self.coordinatorDelegate?.presentAlertVC(with: "사진첩에 저장이 되었습니다.", completion: {
                    #if DEBUG
                    print("Saved Image")
                    #endif
                })
            }
            .disposed(by: disposeBag)
    }
}
