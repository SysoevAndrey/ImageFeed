//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 02.01.2023.
//

import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                    return
                }
                
                if
                    let response = response as? HTTPURLResponse,
                    response.statusCode < 200 || response.statusCode >= 300
                {
                    completion(.failure(URLSessionError.codeError))
                    return
                }
                
                guard let data else { return }
                
                do {
                    let json = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(json))
                } catch {
                    completion(.failure(URLSessionError.decodeError))
                }
            }
        }
        
        return task
    }
    
    private enum URLSessionError: Error {
        case codeError, decodeError
    }
}
