//
//  MoviesListViewController.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 13/10/2020.
//

import UIKit
import RxSwift
import RxCocoa


class MoviesListViewController: UICollectionViewController {
    
    
    // MARK: - Properties
    private var pageNumber: Int = 1
    
    var movieService = MovieService()
    var moviesListViewModel: MoviesListViewModel

    var movies = PublishSubject<[Movie]>()
    let selectedMovie : PublishSubject<Movie> = PublishSubject()

    let disposeBag = DisposeBag()
    
    
    // MARK: - Views
    let refresher = UIRefreshControl()

    // MARK: - Init
    override init(collectionViewLayout layout: UICollectionViewLayout){
        self.moviesListViewModel = MoviesListViewModel(movieService: self.movieService)
        super.init(collectionViewLayout: layout)
    }
    
   
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#BDC4CC")
        collectionView?.backgroundColor = UIColor.hexStringToUIColor(hex: "#BDC4CC")
        
        refresher.tintColor = .black
        refresher.addTarget(self, action: #selector(reloadMoviesList), for: .valueChanged)
        collectionView.addSubview(refresher)
        
        collectionView.dataSource = nil
        collectionView.delegate = nil
        
        setupCollectionViewWithBinding()
        
        // Ask the MoviesListViewMode for the movie list
        reloadMoviesList("")

    }
    
    // MARK: - Methods
    
    @objc func reloadMoviesList(_: Any) {
        self.pageNumber = 1
        self.moviesListViewModel.requestMoviesList(pageNumber: String(self.pageNumber), isRefresh: false)
    }
    
    func setupCollectionViewWithBinding() {
        // Collection View
        collectionView?.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "cellIdMovie")
        movies.bind(to: collectionView.rx.items(cellIdentifier: "cellIdMovie", cellType: MovieCollectionViewCell.self)) {  (row,movie,cell) in
            cell.movie = movie
            }
        .disposed(by: disposeBag)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.rx.modelSelected(Movie.self)
                  .subscribe(onNext: { movie in
                    self.selectedMovie.onNext(movie)
                    self.presentDetailsPage(movieId: String(movie.id))
                  }).disposed(by: self.disposeBag)
        // -------------------------------------- //
        
        // Loading
        moviesListViewModel
            .loading
            .bind(to: self.rx.isAnimating).disposed(by: disposeBag)
        // -------------------------------------- //
        
        
        // Error Messages
        moviesListViewModel
            .error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (error) in
                switch error {
                case .internetError(let message):
                    MessageBanner.sharedInstance.showBanner(message: message, theme: .error)
                case .serverMessage(let message):
                    MessageBanner.sharedInstance.showBanner(message: message, theme: .warning)
                }
            }).disposed(by: disposeBag)
        // -------------------------------------- //
        
        

        // Handle Empty Movies List
        moviesListViewModel
            .emptyList
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (message) in
                MessageBanner.sharedInstance.showBanner(message: message, theme: .success)
            }).disposed(by: disposeBag)
        // -------------------------------------- //
        
        
        /*
        Increment page number when new page is loaded.
        The new page number will be used in the next request
        */
        moviesListViewModel
            .incrementPageNumber
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (isIncrement) in
                if isIncrement {
                    self.pageNumber += 1
                }
            }).disposed(by: disposeBag)
        // -------------------------------------- //
        
        
        // Stop collection refresher
        moviesListViewModel
            .refresher
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (isRefreshing) in
                if !isRefreshing {
                    self.refresher.endRefreshing()
                }
            }).disposed(by: disposeBag)
        // -------------------------------------- //
        
        // Movies List Binding
        moviesListViewModel
            .movies
            .bind(to: movies)
            .disposed(by: disposeBag)
        // -------------------------------------- //
        
        }
    
    func presentDetailsPage(movieId: String) {
        let movieDetailsViewController = MovieDetailsViewController()
        movieDetailsViewController.id = movieId
        present(movieDetailsViewController, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Extension

extension MoviesListViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width - 20, height: 110)
        }
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0.0
        }
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 15
        }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.contentSize.height
        
        // Collection View reaches the last item?, Load the next page of the movies
        if offsetY > height - scrollView.frame.size.height {
            self.moviesListViewModel.requestMoviesList(pageNumber: String(self.pageNumber), isRefresh: false)
        }
    }
}
