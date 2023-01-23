//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 01.12.2022.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Vars
    
    var imageURL: URL!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        setImage()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapShareButton() {
        let share = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        present(share, animated: true)
    }
    
    // MARK: - Methods
    
    func setImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let contentSize = scrollView.contentSize
        let xCenter = (contentSize.width - visibleRectSize.width) / 2
        let yCenter = (contentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: xCenter, y: yCenter), animated: false)
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Не надо", style: .default)
        let repeatAction = UIAlertAction(title: "Повторить", style: .cancel) { [weak self] _ in
            guard let self else { return }
            self.setImage()
        }
        alert.addAction(cancelAction)
        alert.addAction(repeatAction)
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
