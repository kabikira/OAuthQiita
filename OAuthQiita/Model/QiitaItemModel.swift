//
//  QiitaItemModel.swift
//  OAuthQiita
//
//  Created by koala panda on 2023/07/12.
//

import Foundation

struct QiitaItemModel: Codable {
    var urlStr: String
    var title: String

    enum CodingKeys: String, CodingKey {
        case urlStr = "url"
        case title = "title"
    }
    var url: URL? { URL.init(string: urlStr)}
}
