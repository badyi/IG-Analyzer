//
//  Credentials.swift
//  IG-Analyzer
//
//  Created by Бадый Шагаалан on 18.03.2020.
//  Copyright © 2020 Бадый Шагаалан. All rights reserved.
//

import Foundation

class Credentials {
    let clientId = "142882310372882"
    let clientSecret = "82f3aa775114c2ecbe972d8fee84e130"
    let redirectUri = "https://badyi.github.io/"
    var userId: UInt64? = nil
    var shortAccessToken: String?
    var longAccessToken: String?
    var token_type: String?
    var expires_in: UInt64?
}
