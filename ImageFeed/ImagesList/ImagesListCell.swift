//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 18.11.2022.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    // MARK: - Outlets
    
    @IBOutlet private weak var cellImage_old: UIImageView!
    @IBOutlet private weak var gradientView_old: UIView!
    @IBOutlet private weak var likeButton_old: UIButton!
    @IBOutlet private weak var dateLabel_old: UILabel!
    
    // MARK: - Vars
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Overriden
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage_old.kf.cancelDownloadTask()
    }
    
    // MARK: - Actions
    
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Methods
    
    func setIsLiked(_ isLiked: Bool) {
        guard let activeLikeIcon = UIImage(named: "likeActive"),
              let notActiveLikeIcon = UIImage(named: "likeNotActive") else {
            return
        }
        let likeIcon = isLiked ? activeLikeIcon : notActiveLikeIcon
        likeButton_old.setImage(likeIcon, for: .normal)
    }
    
    func setupCellContent(with photo: Photo, completion: @escaping () -> Void) {
        guard let thumbURL = URL(string: photo.thumbImageURL),
              let placeholderImage = UIImage(named: "placeholder"),
              let activeLikeIcon = UIImage(named: "likeActive"),
              let notActiveLikeIcon = UIImage(named: "likeNotActive") else {
            return
        }
        
        cellImage_old.kf.setImage(with: thumbURL, placeholder: placeholderImage) { _, _ in
            completion()
        }
        
        if let createdAt = photo.createdAt {
            dateLabel_old.text = dateFormatter.string(from: createdAt)
        }

        likeButton_old.imageView?.image = photo.isLiked ? activeLikeIcon : notActiveLikeIcon
        
        let gradient = CAGradientLayer()
        gradient.frame = gradientView_old.bounds
        gradient.colors = [
            UIColor(
                red: 26 / 255,
                green: 27 / 255,
                blue: 34 / 255,
                alpha: 0).cgColor,
            UIColor(
                red: 26 / 255,
                green: 27 / 255,
                blue: 34 / 255,
                alpha: 0.2).cgColor
        ]
        gradientView_old.layer.insertSublayer(gradient, at: 0)
    }
}
