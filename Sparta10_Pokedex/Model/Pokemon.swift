//
//  Pokemon.swift
//  Sparta10_Pokedex
//
//  Created by seohuibaek on 12/30/24.
//

import Foundation

struct PokemonListResponse: Codable {
    let results: [PokemonList]
}

struct PokemonList: Codable {
    let name: String?
    let url: String?
}

struct PokemonDetailResponse: Codable {
    let results: [PokemonDetail]
}

struct PokemonDetail: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
    let types: [TypeElement]
}

struct Sprites: Codable {
    let front_default: String?
}

struct TypeElement: Codable {
    let type: Type
}

struct Type: Codable {
    let name: String
}
