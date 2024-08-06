//
//  PokeCollectionViewCell.swift
//  ChallengeProject
//
//  Created by 박승환 on 8/6/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class PokeCollectionViewCell: UICollectionViewCell {
    let pokemonImage = UIImageView()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        contentView.addSubview(pokemonImage)
        pokemonImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(image: String) {
        pokemonImage.image = nil // 셀이 재사용될 때 이전 이미지를 초기화
        loadImage(from: image)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.pokemonImage.image = image
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
