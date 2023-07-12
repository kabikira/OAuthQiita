//
//  API.swift
//  OAuthQiita
//
//  Created by koala panda on 2023/07/12.
//

import Foundation

enum APIError: Error {
    case postAccessToken
    case getItems
}

final class API {
    static let shared = API()
    private init() {}

    private let host = "https://qiita.com/api/v2"
    private let clientID = "459805dbc32e8d12d9e9f544db0bd5a36074650d"
    private let clientSecret = "57673417cc5f73efbfd72e82b25239eb8c898a5d"
    let qiitState = "bb17785d811bb1913ef54b0a7657de780defaa2d"

    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // ハードコーティングを防ぐため
    // Alamofireを使わないならいらないのかなというよりURLクエリに文字を入れないからいいのか
    enum URLParameterName: String {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case scope = "scope"
        case state = "state"
        case code = "code"
    }
    // GET /api/v2/oauth/authorizeにアクセス
    var oAuthURL: URL {
        let endPoint = "/oauth/authorize"
        return URL(string: host + endPoint + "?" +
                    "\(URLParameterName.clientID.rawValue)=\(clientID)" + "&" +
                    "\(URLParameterName.scope.rawValue)=read_qiita+write_qiita" + "&" +
                    "\(URLParameterName.state.rawValue)=\(qiitState)")!
    }
    // ここをボディに直す
    func postAccessToken(code: String, completion: ((Result<QiitaAccessTokenModel, Error>) -> Void)? = nil) {
        let endPoint = "/access_tokens"
        guard let url = URL(string: host + endPoint) else {
            completion?(.failure(APIError.postAccessToken))
            return
        }
        let params = [
               "client_id": clientID,
               "client_secret": clientSecret,
               "code": code
           ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.httpMethod = "POST"

            // ただのプリントテスト
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            } else {
                print("Failed to convert data to JSON string")
            }
            let task = URLSession.shared.dataTask(with: request) { (data, request, error) in
                do {
                    guard
                        let _data = data else {
                        completion?(.failure(APIError.postAccessToken))
                        return
                    }
                    let accessToken = try API.jsonDecoder.decode(QiitaAccessTokenModel.self, from: _data)
                    completion?(.success(accessToken))

                } catch let error {
                    completion?(.failure(error))
                }
            }
            task.resume()
        } catch let error {
            completion?(.failure(error))
        }


    }

    func getItems(completion: ((Result<[QiitaItemModel], Error>) -> Void)? = nil) {
        let endPoint = "/authenticated_user/items"
        guard let url = URL(string: host + endPoint),
              !UserDefaults.standard.qiitaAccessToken.isEmpty else {
            completion?(.failure(APIError.getItems))
            return
        }
        let headers: [String: String] = [
            "Authorization": "Bearer \(UserDefaults.standard.qiitaAccessToken)"
        ]

        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "20")
        ]

        // Headerとクエリを付与する
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        var request = URLRequest(url: (components?.url)!)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, request, error) in
            do {
                guard
                    let _data = data else {
                    completion?(.failure(APIError.getItems))
                    return
                }
                let items = try API.jsonDecoder.decode([QiitaItemModel].self, from: _data)
                completion?(.success(items))
            } catch let error {
                completion?(.failure(error))
            }

        }
        task.resume()


    }
}
