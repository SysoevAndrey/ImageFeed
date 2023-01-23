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
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Vars
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Overriden
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
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
        likeButton.setImage(likeIcon, for: .normal)
    }
}
