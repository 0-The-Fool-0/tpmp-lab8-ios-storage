//
//  StudentsViewController.swift
//  StudentsCoreData — пример 1.6
//

import CoreData
import UIKit

final class StudentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var students: [Student] = []
    private let tableView = UITableView()
    private let nameField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Студенты"
        nameField.placeholder = "Введите Фамилию и Имя студента"
        nameField.borderStyle = .roundedRect
        let addButton = UIButton(type: .system)
        addButton.setTitle("Добавить студента", for: .normal)
        addButton.addTarget(self, action: #selector(addStudent), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        [nameField, addButton, tableView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        view.addSubview(nameField)
        view.addSubview(addButton)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        fetch()
    }

    private func fetch() {
        let request = Student.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        students = (try? Persistence.shared.context.fetch(request)) ?? []
        tableView.reloadData()
    }

    @objc private func addStudent() {
        guard let text = nameField.text, !text.isEmpty else { return }
        let student = Student(context: Persistence.shared.context)
        student.name = text
        Persistence.shared.save()
        nameField.text = ""
        view.endEditing(true)
        fetch()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { students.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = students[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        Persistence.shared.context.delete(students[indexPath.row])
        Persistence.shared.save()
        fetch()
    }
}
