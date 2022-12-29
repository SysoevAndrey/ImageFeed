//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 17.12.2022.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Vars
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthentication"
    private let showTableSegueIdentifier = "ShowTable"
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = oauth2TokenStorage.token {
            performSegue(withIdentifier: showTableSegueIdentifier, sender: nil)
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
        oauth2Service.fetchAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let token):
                    self?.oauth2TokenStorage.token = token
                    vc.dismiss(animated: true) { [weak self] in
                        self?.switchToTabBarController()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
