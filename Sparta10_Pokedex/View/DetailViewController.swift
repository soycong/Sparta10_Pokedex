//
//  DetailViewController.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/31/24.
//

import UIKit
import SnapKit
import RxSwift

class DetailViewController: UIViewController {
    
    private let detailViewModel = DetailViewModel()
    
    private let disposeBag = DisposeBag()
    
    private lazy var stackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, typeLabel, heightLabel, weightLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        
        stackView.backgroundColor = .detailBackground
        stackView.layer.cornerRadius = 20
        
//        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
//        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PokemonBall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름: nameLabel"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private var typeLabel: UILabel = {
        let label = UILabel()
        label.text = "타입: typeLabel"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private var heightLabel: UILabel = {
        let label = UILabel()
        label.text = "키: heightLabel"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private var weightLabel: UILabel = {
        let label = UILabel()
        label.text = "무게: weightLabel"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main
        bindViewModel()
        configureUI()
    }
    
    private func bindViewModel() {
        detailViewModel.pokemonDetailSubject
            .observe(on: MainScheduler.instance)  // UI 업데이트는 메인 스레드에서
            .debug()
            .subscribe(onNext: { [weak self] pokemonDetail in
                guard let self = self else { return }
                
                if let imageUrlString = pokemonDetail.sprites.front_default,
                   let imageUrl = URL(string: imageUrlString) {

                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: imageUrl),
                           let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.imageView.image = image
                            }
                        }
                    }
                }
                
                self.nameLabel.text = "이름: \(pokemonDetail.name)"
                self.heightLabel.text = "키: \(pokemonDetail.height)0cm"
                self.weightLabel.text = "무게: \(pokemonDetail.weight)kg"
                
            }, onError: { error in
                print("상세정보 에러:", error)
            })
            .disposed(by: disposeBag)
    }
    
    func configureUI() {
        view.addSubview(stackView)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.top).inset(20)
            $0.width.height.equalTo(200)
        }
        
        weightLabel.snp.makeConstraints {
            $0.bottom.equalTo(stackView.snp.bottom).offset(-20)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            //$0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            //$0.bottom.equalToSuperview().inset(20)
            //$0.verticalEdges.equalToSuperview().inset(20)
            //$0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            //$0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func configure(with pokemon: PokemonList) {
        detailViewModel.fetchPokemonDetail(pokemonList: pokemon)
    }
}
