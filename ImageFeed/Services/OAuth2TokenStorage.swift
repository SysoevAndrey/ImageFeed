//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 16.12.2022.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let token = newValue else { return }
            
            let isSuccess = KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            
            guard isSuccess else { fatalError() }
        }
    }
    
    private let userDefaults = UserDefaults.standard
}
