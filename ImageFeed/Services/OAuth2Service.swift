//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 16.12.2022.
//

import Foundation

final class OAuth2Service {
    private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/token"
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = makeRequest(code: code)
        
        let task = urlSession.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let json):
                completion(.success(json.accessToken))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: unsplashAuthorizeURLString) else { fatalError("Failed to create URL") }
        
        var request = URLRequest(url: url)
        
        let payload: [String: String] = [
            "client_id": AccessKey,
            "client_secret": SecretKey,
            "redirect_uri": RedirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
}
