//
//  MovieDetailsViewController.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 13/10/2020.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import SnapKit

class MovieDetailsViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    
    // MARK: - Properties
    lazy var contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 200)
    lazy var posterHeight: CGFloat = (UIScreen.main.bounds.height) * 0.50
    
    var movie = PublishSubject<Movie>()
    
    let disposeBag = DisposeBag()
    
    var movieService = MovieService()
    let movieDetailsViewModel: MovieDetailsViewModel
    
    // id waiting for a value to request movies data
    var id: String {
        didSet {
            if !id.isEmpty {
                loadMovie(movieId: id)
            }
        }
    }
    
    
    // MARK: - Views
    lazy var contentScrollView: UIScrollView = {
        let scrollView =  UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.contentSize = contentSize
        scrollView.autoresizingMask = .flexibleHeight
        scrollView.bounces = true
        return scrollView
    }()
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.frame.size = contentSize
        return container
    }()
    
    let headerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = UIColor.hexStringToUIColor(hex: "#fafafa")
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.textColor = UIColor.hexStringToUIColor(hex: "#31456A")
        label.font = UIFont(name: "ArialMT", size: 25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BOOK", for: .normal)
        button.backgroundColor =  UIColor.hexStringToUIColor(hex: "#31456A")
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let generLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.text = "Gener(s): "
        label.textColor = UIColor.hexStringToUIColor(hex: "##CBDDEF")
        label.font = UIFont(name: "ArialMT", size: 17.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var durationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.text = "Duration: "
        label.textColor = UIColor.hexStringToUIColor(hex: "##CBDDEF")
        label.font = UIFont(name: "ArialMT", size: 17.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var languageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.text = ""
        label.textColor = UIColor.hexStringToUIColor(hex: "##CBDDEF")
        label.font = UIFont(name: "ArialMT", size: 17.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Synopsis"
        label.textColor = UIColor.hexStringToUIColor(hex: "#364256")
        label.font = UIFont(name: "ArialMT", size: 25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let errorMessage: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.textColor = UIColor.hexStringToUIColor(hex: "#364256")
        label.font = UIFont(name: "ArialMT", size: 25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionContent: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.textColor = UIColor.hexStringToUIColor(hex: "#364256")
        label.font = UIFont(name: "ArialMT", size: 15)
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    init(){
        
        // Initialize movieDetailsViewModel with Injecting MovieService Instance
        self.movieDetailsViewModel = MovieDetailsViewModel(movieService: self.movieService)
        
        self.id = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "#BDC4CC")
        title = "Details"
        setupBinding()
    }
    
    
    // MARK: - Methods
    func setupBinding() {
        
        // Loading
        movieDetailsViewModel
            .loading
            .bind(to: self.rx.isAnimating).disposed(by: disposeBag)
        // -------------------------------------- //
        
        // Error Messages
        movieDetailsViewModel
            .error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (error) in
                self.errorMessage.isHidden = false
                switch error {
                case .internetError(let message):
                    self.errorMessage.text = message
                case .serverMessage(let message):
                    self.errorMessage.text = message
                }
            }).disposed(by: disposeBag)
        // -------------------------------------- //
        
        // Movie Binding
        movieDetailsViewModel
            .movie
            .bind(to: movie).disposed(by: disposeBag)
        
        movieDetailsViewModel
            .movie
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (movie) in
                self.containerView.isHidden = false
                self.descriptionContent.text = movie.overview
                self.titleLabel.text = movie.title
                if let language = movie.original_language {
                    self.languageLabel.text = "Language: " + language.uppercased()
                }
                if let runtime = movie.runtime {
                    self.durationLabel.text = self.returnHours(runtime: runtime)
                }
                
                if let geners = movie.genres {
                    self.generLabel.text = self.returnGeners(geners: geners)
                }
                
                self.headerImage.loadImage(imageURL: "https://image.tmdb.org/t/p/w500", path: ((movie.poster_path) ?? ""))
            }).disposed(by: disposeBag)
        // Error Messages
        
    }
    
    func loadMovie(movieId: String) {
        self.containerView.isHidden = true
        self.errorMessage.isHidden = true
        self.movieDetailsViewModel.requestMovie(movieId: self.id)
        setUPUI()
    }
    
    
    func setUPUI() {
        
        view.addSubview(errorMessage)
        errorMessage.isHidden = true
        errorMessage.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
        }
        
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(containerView)
        
        containerView.addSubview(headerImage)
        headerImage.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentScrollView.snp.top).offset(0)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(posterHeight)
        }
        
        containerView.addSubview(bookButton)
        bookButton.addTarget(self, action: #selector(redirectToBooking), for: .touchUpInside)
        bookButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(headerImage.snp.bottom).offset(20)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(headerImage.snp.bottom).offset(20)
            make.trailing.equalTo(bookButton.snp.leading).offset(0)
            make.leading.equalTo(view.snp.leading).offset(16)
        }
        
        containerView.addSubview(generLabel)
        generLabel.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-50)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        containerView.addSubview(languageLabel)
        languageLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(generLabel.snp.bottom).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.leading.equalTo(view.snp.leading).offset(16)
        }
        
        containerView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo((languageLabel).snp.bottom).offset(5)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
        }
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(durationLabel.snp.bottom).offset(10)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.leading.equalTo(view.snp.leading).offset(16)
        }
        
        containerView.addSubview(descriptionContent)
        descriptionContent.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.leading.equalTo(view.snp.leading).offset(16)
        }
    }
    
    
    @objc func redirectToBooking(_: Any) {
        let webViewController = WebViewController(url: "https://www.cathaycineplexes.com.sg/")
        present(webViewController, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
