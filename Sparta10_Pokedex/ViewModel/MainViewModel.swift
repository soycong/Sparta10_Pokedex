//
//  MainViewModel.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/30/24.
//

import Foundation
import RxSwift

final class MainViewModel {
    private let disposeBag = DisposeBag()
    
    let pokemonSubject = BehaviorSubject(value: [PokemonList]())
    
    let limit = 20
    private var offset = 0
    private var isFetching = false

    func fetchPokemonList() {
        // 이미 데이터를 가져오는 중이면 중복 요청 방지
        guard !isFetching else { return }
        isFetching = true
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            pokemonSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        NetworkManager.shared.fetch(url: url)
            .subscribe(onSuccess: { [weak self] (pokemonListResponse: PokemonListResponse) in
                guard let self = self else { return }
                
                if let currentList = try? self.pokemonSubject.value() {
                    // 기존 리스트에 새로운 데이터 추가
                    let newList = currentList + pokemonListResponse.results
                    self.pokemonSubject.onNext(newList)
                    
                    // 다음 페이지를 위해 offset 증가
                    self.offset += self.limit
                }
                self.isFetching = false            }, onFailure: { [weak self] error in
                    self?.pokemonSubject.onError(error)
                    self?.isFetching = false
                }).disposed(by: disposeBag)
    }
}
