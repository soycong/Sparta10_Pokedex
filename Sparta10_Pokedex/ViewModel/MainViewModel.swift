//
//  MainViewModel.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/30/24.
//

import Foundation
import RxSwift

//비즈니스 로직 작성

class MainViewModel {
    private let disposeBag = DisposeBag()
    
    ///View가 구독할 subject
    let pokemonSubject = BehaviorSubject(value: [PokemonList]())
    let pokemonDetailSubject = PublishSubject<PokemonDetail>()
    
    let limit = 20
    let offset = 0
    
    init() {
        fetchPokemonList(limit: limit, offset: offset)
        
//        if let firstPokemon = try? pokemonSubject.value().first {
//            fetchPokemonDetail(pokemonList: firstPokemon)
//        }
        
        fetchPokemonDetail()
    }
    
    func fetchPokemonList(limit: Int, offset: Int) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            pokemonSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .debug()
            .subscribe(onSuccess: { [weak self] (pokemonListResponse: PokemonListResponse) in
                self?.pokemonSubject.onNext(pokemonListResponse.results)
            }, onFailure: { [weak self] error in
                self?.pokemonSubject.onError(error)
            }).disposed(by: disposeBag)
    }
    
//    func fetchPokemonDetail(pokemonList: PokemonList) {
//        guard let pokemonUrl = pokemonList.url else {
//            pokemonDetailSubject.onError(NetworkError.dataFetchFail)
//            return
//        }
//        
//        guard let url = URL(string: pokemonUrl) else {
//            pokemonDetailSubject.onError(NetworkError.invalidUrl)
//            return
//        }
//        
//
//        NetworkManager.shared.fetch(url: url)
//            .debug("Pokemon Detail")
//            .subscribe(
//                onSuccess: { [weak self] (pokemonDetail: PokemonDetail) in
//                    self?.pokemonDetailSubject.onNext(pokemonDetail)
//                },
//                onFailure: { [weak self] error in
//                    self?.pokemonDetailSubject.onError(error)
//                }
//            )
//            .disposed(by: disposeBag)
//    }
    
    func fetchPokemonDetail() {
        let url = "https://pokeapi.co/api/v2/pokemon/1/"
        
        NetworkManager.shared.fetch(url: URL(string: url)!)
            .debug("Pokemon Detail")
            .subscribe(
                onSuccess: { [weak self] (pokemonDetail: PokemonDetail) in
                    self?.pokemonDetailSubject.onNext(pokemonDetail)
                },
                onFailure: { [weak self] error in
                    self?.pokemonDetailSubject.onError(error)
                }
            )
            .disposed(by: disposeBag)
    }
}
