//
//  AuthService.swift
//  IG-Analyzer
//
//  Created by Бадый Шагаалан on 18.03.2020.
//  Copyright © 2020 Бадый Шагаалан. All rights reserved.
//

import Foundation

struct LongLivedTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: UInt64
}

struct ShortLivedTokenResponse: Codable {
    let access_token: String
    let user_id: UInt64
}

class AuthService {
    func setShortLivedToken(_ credentials: inout Credentials, _ url: URL, completionBlock: @escaping() -> ()) {
        let urlString = url.absoluteString
        guard let components = URLComponents(string: urlString) else { return  }
        
        guard let code = components.queryItems?.first(where: {$0.name == "code"})?.value else { return }
        
        let requestHeaders: [String:String] = ["Authorization": credentials.clientSecret,
                                               "Content-Type": "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "client_id", value: credentials.clientId),
                                            URLQueryItem(name: "client_secret", value: credentials.clientSecret),
                                            URLQueryItem(name: "grant_type", value: "authorization_code"),
                                            URLQueryItem(name: "redirect_uri", value: credentials.redirectUri),
                                            URLQueryItem(name: "code", value: code)]
        
        var request = URLRequest(url: URL(string: "https://api.instagram.com/oauth/access_token")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { [weak credentials] (data, response, error) in
            if let response = response {
                print(response)
            }
            guard let data = data else {
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(ShortLivedTokenResponse.self, from: data)
                guard let credentials = credentials else { return }
                credentials.shortAccessToken = jsonResponse.access_token
                credentials.userId = jsonResponse.user_id
                completionBlock()
            } catch {
                print(error)
            }
        }).resume()
}
    
    func setLongLivedToken(_ credentials: inout Credentials, completionBlock: @escaping() -> ()) {
        guard let shortAccessToken = credentials.shortAccessToken else { return }
        
        guard var urlComponents = URLComponents(string: "https://graph.instagram.com/access_token") else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "ig_exchange_token"),
            URLQueryItem(name: "client_secret", value: credentials.clientSecret),
            URLQueryItem(name: "access_token", value: shortAccessToken)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url){ [weak credentials] (data, response, error) in
            if error != nil {
                return
            }
            
            guard response != nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                guard let credentials = credentials else { return }
                let jsonResponse = try JSONDecoder().decode(LongLivedTokenResponse.self, from: data)
                credentials.longAccessToken = jsonResponse.access_token
                credentials.expires_in = jsonResponse.expires_in
                credentials.token_type = jsonResponse.token_type
                completionBlock()
            } catch {
                print(error)
            }
        }.resume()
    }
}
