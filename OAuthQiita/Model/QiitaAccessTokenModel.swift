//
//  QiitaAccessTokenModel.swift
//  OAuthQiita
//
//  Created by koala panda on 2023/07/12.
//

import Foundation

struct QiitaAccessTokenModel: Codable {
  let clientId: String
  let scopes: [String]
  let token: String
}
