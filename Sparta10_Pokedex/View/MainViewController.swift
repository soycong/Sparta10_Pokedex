//
//  ViewController.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/30/24.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {

    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    private var pokemonList = [PokemonList]()
    
    private lazy var collectionView: UICollectionView = {
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
//        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
//        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bindViewModel()
    }
    
    private func bindViewModel() {
        // 포켓몬 리스트 데이터 구독
        viewModel.pokemonSubject
            .observe(on: MainScheduler.instance) //MainThread 에서 동작해라!
            .subscribe(onNext: { pokemonList in
                print("받은 포켓몬 리스트:", pokemonList)

                self.pokemonList = pokemonList
                self.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생:", error)
            })
            .disposed(by: disposeBag)
            
        // 포켓몬 상세 정보 구독
        viewModel.pokemonDetailSubject
            .subscribe(onNext: { pokemonDetail in
                print("포켓몬 상세정보:", pokemonDetail)
                // 상세 화면 업데이트
            }, onError: { error in
                print("상세정보 에러:", error)
            })
            .disposed(by: disposeBag)
    }

}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionViewCell.id, for: indexPath) as? PokemonCollectionViewCell  else { return UICollectionViewCell() }

        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    
}

