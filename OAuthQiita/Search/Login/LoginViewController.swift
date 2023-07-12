//
//  LoginViewController.swift
//  OAuthQiita
//
//  Created by koala panda on 2023/07/12.
//

import UIKit

class LoginViewController: UIViewController {


    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(tapLoginButton), for: .touchUpInside)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func openURL(_ url: URL) {
        guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
              let code = queryItems.first(where: {$0.name == "code"})?.value,
              let getState = queryItems.first(where: {$0.name == "state"})?.value,
              getState == API.shared.qiitState
        else {
            return
        }
        API.shared.postAccessToken(code: code) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):
                    UserDefaults.standard.qiitaAccessToken = accessToken.token
                    let vc = UIStoryboard.init(name: "Items", bundle: nil).instantiateInitialViewController()!
                    self.navigationController?.pushViewController(vc, animated: true)
                case .failure(let error):
                    print(error)

                }
            }
        }
    }
}

private extension LoginViewController {
    @objc func tapLoginButton() {
        UIApplication.shared.open(API.shared.oAuthURL, options: [:], completionHandler: nil)
    }
}

