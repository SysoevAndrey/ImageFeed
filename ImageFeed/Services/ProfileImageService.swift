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
        
        let task = urlSession.dataTask(with: request) { data, response, error in
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
                    completion(.failure(ProfileImageError.codeError))
                    return
                }
                
                guard let data else { return }
                
                do {
                    let json = try JSONDecoder().decode(UserResult.self, from: data)
                    let profileImageURL = json.profileImage.small
                    self.avatarUrl = profileImageURL
                    completion(.success(profileImageURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL]
                    )
                } catch {
                    completion(.failure(ProfileImageError.decodeError))
                }
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

private extension ProfileImageService {
    enum ProfileImageError: Error {
        case codeError, decodeError
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
