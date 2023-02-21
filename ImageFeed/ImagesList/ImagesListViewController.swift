//
//  ViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 17.11.2022.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - Layout
    
    private var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        view.backgroundColor = .ypBlack
        return view
    }()
    
    // MARK: - Properties
    
    enum CellState {
        case empty
        case loading
        case success(UIImage)
        case error
    }
    
    var presenter: ImagesListPresenterProtocol?
    private var photos: [Photo] = []
    private var tableState: [Int: CellState] = [:]
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        setupContent()
        setupConstraints()
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - Methods
    
    func updateTableViewAnimated() {
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
        guard let cellState = tableState[indexPath.row] else { return }
        
        let photo = photos[indexPath.row]
        
        guard
            let thumbURL = URL(string: photo.thumbImageURL),
            let placeholderImage = UIImage(named: "placeholder")
        else { return }
        
        switch cellState {
        case .empty:
            let skeleton = CAGradientLayer()
            cell.contentView.addSkeleton(gradient: skeleton)
            tableState[indexPath.row] = .loading
            cell.cellImage.kf.setImage(with: thumbURL, placeholder: nil) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let value):
                    cell.cellImage.image = value.image
                    self.tableState[indexPath.row] = .success(value.image)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    cell.setupCellContent(with: photo)
                case .failure:
                    cell.cellImage.image = placeholderImage
                    self.tableState[indexPath.row] = .error
                }
                cell.contentView.removeSkeleton(gradient: skeleton)
            }
        case .loading:
            return
        case .error:
            cell.cellImage.image = placeholderImage
        case .success(let image):
            cell.cellImage.image = image
            cell.setupCellContent(with: photo)
        }
    }
    
    private func setupContent() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        let tableViewConstraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(tableViewConstraints)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellState = tableState[indexPath.row] else {
            return 252
        }
        
        switch cellState {
        case .success(let image):
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = image.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        default:
            return 252
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
        
        if tableState[indexPath.row] == nil {
            tableState[indexPath.row] = .empty
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
