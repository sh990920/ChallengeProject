//
//  DetailViewController.swift
//  ChallengeProject
//
//  Created by 박승환 on 8/6/24.
//

import Foundation
import UIKit
import SnapKit

class DetailViewController: UIViewController {
    
    var pokemon: Pokemon?
    let detailView = DetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(detailView)
        view.backgroundColor = .mainRed
        detailView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.height.equalTo(400)
        }
        if let pokemon = pokemon {
            configure(item: pokemon)
        }
    }
    
    func configure(item: Pokemon) {
        detailView.indexLabel.text = "No.\(item.id.self)"
        detailView.nameLabel.text = PokemonTranslator.getKoreanName(for: item.name)
        var typeText = "타입 : "
        for (idx, type) in item.types.enumerated() {
            guard let typeName = convertToKoreanTypeName(from: type.type) else { return }
            if idx == item.types.count - 1 {
                typeText += typeName
            } else {
                typeText += "\(typeName), "
            }
        }
        detailView.typeLabel.text = typeText
        detailView.heightLabel.text = "키 : \(Double(item.height) / 10)m"
        detailView.weightLabel.text = "몸무게 : \(Double(item.weight) / 10)kg"
        detailView.configureImage(image: item.sprites.frontDefault)
    }
    
    
    
}
