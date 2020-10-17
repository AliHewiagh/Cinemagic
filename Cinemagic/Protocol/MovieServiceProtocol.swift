//
//  MovieServiceProtocol.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 17/10/2020.
//

import Foundation

protocol MovieServiceProtocol {
    
    func fetchMoviesList(pageNumber: String, completion: @escaping (ApiResult)->Void)
    func fetchMovie(movieId: String, completion: @escaping (ApiResult)->Void)
  
}
