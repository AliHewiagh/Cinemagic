//
//  Movie.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 13/10/2020.
//

import UIKit

struct Movie: Codable, Equatable {
    
    let id: Int
    let title, original_title, overview,release_date : String
    let backdrop_path, poster_path, original_language: String?
    let runtime: Int?
    let popularity: Double

    let genres: [Genre]?

    enum CodingKeys: String, CodingKey {
            case backdrop_path
            case id
            case original_title
            case overview
            case poster_path
            case original_language
            case release_date
            case runtime
            case title
            case popularity
            case genres
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
       return true
    }
}

struct Genre: Codable {
    let id: Int?
    let name: String?
}

// MARK: Convenience initializers
extension Movie {
    init?(data: Data) {
        guard let mo = try? JSONDecoder().decode(Movie.self, from: data) else {
            return nil }
        self = mo
    }
}
