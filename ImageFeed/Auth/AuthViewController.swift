//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 15.12.2022.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    // MARK: - Vars
    
    weak var delegate: AuthViewControllerDelegate?
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Overriden
    
    @IBAction func didTapLoginButton() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .overFullScreen
        present(webViewViewController, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
