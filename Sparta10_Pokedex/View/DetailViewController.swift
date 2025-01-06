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
    
    private var informationView: UIView = {
        let view = UIView()
        view.backgroundColor = .detailBackground
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var stackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, typeLabel, heightLabel, weightLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .cellBackground
        label.numberOfLines = 0
        return label
    }()
    
    private var typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .cellBackground
        label.numberOfLines = 0
        return label
    }()
    
    private var heightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .cellBackground
        label.numberOfLines = 0
        return label
    }()
    
    private var weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .cellBackground
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
                
                let koreanName = PokemonTranslator.getKoreanName(for: pokemonDetail.name)
                
                let types = pokemonDetail.types.map { type in
                    if let pokemonType = PokemonTypeName(rawValue: type.type.name) {
                        return pokemonType.displayName
                    }
                    return type.type.name
                }
                
                self.nameLabel.text = "No.\(pokemonDetail.id) \(koreanName)"
                self.typeLabel.text = "타입: \(types.joined(separator: ", "))"
                self.heightLabel.text = "키: \(pokemonDetail.height)0cm"
                self.weightLabel.text = "몸무게: \(String(format: "%.1f", Double(pokemonDetail.weight) / 10))kg"
            }, onError: { error in
                print("상세정보 에러:", error)
            })
            .disposed(by: disposeBag)
    }
    
    func configureUI() {
        view.addSubview(informationView)
        view.addSubview(stackView)
        
        informationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(200)
        }
        
        weightLabel.snp.makeConstraints {
            $0.bottom.equalTo(stackView.snp.bottom).offset(-40)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(informationView.snp.top).offset(20)
            $0.leading.trailing.equalTo(informationView).inset(20)
            $0.bottom.lessThanOrEqualTo(informationView.snp.bottom).offset(-20)
        }
    }
    
    func configure(with pokemon: PokemonList) {
        detailViewModel.fetchPokemonDetail(pokemonList: pokemon)
    }
}
