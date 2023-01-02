//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 02.01.2023.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarUrl: String?
    
    func fetchProfileImageUrl(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let task {
            task.cancel()
        }
        
        let request = makeRequest(username: username)
        
        let task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let json):
                let profileImageURL = json.profileImage.small
                self.avatarUrl = profileImageURL
                
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(username: String) -> URLRequest {
        guard let token = OAuth2TokenStorage().token else { fatalError("No token provided") }
        
        var request = URLRequest(url: DefaultBaseURL.appendingPathComponent("/users/\(username)"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}
