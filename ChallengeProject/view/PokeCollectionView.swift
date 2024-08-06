//
//  pokeCollectionView.swift
//  ChallengeProject
//
//  Created by 박승환 on 8/6/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class PokeCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 3 - 10
        layout.itemSize = CGSize(width: width, height: width)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    private var pokemonList = [PokemonResult]()
    private var pokemonDetails = [Pokemon]()
    var viewController: UIViewController?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PokeCollectionViewCell.self, forCellWithReuseIdentifier: "PokeCollectionViewCell")
        collectionView.backgroundColor = .darkRed
        
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        // ViewModel의 pokemonListSubject를 구독하여 포켓몬 리스트를 업데이트
        viewModel.pokemonListSubject
            .observe(on: MainScheduler.instance) // 메인 스레드에서 관찰
            .subscribe(onNext: { [weak self] pokemonList in
                self?.pokemonList = pokemonList // 포켓몬 리스트 업데이트
                self?.collectionView.reloadData() // 컬렉션 뷰 리로드
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
        
        // ViewModel의 pokemonDetailSubject를 구독하여 포켓몬 상세 정보를 업데이트
        viewModel.pokemonDetailSubject
            .observe(on: MainScheduler.instance) // 메인 스레드에서 관찰
            .subscribe(onNext: { [weak self] pokemonDetails in
                self?.pokemonDetails = pokemonDetails // 포켓몬 상세 정보 업데이트
                self?.collectionView.reloadData() // 컬렉션 뷰 리로드
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            viewModel.fetchNextPokemonList()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCollectionViewCell", for: indexPath) as! PokeCollectionViewCell
        let pokemon = pokemonDetails[indexPath.item]
        cell.configure(image: pokemon.sprites.frontDefault)
        cell.backgroundColor = .cellBackground
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 10
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectItem = pokemonDetails[indexPath.item]
        let nextViewController = DetailViewController()
        nextViewController.pokemon = selectItem
        
        if let parentVC = viewController {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            parentVC.navigationItem.backBarButtonItem = backItem
            parentVC.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    
}

extension UIColor {
    static let mainRed = UIColor(red: 190/255, green: 30/255, blue: 40/255, alpha: 1.0)
    static let darkRed = UIColor(red: 120/255, green: 30/255, blue: 30/255, alpha: 1.0)
    static let cellBackground = UIColor(red: 245/255, green: 245/255, blue: 235/255, alpha: 1.0)
}
