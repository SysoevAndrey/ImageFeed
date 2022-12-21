//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 16.12.2022.
//

import Foundation

fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/token"

final class OAuth2Service {
    private enum OAuthError: Error {
        case codeError, decodeError
    }
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: UnsplashAuthorizeURLString)!
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
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            if
                let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode > 299
            {
                completion(.failure(OAuthError.codeError))
                return
            }
            
            guard let data else { return }
            
            do {
                let json = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                completion(.success(json.accessToken))
            } catch {
                completion(.failure(OAuthError.decodeError))
            }
        }
        
        task.resume()
    }
}
