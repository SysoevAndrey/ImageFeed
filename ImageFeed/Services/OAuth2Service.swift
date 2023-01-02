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
    
    private enum OAuthError: Error {
        case codeError, decodeError
    }
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = makeRequest(code: code)
        
        let task: URLSessionTask = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                    self.lastCode = nil
                    return
                }
                
                if
                    let response = response as? HTTPURLResponse,
                    response.statusCode < 200 || response.statusCode >= 300
                {
                    completion(.failure(OAuthError.codeError))
                    return
                }
                
                guard let data else { return }
                
                do {
                    let json = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(json.accessToken))
                    self.task = nil
                } catch {
                    completion(.failure(OAuthError.decodeError))
                }
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
