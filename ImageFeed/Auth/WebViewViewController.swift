//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Andrey Sysoev on 15.12.2022.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    // MARK: - Layout
    
    private var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var progressView: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.progressTintColor = .ypBlack
        view.trackTintColor = .white
        return view
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "nav_back_button_black"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Vars
    
    weak var delegate: WebViewViewControllerDelegate?
    private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 self.updateProgress()
             })
        
        webView.navigationDelegate = self
        
        var urlComponents = URLComponents(string: unsplashAuthorizeURLString)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        
        let url = urlComponents.url!
        
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    // MARK: - Private methods
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    private func setupContent() {
        view.backgroundColor = .white
        view.addSubview(progressView)
        view.addSubview(webView)
        view.addSubview(backButton)
    }
    
    private func setupConstraints() {
        let backButtonConstraints = [
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ]
        let progressViewConstraints = [
            progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 4),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ]
        let webViewConstraints = [
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(
            backButtonConstraints +
            progressViewConstraints +
            webViewConstraints
        )
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
