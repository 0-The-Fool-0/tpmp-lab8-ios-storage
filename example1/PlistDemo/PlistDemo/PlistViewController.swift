//
//  PlistViewController.swift
//  PlistDemo — пример 1.1: чтение данных из plist
//

import UIKit

struct BookItem: Codable {
    let title: String
    let author: String
}

final class PlistViewController: UIViewController, UITableViewDataSource {

    private var items: [BookItem] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Книги (plist)"
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        loadPlist()
    }

    private func loadPlist() {
        guard let url = Bundle.main.url(forResource: "books", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let decoded = try? PropertyListDecoder().decode([BookItem].self, from: data) else { return }
        items = decoded
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.author
        return cell
    }
}
