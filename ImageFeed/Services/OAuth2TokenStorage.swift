//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 16.12.2022.
//

import Foundation

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    private let userDefaults = UserDefaults.standard
}
