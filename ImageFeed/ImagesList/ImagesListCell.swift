//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 18.11.2022.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Outlets
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Vars
    
    static let reuseIdentifier = "ImagesListCell"
}
