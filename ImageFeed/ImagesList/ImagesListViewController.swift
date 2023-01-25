//
//  ViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 17.11.2022.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Vars
    
    private var photos: [Photo] = []
    private var imageNames = [String]()
    private var imagesListServiceObserver: NSObjectProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
        )
        
        imagesListService.fetchPhotosNextPage()
        
        imageNames = Array(0..<20).map { "\($0)" }
    }
    
    // MARK: - Methods
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func configureCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.setupCellContent(with: photo) { [weak self] in
            guard let self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        let photo = photos[indexPath.row]
        
        guard let url = URL(string: photo.largeImageURL) else { return }
        singleImageViewController.imageURL = url
        
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(for: imagesListCell, with: indexPath)
        imagesListCell.delegate = self
        return imagesListCell
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos[indexPath.row].isLiked.toggle()
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print(error)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
}
