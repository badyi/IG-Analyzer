//
//  ProfileViewController.swift
//  IG-Analyzer
//
//  Created by Бадый Шагаалан on 18.03.2020.
//  Copyright © 2020 Бадый Шагаалан. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var accountTypeLabel: UILabel!
    
    @IBOutlet weak var usernameLowerLabel: UILabel!
    @IBOutlet weak var usernameTopLabel: UILabel!
    
    @IBOutlet weak var postsCount: UILabel!
    
    var credentials: Credentials?
    private var profilePresenter: ProfilePresenter = ProfilePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarVC = self.tabBarController as! BaseUITabBarViewController
        guard let cred = tabBarVC.credentials else { return }
        self.credentials = cred
        profilePresenter.setCredentials(self.credentials)
        profilePresenter.getMainUserInfo() {
            self.setupMainInfo()
        }
    }    
}

extension ProfileViewController: ProfilePresenterViewDelegate {
    func setupProfileView() {
        DispatchQueue.main.sync {
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.clipsToBounds = true
        }
    }
    
    func setupMainInfo() {
        DispatchQueue.main.sync {
            usernameTopLabel.text = profilePresenter.getUserName()
            usernameLowerLabel.text = profilePresenter.getUserName()
            accountTypeLabel.text = profilePresenter.getAccountType()
            postsCount.text = "\(profilePresenter.getPostsCount()!)"
        }
    }
}
