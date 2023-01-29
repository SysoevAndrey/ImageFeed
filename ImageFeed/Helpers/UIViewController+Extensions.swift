//
//  UIViewController+Extensions.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 29.01.2023.
//

import UIKit

extension UIViewController {
    func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Ок", style: .cancel)

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
}
