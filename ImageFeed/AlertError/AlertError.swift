//
//  AlertError.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 27.01.2023.
//

import UIKit

struct AlertError {
    static func show(on vc: UIViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Ок", style: .cancel)

        alert.addAction(action)

        vc.present(alert, animated: true, completion: nil)
    }
}
