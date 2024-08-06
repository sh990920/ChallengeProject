//
//  ViewController.swift
//  ChallengeProject
//
//  Created by 박승환 on 8/5/24.
//

import UIKit
import RxSwift
import SnapKit

class ViewController: UIViewController {
    private let collectionView = PokeCollectionView()
    private let poketBallImageVIew = UIImageView(image: UIImage(named: "poketBall"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.viewController = self
    }
    
    func configureUI() {
        view.addSubview(poketBallImageVIew)
        view.addSubview(collectionView)
        view.backgroundColor = UIColor.mainRed
        
        poketBallImageVIew.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(poketBallImageVIew.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

}

