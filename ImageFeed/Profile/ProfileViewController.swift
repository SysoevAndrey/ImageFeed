//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 01.12.2022.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateProfileDetails(profile: Profile)
    func showErrorAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - Layout
    
    private var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ProfileImage")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = UIFont(name: "YSDisplay-Bold", size: 23)
        label.textColor = .ypWhite
        return label
    }()
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont(name: "YSDisplay-Medium", size: 13)
        label.textColor = .ypGray
        return label
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = UIFont(name: "YSDisplay-Medium", size: 13)
        label.textColor = .ypWhite
        return label
    }()
    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "logout")!,
            target: self,
            action: #selector(didTapLogoutButton)
        )
        button.accessibilityIdentifier = "logout button"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ypRed
        return button
    }()
    
    // MARK: - Properties
    
    var presenter: ProfileViewPresenterProtocol?
    private let profileImageGradient = CAGradientLayer()
    private let nameLabelGradient = CAGradientLayer()
    private let usernameLabelGradient = CAGradientLayer()
    private let descriptionLabelGradient = CAGradientLayer()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
        
        presenter?.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if profileService.profile == nil {
            nameLabel.addSkeleton(gradient: nameLabelGradient)
            usernameLabel.addSkeleton(gradient: usernameLabelGradient)
            descriptionLabel.addSkeleton(gradient: descriptionLabelGradient)
        }
        
        if profileImageService.avatarUrl == nil {
            profileImage.addSkeleton(gradient: profileImageGradient, cornerRadius: 35)
        }
    }
    
    // MARK: - Methods
    
    func updateProfileDetails(profile: Profile) {
        nameLabel.removeSkeleton(gradient: nameLabelGradient)
        nameLabel.text = profile.name
        usernameLabel.removeSkeleton(gradient: usernameLabelGradient)
        usernameLabel.text = profile.loginName
        descriptionLabel.removeSkeleton(gradient: descriptionLabelGradient)
        descriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageUrl = ProfileImageService.shared.avatarUrl,
            let url = URL(string: profileImageUrl)
        else { return }
        
        profileImage.removeSkeleton(gradient: profileImageGradient)
        profileImage.kf.setImage(with: url)
    }
    
    private func setupContent() {
        view.backgroundColor = .ypBlack
        view.addSubview(profileImage)
        view.addSubview(logoutButton)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        let profileImageConstraints = [
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ]
        let logoutButtonConstraints = [
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ]
        let nameLabelConstraints = [
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor)
        ]
        let usernameLabelConstraints = [
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor)
        ]
        let descriptionLabelConstraints = [
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor)
        ]
        
        NSLayoutConstraint.activate(
            profileImageConstraints +
            logoutButtonConstraints +
            nameLabelConstraints +
            usernameLabelConstraints +
            descriptionLabelConstraints
        )
    }
    
    @objc
    private func didTapLogoutButton() {
        guard let alert = presenter?.makeAlert() else { return }
        present(alert, animated: true)
    }
}
