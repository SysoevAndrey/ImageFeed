//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 30.12.2022.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let task {
            task.cancel()
        }
        
        let request = makeRequest(with: token)
        
        let task: URLSessionTask = urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                if let error {
                    completion(.failure(error))
                    return
                }
                
                if
                    let response = response as? HTTPURLResponse,
                    response.statusCode < 200 || response.statusCode >= 300
                {
                    completion(.failure(ProfileError.codeError))
                    return
                }
                
                guard let data else { return }
                
                do {
                    let json = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(
                        username: json.username,
                        name: "\(json.firstName) \(json.lastName)",
                        loginName: "@\(json.username)",
                        bio: json.bio
                    )
                    self.profile = profile
                    completion(.success(profile))
                } catch {
                    completion(.failure(ProfileError.decodeError))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(with token: String) -> URLRequest {
        var request = URLRequest(url: DefaultBaseURL.appendingPathComponent("me"))
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

private extension ProfileService {
    enum ProfileError: Error {
        case codeError, decodeError
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}
