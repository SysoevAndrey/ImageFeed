//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 06.02.2023.
//

import UIKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func makeAlert() -> UIAlertController
}

final class ProfilePresenter {
    weak var view: ProfileViewControllerProtocol?
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                self.view?.updateProfileDetails(profile: profile)
                self.profileImageService.fetchProfileImageUrl(username: profile.username) { _ in }
            case .failure(_):
                self.view?.showErrorAlert()
            }
        }
    }
    
    private func logout() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration") }
        
        OAuth2TokenStorage.clean()
        
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}

// MARK: - ProfilePresenterProtocol

extension ProfilePresenter: ProfilePresenterProtocol {
    func viewDidLoad() {
        guard let token = oauth2TokenStorage.token else { return }
        fetchProfile(token: token)
    }
    
    func makeAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        let confirmAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else { return }
            self.logout()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        return alert
    }
}
