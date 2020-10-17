//
//  MovieCollectionViewCell.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 13/10/2020.
//

import UIKit
import SnapKit

class MovieCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    public var movie: Movie! {
        didSet {
            self.title.text = movie.title.trunc(length: 22, trailing: "...")
            self.caption.text = "Popularity: " + String(movie.popularity)
            self.image.loadImage(imageURL: baseImageUrl, path: ((movie.poster_path ?? movie.backdrop_path) ?? ""))
            SetUpUI()
        }
    }

    // MARK: - Views
    var image:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        label.clipsToBounds = true
        label.textColor = #colorLiteral(red: 0.168627451, green: 0.2196078431, blue: 0.2862745098, alpha: 1)
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let caption: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = true
        label.textColor = .gray
        label.lineBreakMode = .byWordWrapping
        return label
    }()


    // MARK: - Methods
    func SetUpUI() {

        backgroundColor = .white
        layer.cornerRadius = 8
        layer.shadowColor = #colorLiteral(red: 0.6352941176, green: 0.6352941176, blue: 0.6352941176, alpha: 1)


        self.addSubview(image)
        image.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.top).offset(12)
            make.leading.equalTo(self.snp.leading).offset(8)
            make.bottom.equalTo(self.snp.bottom).offset(-8)
            make.width.equalTo(100)
            make.height.equalTo(72)
            }

        self.addSubview(title)
        title.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp.top).offset(12)
            make.leading.equalTo(image.snp.trailing).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-8)
            
            }

        self.addSubview(caption)
        caption.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.leading.equalTo(image.snp.trailing).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-18)
            }
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        SetUpUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
