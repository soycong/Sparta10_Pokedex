//
//  PokemonCollectionViewCell.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/31/24.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    static let id: String = "PokemonCollectionViewCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PokemonBall")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        self.backgroundColor = .cellBackground
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // cell 버벅임 현상 해결
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with pokemon: PokemonList) {
        // URL에서 포켓몬 ID 추출
        if let url = pokemon.url,
           let id = Int(url.split(separator: "/").last ?? "0") {
            let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
            if let imageUrl = URL(string: imageUrlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageUrl),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                        }
                    }
                }
            }
        }
    }
}
