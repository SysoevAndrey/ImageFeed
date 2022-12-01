//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 01.12.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var usernameLabel: UIStackView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func didTapLogoutButton() {
    }
}
