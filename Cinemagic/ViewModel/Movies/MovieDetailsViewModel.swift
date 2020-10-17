//
//  MovieDetailsViewModel.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 16/10/2020.
//

import UIKit
import RxSwift
import RxCocoa


class MovieDetailsViewModel {
    
    // MARK: - Properties
    
    private let movieService: MovieService

    public let movie : PublishSubject<Movie> = PublishSubject()
    public let error : PublishSubject<HomeError> = PublishSubject()
    public let loading: PublishSubject<Bool> = PublishSubject()
    
    // MARK: - init
    init(movieService: MovieService) {
        self.movieService = movieService
    }
}

// MARK: - Extensions

extension MovieDetailsViewModel {
    
    func requestMovie(movieId: String) {
        
        self.loading.onNext(true)
        
        self.movieService.fetchMovie(movieId: movieId, completion: { (result) in
            
            self.loading.onNext(false)
            
            switch result {
            case .success(let returnJson) :
                
                /*
                 Json Data of the movie as Input
                 Movie Object as Output
                 */
                if let returnMovie = Movie(data: try! returnJson.rawData()) {
                    
                    self.movie.onNext(returnMovie)
                    
                } else {
                    
                    self.error.onNext(.serverMessage("Faild to retrieve the movie"))
                }
                
            case .failure(let failure) :
                switch failure {
                case .connectionError:
                    self.error.onNext(.internetError("Check your Internet connection."))
                case .authorizationError(let errorJson):
                    self.error.onNext(.serverMessage(errorJson["message"].stringValue))
                default:
                    self.error.onNext(.serverMessage("Unknown Error"))
                }
            }
        })
    }
}
