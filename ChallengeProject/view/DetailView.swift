//
//  DetailView.swift
//  ChallengeProject
//
//  Created by 박승환 on 8/6/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class DetailView: UIView {
    let pokemonImageView = UIImageView()
    let indexLabel = UILabel()
    let nameLabel = UILabel()
    let typeLabel = UILabel()
    let heightLabel = UILabel()
    let weightLabel = UILabel()
    let stackView = UIStackView()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        self.backgroundColor = .darkRed
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
                
        stackView.addArrangedSubview(indexLabel)
        stackView.addArrangedSubview(nameLabel)
        indexLabel.textAlignment = .center
        nameLabel.textAlignment = .center
    }
    
    func configure() {
        configureStackView()
        indexLabel.font = .boldSystemFont(ofSize: 25)
        nameLabel.font = .boldSystemFont(ofSize: 25)
        indexLabel.textColor = .white
        nameLabel.textColor = .white
        typeLabel.textColor = .white
        heightLabel.textColor = .white
        weightLabel.textColor = .white
        
        
        [pokemonImageView, stackView, typeLabel, heightLabel, weightLabel].forEach { addSubview($0) }
        
        pokemonImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.width.equalTo(150)
            $0.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(pokemonImageView.snp.bottom)
            $0.height.equalTo(50)
            $0.width.equalTo(200)
            $0.centerX.equalToSuperview()
        }
        
        typeLabel.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(20)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
        heightLabel.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(20)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
        weightLabel.snp.makeConstraints {
            $0.top.equalTo(heightLabel.snp.bottom).offset(20)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
        
    }
    func configureImage(image: String) {
        pokemonImageView.image = nil // 셀이 재사용될 때 이전 이미지를 초기화
        loadImage(from: image)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.pokemonImageView.image = image
            }, onError: { error in
                print("Failed to load image: \(error)")
            }).disposed(by: disposeBag)
    }
    
    private func loadImage(from urlString: String) -> Observable<UIImage?> {
        return Observable.create { observer in
            guard let url = URL(string: urlString) else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error)
                } else if let data = data, let image = UIImage(data: data) {
                    observer.onNext(image)
                } else {
                    observer.onNext(nil)
                }
                observer.onCompleted()
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}
