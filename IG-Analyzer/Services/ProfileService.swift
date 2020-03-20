//
//  ProfileService.swift
//  IG-Analyzer
//
//  Created by Бадый Шагаалан on 18.03.2020.
//  Copyright © 2020 Бадый Шагаалан. All rights reserved.
//

import Foundation

struct MainProfileInfo: Codable {
    let id: String
    let account_type: String
    let media_count: Int
    let username: String
}

class ProfileService {
    func getMainProfileInfo(_ credentials: Credentials, _ profile: inout Profile, completionBlock: @escaping() -> ()) {
        guard var urlComponents = URLComponents(string: "https://graph.instagram.com/\(credentials.userId!)") else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "fields", value: "id,account_type,media_count,username"),
            URLQueryItem(name: "access_token", value: credentials.longAccessToken)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url){ [weak profile] (data, response, error) in
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
                let jsonResponse = try JSONDecoder().decode(MainProfileInfo.self, from: data)
                profile?.userId = jsonResponse.id
                profile?.accountType = jsonResponse.account_type
                profile?.postsCount = jsonResponse.media_count
                profile?.userName = jsonResponse.username
                completionBlock()
            } catch {
                print(error)
            }
        }.resume()
    }
}
