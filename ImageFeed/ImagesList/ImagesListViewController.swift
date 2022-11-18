//
//  ViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 17.11.2022.
//

import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Vars
    
    private var imagesName = [String]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesName = Array(0..<20).map { "\($0)" }
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Methods
    
    private func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: "\(indexPath.row)"),
              let activeLikeIcon = UIImage(named: "likeActive"),
              let notActiveLikeIcon = UIImage(named: "likeNotActive") else {
            return
        }
        
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        let isEven = indexPath.row % 2 == 0
        cell.likeButton.imageView?.image = isEven ? activeLikeIcon : notActiveLikeIcon
        
        let gradient = CAGradientLayer()
        gradient.frame = cell.gradientView.bounds
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
        cell.gradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imagesName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}
