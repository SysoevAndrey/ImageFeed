//
//  Constants.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 15.12.2022.
//

import Foundation

let AccessKey = "x_1HVdzZP5QZYmnJuyrc6k5KC6ShRuuskFBHu7A2p5Y"
let SecretKey = "85T5gNlU9cpY1BRHNmDWC-jxW3jx0iEotjpLYty3MGQ"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"

var DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    static var standard: AuthConfiguration {
        AuthConfiguration(
            accessKey: AccessKey,
            secretKey: SecretKey,
            redirectURI: RedirectURI,
            accessScope: AccessScope,
            defaultBaseURL: DefaultBaseURL,
            authURLString: unsplashAuthorizeURLString
        )
    }
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
