//
//  ViewController.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/30/24.
//

import UIKit
import SnapKit
import RxSwift

final class MainViewController: UIViewController {

    private let mainViewModel = MainViewModel()
    private let detailViewModel = DetailViewModel()
    
    private let disposeBag = DisposeBag()
    
    private var pokemonList = [PokemonList]()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PokemonBall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: PokemonCollectionViewCell.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .main
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main
        bind()
        configureUI()
    }
    
    private func bind() {
        // 포켓몬 리스트 데이터 구독
        mainViewModel.pokemonSubject
            .observe(on: MainScheduler.instance) //MainThread 에서 동작해라!
            .subscribe(onNext: { pokemonList in
                self.pokemonList = pokemonList
                self.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생:", error)
            })
            .disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // 아이템 크기 설정
         let itemSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(1/3),  // 화면 너비의 1/3
             heightDimension: .fractionalWidth(1/3)   // 정사각형을 위해 너비와 동일하게
         )
         let item = NSCollectionLayoutItem(layoutSize: itemSize)
         item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
         
         // 그룹 크기 설정
         let groupSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(1.0),    // 전체 너비 사용
             heightDimension: .fractionalWidth(1/3)    // 아이템과 동일한 높이
         )
         
         // 그룹에 아이템을 수평으로 3개 배치
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
        )
         
         let section = NSCollectionLayoutSection(group: group)
         section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
         
         return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureUI() {
        [ imageView, collectionView ].forEach { view.addSubview($0) }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionViewCell.id, for: indexPath) as? PokemonCollectionViewCell  else { return UICollectionViewCell() }
        
        let pokemon = pokemonList[indexPath.item]
        cell.configure(with: pokemon)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemon = pokemonList[indexPath.item]
        let detailVC = DetailViewController()
        detailVC.configure(with: pokemon)
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.bounds.height
        
        // 스크롤이 하단에서 100포인트 남았을 때 다음 데이터 로드
        if offsetY > contentHeight - screenHeight - 100 {
            mainViewModel.fetchPokemonList()
        }
    }
}
