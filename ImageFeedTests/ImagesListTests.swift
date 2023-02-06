//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Andrey Sysoev on 06.02.2023.
//

import XCTest
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled = false
    var view: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
