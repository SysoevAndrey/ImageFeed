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
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let json):
                let profile = Profile(
                    username: json.username,
                    name: "\(json.firstName) \(json.lastName)",
                    loginName: "@\(json.username)",
                    bio: json.bio
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
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
