//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 16.12.2022.
//

import Foundation
import SwiftKeychainWrapper
import WebKit

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
    
    static func clean() {
        KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
