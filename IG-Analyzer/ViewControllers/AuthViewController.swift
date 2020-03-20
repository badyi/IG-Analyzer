//
//  AuthViewController.swift
//  IG-Analyzer
//
//  Created by Бадый Шагаалан on 18.03.2020.
//  Copyright © 2020 Бадый Шагаалан. All rights reserved.
//

import UIKit
import WebKit

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}

class AuthViewController: UIViewController {
    
    private let authPresenter: AuthPresenter = AuthPresenter()
    weak var delegate: AuthViewControllerDelegate?
    private var credentials: Credentials = Credentials()
    private let webView = WKWebView()
    
    
    private var isTokenExisting = false {
        didSet {
            DispatchQueue.main.sync{
                performSegue(withIdentifier: "authToProfile", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        auth()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "authToProfile" else { return }
        guard let destination = segue.destination as? BaseUITabBarViewController else { return }
        destination.credentials = credentials
    }
    
    func auth() {
        authPresenter.setCred(credentials)
        
        guard let request = authPresenter.requestToGetCode() else {
            return
        }
        
        webView.load(request)
        webView.navigationDelegate = self
    }
}

extension AuthViewController: AuthPresenterViewDelegate {
    func setupViews() {
        view.backgroundColor = .white
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated {
            let alert = UIAlertController(title: "Error", message: "Smth went wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            if let url = navigationAction.request.url {
                print(url);
                
                guard let host = url.host else {
                    return
                }
                
                if host == "badyi.github.io" {
                    authPresenter.setShortLivedToken(url: url) {
                        self.authPresenter.setLongLivedToken() {
                            if self.credentials.longAccessToken != nil {
                                self.isTokenExisting = true
                            }
                        }
                    }
                }
            }
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}
