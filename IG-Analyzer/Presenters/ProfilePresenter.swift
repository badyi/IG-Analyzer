//
//  ProfilePresenter.swift
//  IG-Analyzer
//
//  Created by Бадый Шагаалан on 18.03.2020.
//  Copyright © 2020 Бадый Шагаалан. All rights reserved.
//

import Foundation

protocol ProfilePresenterViewDelegate: NSObjectProtocol {
    func setupProfileView()
    func setupMainInfo()
}

class ProfilePresenter {
    private let profileService: ProfileService
    weak var profilePresenterViewDelegate: ProfilePresenterViewDelegate?
    var profile: Profile
    var credentials: Credentials?
    
    init() {
        profileService = ProfileService()
        profile = Profile()
    }
    
    func setCredentials(_ credentials: Credentials?){
        self.credentials = credentials
    }
    
    func getMainUserInfo(completionBlock: @escaping() -> ()) {
        guard let credentials = credentials else { return } 
        profileService.getMainProfileInfo(credentials, &profile) {
            completionBlock()
        }
    }
    
    func getUserName() -> String? {
        guard let nick = profile.userName else { return nil }
        return nick
    }
    
    func getPostsCount() -> Int? {
        guard let count = profile.postsCount else { return nil }
        return count
    }
    
    func getAccountType() -> String? {
        guard let type = profile.accountType else { return nil }
        return type
    }
}

