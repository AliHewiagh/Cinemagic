//
//  MoviesListViewModel.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 13/10/2020.
//

import UIKit
import RxSwift
import RxCocoa

public enum HomeError: Equatable {
    case internetError(String)
    case serverMessage(String)
}

class MoviesListViewModel {
    
    // MARK: - Properties
    
    let movieService: MovieServiceProtocol
    var accumulateMovieList = [Movie]()
    
    public let movies : PublishSubject<[Movie]> = PublishSubject()
    public let loading: PublishSubject<Bool> = PublishSubject()
    public let error : PublishSubject<HomeError> = PublishSubject()
    public let emptyList : PublishSubject<String> = PublishSubject()
    public let refresher : PublishSubject<Bool> = PublishSubject()
    public let incrementPageNumber : PublishSubject<Bool> = PublishSubject()
    
    
    // MARK: - init
    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
    }
}

// MARK: - Extensions

extension MoviesListViewModel {
    
    func requestMoviesList(pageNumber: String, isRefresh: Bool) {
        
        self.loading.onNext(true)
        
        self.movieService.fetchMoviesList(pageNumber: pageNumber, completion: { (result) in
            
            /*
             Empty the displayed movies list
             when collection view is refreshed
             */
            if isRefresh {
                self.accumulateMovieList = []
            }
            
            self.loading.onNext(false)
            self.refresher.onNext(false)
            
            switch result {
            case .success(let returnJson) :
                
                /*
                 Json Data of the movies array as Input
                 Movie Objects as Output
                 */
                let moviesList = returnJson["results"].arrayValue.compactMap {  return Movie(data: try! $0.rawData()) }
                
                /*
                 In case json data decoding fail,
                 Return no movies to show message.
                 */
                if moviesList.count > 0 {
                    self.accumulateMovieList.append(contentsOf: moviesList)
                    self.incrementPageNumber.onNext(true)
                    self.movies.onNext(self.accumulateMovieList)
                    
                } else {
                    self.emptyList.onNext("No movies to show.")
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
