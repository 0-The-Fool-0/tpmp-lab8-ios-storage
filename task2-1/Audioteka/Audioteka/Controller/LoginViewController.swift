//
//  LoginViewController.swift
//  Audioteka
//
//  Форма авторизации и регистрации (NSUserDefaults).
//

import UIKit

/// Экран входа и регистрации.
final class LoginViewController: UIViewController {

    var onAuthSuccess: (() -> Void)?

    private enum Mode: Int {
        case login = 0
        case register = 1
    }

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            NSLocalizedString("auth_login_tab", comment: ""),
            NSLocalizedString("auth_register_tab", comment: "")
        ])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private let loginField = LoginViewController.makeField(placeholderKey: "auth_login_placeholder")
    private let passwordField = LoginViewController.makeField(placeholderKey: "auth_password_placeholder", isSecure: true)
    private let confirmPasswordField = LoginViewController.makeField(placeholderKey: "auth_confirm_password_placeholder", isSecure: true)

    private let termsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("auth_terms_label", comment: "")
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("auth_login_button", comment: ""), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let registerContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.isHidden = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("app_title", comment: "")
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        segmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        updateModeUI()
    }

    private func setupLayout() {
        let termsRow = UIStackView(arrangedSubviews: [termsSwitch, termsLabel])
        termsRow.axis = .horizontal
        termsRow.spacing = 8
        termsRow.alignment = .center

        registerContainer.addArrangedSubview(confirmPasswordField)
        registerContainer.addArrangedSubview(termsRow)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            segmentedControl,
            loginField,
            passwordField,
            registerContainer,
            actionButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func modeChanged() {
        updateModeUI()
    }

    private func updateModeUI() {
        let isRegister = segmentedControl.selectedSegmentIndex == Mode.register.rawValue
        registerContainer.isHidden = !isRegister
        actionButton.setTitle(
            isRegister
                ? NSLocalizedString("auth_register_button", comment: "")
                : NSLocalizedString("auth_login_button", comment: ""),
            for: .normal
        )
    }

    @objc private func actionTapped() {
        view.endEditing(true)
        let isRegister = segmentedControl.selectedSegmentIndex == Mode.register.rawValue
        let login = loginField.text ?? ""
        let password = passwordField.text ?? ""

        if isRegister {
            guard termsSwitch.isOn else {
                showAlert(titleKey: "alert_error", messageKey: "error_terms")
                return
            }
            guard password == confirmPasswordField.text else {
                showAlert(titleKey: "alert_error", messageKey: "error_password_mismatch")
                return
            }
            if let error = AuthService.shared.register(login: login, password: password) {
                showAuthError(error)
                return
            }
            showAlert(titleKey: "alert_success", messageKey: "success_register") { [weak self] in
                self?.onAuthSuccess?()
            }
        } else {
            if let error = AuthService.shared.login(login: login, password: password) {
                showAuthError(error)
                return
            }
            onAuthSuccess?()
        }
    }

    private func showAuthError(_ error: AuthError) {
        let key: String
        switch error {
        case .emptyFields: key = "error_empty_fields"
        case .loginExists: key = "error_login_exists"
        case .invalidCredentials: key = "error_invalid_credentials"
        case .termsNotAccepted: key = "error_terms"
        }
        showAlert(titleKey: "alert_error", messageKey: key)
    }

    private func showAlert(titleKey: String, messageKey: String, onOk: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: NSLocalizedString(titleKey, comment: ""),
            message: NSLocalizedString(messageKey, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default) { _ in
            onOk?()
        })
        present(alert, animated: true)
    }

    private static func makeField(placeholderKey: String, isSecure: Bool = false) -> UITextField {
        let field = UITextField()
        field.placeholder = NSLocalizedString(placeholderKey, comment: "")
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.isSecureTextEntry = isSecure
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return field
    }
}
