//
//  AuthViewController.swift
//  AuthDemo — пример 1.2: NSUserDefaults
//

import UIKit

final class AuthViewController: UIViewController {

    private let segment = UISegmentedControl(items: ["Вход", "Регистрация"])
    private let loginField = UITextField()
    private let passwordField = UITextField()
    private let termsSwitch = UISwitch()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Авторизация"
        view.backgroundColor = .systemBackground
        segment.selectedSegmentIndex = 0
        [loginField, passwordField].forEach {
            $0.borderStyle = .roundedRect
            $0.autocapitalizationType = .none
        }
        passwordField.isSecureTextEntry = true
        loginField.placeholder = "Логин"
        passwordField.placeholder = "Пароль"
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        let termsRow = UIStackView(arrangedSubviews: [termsSwitch, UILabel(text: "Принимаю правила")])
        termsRow.spacing = 8
        let button = UIButton(type: .system)
        button.setTitle("Выполнить", for: .normal)
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [segment, loginField, passwordField, termsRow, button, statusLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        if UserDefaults.standard.string(forKey: "demo_user") != nil {
            statusLabel.text = "Уже авторизован: \(UserDefaults.standard.string(forKey: "demo_user")!)"
        }
    }

    @objc private func submit() {
        let login = loginField.text ?? ""
        let password = passwordField.text ?? ""
        guard !login.isEmpty, !password.isEmpty else {
            statusLabel.text = "Заполните поля"
            return
        }
        if segment.selectedSegmentIndex == 1 {
            guard termsSwitch.isOn else { statusLabel.text = "Примите правила"; return }
            UserDefaults.standard.set(password, forKey: "pwd_\(login)")
            UserDefaults.standard.set(login, forKey: "demo_user")
            statusLabel.text = "Регистрация OK"
        } else {
            let saved = UserDefaults.standard.string(forKey: "pwd_\(login)")
            if saved == password {
                UserDefaults.standard.set(login, forKey: "demo_user")
                statusLabel.text = "Вход выполнен"
            } else {
                statusLabel.text = "Неверные данные"
            }
        }
    }
}

private extension UILabel {
    convenience init(text: String) {
        self.init()
        self.text = text
    }
}
