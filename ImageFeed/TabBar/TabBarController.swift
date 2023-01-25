//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 19.01.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .ypBlack
        tabBar.barTintColor = .ypBlack
        tabBar.tintColor = .white
        
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        viewControllers = [imagesListViewController, profileViewController]
    }
}
