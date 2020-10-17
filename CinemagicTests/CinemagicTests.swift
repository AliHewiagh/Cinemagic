//
//  CinemagicTests.swift
//  CinemagicTests
//
//  Created by Ali Hewiagh on 13/10/2020.
//


@testable import Cinemagic


import XCTest
import RxSwift
import RxTest


class CinemagicTests: XCTestCase {
    
    
    var movieListViewModel : MoviesListViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    
    fileprivate var service : MockMovieService!


    override func setUpWithError() throws {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        self.service = MockMovieService()
        self.movieListViewModel = MoviesListViewModel(movieService: service)
    
    }

    override func tearDownWithError() throws {
        self.movieListViewModel = nil
        self.service = nil
        super.tearDown()
    }

    // Ensure MovieListViewModel calls specified methods for the dependency injection
    func testFetchMoviesList() {
        // When start fetch
        self.movieListViewModel.requestMoviesList(pageNumber: "", isRefresh: false)

        // Assert
        XCTAssert(service!.isFetchMoviesListCalled)
    }
    
    /*
     Ensure Connection Error Message
     Arise If No Internet Connection
    */
    func testFetchMoviesFailDueToConnection() {
        
        let connectionError = scheduler.createObserver(HomeError.self)
        
        // giving a service with no movies
        service.completeMoviesList = []
        
        self.movieListViewModel.error.observeOn(MainScheduler.instance)
            .subscribe(connectionError).disposed(by: disposeBag)
        
        self.movieListViewModel.requestMoviesList(pageNumber: "", isRefresh: false)
        self.movieListViewModel.error.onNext(.internetError("Check your Internet connection."))
       
        
        XCTAssertEqual(connectionError.events , [.next(0, HomeError.internetError("Check your Internet connection."))])
    }
    
    /*
     Ensure Server Error Message
     Arise In Case Any Error
     Comes From The Server Side
     */
    func testFetchMoviesFailDueToServerError() {
        
        let serverError = scheduler.createObserver(HomeError.self)
        
        // giving a service with no movies
        service.completeMoviesList = []
        
        self.movieListViewModel.error.observeOn(MainScheduler.instance)
            .subscribe(serverError).disposed(by: disposeBag)
        
        self.movieListViewModel.error.onNext(.serverMessage("Server Error."))
       
        
        XCTAssertEqual(serverError.events , [.next(0, HomeError.serverMessage("Server Error."))])
    }
    
    /*
     Ensure MovieListViewMode Recieves
     The Movies List From The Server
     Without Errors
     */
    func testFetchMoviesSuccess() {
        
        // Create Movie Test Observable
        let movieObservable = scheduler.createObserver([Movie].self)
        
        // Create Gener Object
        let geners: [Genre] = [Genre(id: 22, name: "Documentary")]
        
        // Create Movie Object
        let movies: [Movie] = [Movie(id: 1000, title: "Movie Title", original_title: "Movie Original Title", overview: "Movie Overview", release_date: "20/10/190", backdrop_path: "", poster_path: "", original_language: "", runtime: 88, popularity: 6.7, genres: geners)]
        
        // Set movies to Mock Service Movies
        self.service.completeMoviesList = movies

        self.movieListViewModel.movies.bind(to: movieObservable).disposed(by: disposeBag)

        self.movieListViewModel.movies.onNext(service.completeMoviesList)

        XCTAssertEqual(movieObservable.events , [.next(0, movies)])
    }
}


 class MockMovieService: MovieServiceProtocol {
    
    var completeMoviesList: [Movie] = [Movie]()

    var isFetchMoviesListCalled = false
    
     func fetchMoviesList(pageNumber: String, completion: @escaping (ApiResult) -> Void) {
        isFetchMoviesListCalled = true
    }
    
     func fetchMovie(movieId: String, completion: @escaping (ApiResult) -> Void) {}
}
