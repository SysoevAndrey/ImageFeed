//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 17.12.2022.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Views
    
    private var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "splash_screen_logo")
        return imageView
    }()
    
    // MARK: - Properties

    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            let authViewController = AuthViewController()

            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    // MARK: - Private methods
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration") }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    private func setupContent() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImage)
    }
    
    private func setupConstraints() {
        let logoImageConstraints = [
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(logoImageConstraints)
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        vc.dismiss(animated: true) { [weak self] in
            self?.oauth2Service.fetchAuthToken(code: code) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let token):
                    self.oauth2TokenStorage.token = token
                    self.switchToTabBarController()
                case .failure(_):
                    self.showErrorAlert()
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
