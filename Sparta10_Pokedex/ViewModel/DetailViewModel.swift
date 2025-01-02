//
//  DetailViewModel.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/31/24.
//

import UIKit
import RxSwift

class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    let pokemonDetailSubject = PublishSubject<PokemonDetail>()
    
    init() {
        //fetchPokemonDetail(PokemonList)
    }
    
    func fetchPokemonDetail(pokemonList: PokemonList) {
        guard let pokemonUrl = pokemonList.url,
              let url = URL(string: pokemonUrl) else {
            pokemonDetailSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
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
