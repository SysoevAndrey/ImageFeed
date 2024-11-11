//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 19.01.2023.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private let formatter = ISO8601DateFormatter()
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchPhotosNextPage() {
        if task != nil {
            return
        }
        
        let nextPage = lastLoadedPage.map { $0 + 1 } ?? 1
        let request = makeRequest(for: nextPage)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photosResult):
                photosResult.forEach { photoResult in
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self.formatter.date(from: photoResult.createdAt),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        regularImageURL: photoResult.urls.regular,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                    
                    self.photos.append(photo)
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["Photos": self.photos]
                )
                self.task = nil
                self.lastLoadedPage = nextPage
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        enum LikeError: Error {
            case photoNotFound
        }
        
        let request = makeRequest(for: photoId, isLike: isLike)
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        regularImageURL: photo.regularImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                    completion(.success(()))
                } else {
                    completion(.failure(LikeError.photoNotFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func makeRequest(for nextPage: Int) -> URLRequest {
        guard let token = OAuth2TokenStorage().token else { fatalError("No token provided") }
                
        guard var urlComponents = URLComponents(url: DefaultBaseURL, resolvingAgainstBaseURL: false) else { fatalError() }
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeRequest(for photoId: String, isLike: Bool) -> URLRequest {
        guard let token = OAuth2TokenStorage().token else { fatalError("No token provided") }
        
        guard var urlComponents = URLComponents(url: DefaultBaseURL, resolvingAgainstBaseURL: false) else { fatalError() }
        urlComponents.path = "/photos/\(photoId)/like"
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let regularImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

private extension ImagesListService {
    struct PhotoResult: Decodable {
        let id: String
        let width: Int
        let height: Int
        let createdAt: String
        let description: String?
        let urls: UrlsResult
        let likedByUser: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case width
            case height
            case createdAt = "created_at"
            case description
            case urls
            case likedByUser = "liked_by_user"
        }
    }
    
    struct UrlsResult: Decodable {
        let full: String
        let regular: String
        let thumb: String
    }
    
    struct LikeResult: Decodable {
        let photo: PhotoResult
    }
}
