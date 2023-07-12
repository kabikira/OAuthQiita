//
//  ItemsViewController.swift
//  OAuthQiita
//
//  Created by koala panda on 2023/07/12.
//

import UIKit

class ItemsViewController: UIViewController {

    private let cellID = "UITableViewCell"
    @IBOutlet private weak var tableView: UITableView!

    private var qiitaItems: [QiitaItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print("sksksksks")
        API.shared.getItems {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.qiitaItems = items
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
            }
            }
        }
    }
}

extension ItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = qiitaItems[indexPath.row].url,
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension ItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qiitaItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) else {
            fatalError()
        }

        let item = qiitaItems[indexPath.row]
        cell.textLabel?.text = item.title

        return cell
    }
}
