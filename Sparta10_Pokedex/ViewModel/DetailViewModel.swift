//
//  DetailViewModel.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/31/24.
//

import UIKit
import RxSwift

final class DetailViewModel {
    
    private let disposeBag = DisposeBag()
    let pokemonDetailSubject = PublishSubject<PokemonDetail>()
    let pokemonImageSubject = PublishSubject<UIImage>()

    func fetchPokemonDetail(pokemonList: PokemonList) {
        guard let pokemonUrl = pokemonList.url,
              let url = URL(string: pokemonUrl) else {
            pokemonDetailSubject.onError(NetworkError.invalidUrl)
            return
        }
        
        if let id = Int(pokemonUrl.split(separator: "/").last ?? "0") {
            let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
            fetchPokemonImage(urlString: imageUrlString)
        }
        
        NetworkManager.shared.fetch(url: url)
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
    
    private func fetchPokemonImage(urlString: String) {
        guard let imageUrl = URL(string: urlString) else { return }
        
        Observable.just(imageUrl)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { url -> UIImage? in
                guard let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) else {
                    return nil
                }
                return image
            }
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] image in
                self?.pokemonImageSubject.onNext(image)
            })
            .disposed(by: disposeBag)
    }
}
