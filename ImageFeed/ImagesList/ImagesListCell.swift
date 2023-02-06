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
    // MARK: - Layout
    
    private var cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "like button"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "likeNotActive"), for: .normal)
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        return button
    }()
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont(name: "YS Display", size: 13)
        return label
    }()
    
    // MARK: - Vars
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overriden
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    // MARK: - Actions
    
    @objc private func didTapLikeButton() {
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
    
    func setupCellContent(with photo: Photo, completion: @escaping () -> Void) {
        guard let thumbURL = URL(string: photo.thumbImageURL),
              let placeholderImage = UIImage(named: "placeholder"),
              let activeLikeIcon = UIImage(named: "likeActive"),
              let notActiveLikeIcon = UIImage(named: "likeNotActive") else {
            return
        }
        
        cellImage.kf.setImage(with: thumbURL, placeholder: placeholderImage) { _, _ in
            completion()
        }
        
        if let createdAt = photo.createdAt {
            dateLabel.text = dateFormatter.string(from: createdAt)
        }

        likeButton.imageView?.image = photo.isLiked ? activeLikeIcon : notActiveLikeIcon
        
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
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
        gradientView.layer.addSublayer(gradient)
    }
    
    private func setupContent() {
        selectionStyle = .none
        contentView.backgroundColor = .ypBlack
        contentView.addSubview(cellImage)
        contentView.addSubview(gradientView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        let cellImageConstraints = [
            cellImage.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cellImage.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            cellImage.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ]
        let gradientViewConstraints = [
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ]
        let likeButtonConstraints = [
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 12),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -10)
        ]
        let dateLabelConstraints = [
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(
            cellImageConstraints +
            gradientViewConstraints +
            likeButtonConstraints +
            dateLabelConstraints
        )
    }
}
