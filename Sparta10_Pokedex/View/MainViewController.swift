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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //bindViewModel()
    }
    
    private func bindViewModel() {
        // 포켓몬 리스트 데이터 구독
        viewModel.pokemonSubject
            .subscribe(onNext: { pokemonList in
                print("받은 포켓몬 리스트:", pokemonList)
                // 여기서 TableView나 CollectionView 업데이트
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

