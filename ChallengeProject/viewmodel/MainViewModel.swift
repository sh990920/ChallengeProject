//
//  MainViewModel.swift
//  ChallengeProject
//
//  Created by 박승환 on 8/5/24.
//

import Foundation
import RxSwift

class MainViewModel {
    
    private let disposeBag = DisposeBag()
    private let limit = 20
    private var offset = 0
    
    let pokemonListSubject = BehaviorSubject(value: [PokemonResult]())
    let pokemonDetailSubject = BehaviorSubject(value: [Pokemon]())
    var isLoading = false
    
    init() {
        fetchPokemonList()
    }
    
    // Pokemon 목록 데이터를 불러오는 메서드
//    func fetchPokemonList() {
//        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0") else {
//            pokemonListSubject.onError(NetworkError.invalidUrl)
//            return
//        }
//        
//        NetworkManager.shared.fetch(url: url)
//            .subscribe(onSuccess: { [weak self] (pokemonResponse: PokemonResponse) in
//                self?.pokemonListSubject.onNext(pokemonResponse.results)
//                self?.fetchPokemonDetails(from: pokemonResponse.results)
//            }, onFailure: { [weak self] error in
//                self?.pokemonListSubject.onError(error)
//            }).disposed(by: disposeBag)
//    }
    func fetchPokemonList() {
        guard !isLoading else { return }
        isLoading = true
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            pokemonListSubject.onError(NetworkError.invalidUrl)
            isLoading = false
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (pokemonResponse: PokemonResponse) in
                guard let self = self else { return }
                self.offset += self.limit
                var currentResults = (try? self.pokemonListSubject.value()) ?? []
                currentResults.append(contentsOf: pokemonResponse.results)
                self.pokemonListSubject.onNext(currentResults)
                self.fetchPokemonDetails(from: pokemonResponse.results)
                self.isLoading = false
            }, onFailure: { [weak self] error in
                self?.pokemonListSubject.onError(error)
                self?.isLoading = false
            }).disposed(by: disposeBag)
    }

    func fetchNextPokemonList() {
        fetchPokemonList()
    }
    
    // 각 포켓몬의 상세 정보를 불러오는 메서드
//    func fetchPokemonDetails(from results: [PokemonResult]) {
//        let pokemonFetches = results.map { result -> Single<Pokemon> in
//            guard let url = URL(string: result.url) else {
//                return Single.error(NetworkError.invalidUrl)
//            }
//            return NetworkManager.shared.fetch(url: url)
//        }
//        Single.zip(pokemonFetches)
//            .subscribe(onSuccess: { [weak self] pokemons in
//                self?.pokemonDetailSubject.onNext(pokemons)
//            }, onFailure: { [weak self] error in
//                self?.pokemonDetailSubject.onError(error)
//            }).disposed(by: disposeBag)
//    }
    func fetchPokemonDetails(from results: [PokemonResult]) {
        let pokemonFetches = results.map { result -> Single<Pokemon> in
            guard let url = URL(string: result.url) else {
                return Single.error(NetworkError.invalidUrl)
            }
            return NetworkManager.shared.fetch(url: url)
        }
        Single.zip(pokemonFetches)
            .subscribe(onSuccess: { [weak self] pokemons in
                guard let self = self else { return }
                var currentDetails = (try? self.pokemonDetailSubject.value()) ?? []
                currentDetails.append(contentsOf: pokemons)
                self.pokemonDetailSubject.onNext(currentDetails)
            }, onFailure: { [weak self] error in
                self?.pokemonDetailSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
}
