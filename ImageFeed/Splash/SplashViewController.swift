//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 17.12.2022.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    // MARK: - Vars
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthentication"
    private let showTableSegueIdentifier = "ShowTable"
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Private methods
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration") }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
    private func showAlert(on vc: UIViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Ок", style: .cancel)

        alert.addAction(action)

        vc.present(alert, animated: true, completion: nil)
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageUrl(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                self.showAlert(on: self)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
}

// MARK: - Prepare for segue

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
                    self.fetchProfile(token: token)
                case .failure(_):
                    UIBlockingProgressHUD.dismiss()
                    self.showAlert(on: vc)
                }
            }
        }
    }
}
