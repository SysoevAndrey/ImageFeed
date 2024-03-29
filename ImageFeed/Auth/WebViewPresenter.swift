//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 05.02.2023.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter {
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1) <= 0.0001
    }
}

// MARK: - WebViewPresenterProtocol

extension WebViewPresenter: WebViewPresenterProtocol {
    func viewDidLoad() {
        let request = authHelper.authRequest()
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
