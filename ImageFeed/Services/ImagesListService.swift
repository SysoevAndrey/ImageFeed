//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 19.01.2023.
//

import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionDataTask?
    
    func fetchPhotosNextPage() {
        if task != nil {
            return
        }
        
        let nextPage = lastLoadedPage != nil ? 1 : lastLoadedPage! + 1
        let request = makeRequest(for: nextPage)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotosResult], Error>) in
            switch result {
            case .success(let photosResult):
                photosResult.forEach { photoResult in
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: photoResult.createdAt,
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.photos.append(photo)
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Photos": self.photos]
                        )
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func makeRequest(for nextPage: Int) -> URLRequest {
        guard let token = OAuth2TokenStorage().token else { fatalError("No token provided") }
        
        var request = URLRequest(url: DefaultBaseURL.appendingPathComponent("/photos?page=\(nextPage)&per_page=10"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ImagesListService {
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
    }
    
    private struct PhotosResult: Decodable {
        let id: String
        let width: CGFloat
        let height: CGFloat
        let createdAt: Date
        let description: String
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
    
    private struct UrlsResult: Decodable {
        let full: String
        let thumb: String
    }
}
