//
//  AuthPresenter.swift
//  IG-Analyzer
//
//  Created by Бадый Шагаалан on 18.03.2020.
//  Copyright © 2020 Бадый Шагаалан. All rights reserved.
//

import Foundation

protocol AuthPresenterViewDelegate: NSObjectProtocol {
    func setupViews()
}

protocol AuthPresenterProtocol {
    func setShortLivedToken(url: URL, completionBlock: @escaping () -> ())
    func setLongLivedToken(completionBlock: @escaping () -> ())
}

class AuthPresenter: AuthPresenterProtocol {
    
    private let authService: AuthService = AuthService()
    weak private var authPresenterViewDelegate: AuthPresenterViewDelegate?
    private var credentials: Credentials?
    
    func setCred(_ credentials: Credentials?) {
        self.credentials = credentials
    }
    
    func requestToGetCode() -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.instagram.com/oauth/authorize") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: self.credentials?.clientId),
            URLQueryItem(name: "redirect_uri", value: self.credentials?.redirectUri),
            URLQueryItem(name: "scope", value: "user_profile,user_media"),
            URLQueryItem(name: "response_type", value: "code")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    func setShortLivedToken(url: URL, completionBlock: @escaping () -> ()) {
        guard var credentials = self.credentials else {
            return
        }
        authService.setShortLivedToken(&credentials, url) {
            completionBlock()
        }
    }
    
    func setLongLivedToken(completionBlock: @escaping () -> ()) {
        guard var credentials = credentials else {
            return
        }
        authService.setLongLivedToken(&credentials) {
            completionBlock()
        }
    }
}
