//
//  AuthService.swift
//  Audioteka
//
//  Авторизация и регистрация через NSUserDefaults.
//

import Foundation

/// Учётная запись пользователя.
struct AuthUser: Codable, Equatable {
    let login: String
    let password: String
}

/// Сервис входа и хранения пользователей в NSUserDefaults.
final class AuthService {

    static let shared = AuthService()

    private let defaults = UserDefaults.standard
    private let usersKey = "audioteka_registered_users"
    private let currentUserKey = "audioteka_current_user"

    private init() {}

    var isLoggedIn: Bool {
        defaults.string(forKey: currentUserKey) != nil
    }

    var currentLogin: String? {
        defaults.string(forKey: currentUserKey)
    }

    /// Регистрирует нового пользователя.
    func register(login: String, password: String) -> AuthError? {
        let trimmedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLogin.isEmpty, !password.isEmpty else {
            return .emptyFields
        }
        var users = loadUsers()
        if users.contains(where: { $0.login.lowercased() == trimmedLogin.lowercased() }) {
            return .loginExists
        }
        users.append(AuthUser(login: trimmedLogin, password: password))
        saveUsers(users)
        defaults.set(trimmedLogin, forKey: currentUserKey)
        return nil
    }

    /// Выполняет вход.
    func login(login: String, password: String) -> AuthError? {
        let trimmedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLogin.isEmpty, !password.isEmpty else {
            return .emptyFields
        }
        let users = loadUsers()
        guard let user = users.first(where: { $0.login.lowercased() == trimmedLogin.lowercased() }),
              user.password == password else {
            return .invalidCredentials
        }
        defaults.set(user.login, forKey: currentUserKey)
        return nil
    }

    func logout() {
        defaults.removeObject(forKey: currentUserKey)
    }

    private func loadUsers() -> [AuthUser] {
        guard let data = defaults.data(forKey: usersKey) else { return [] }
        return (try? JSONDecoder().decode([AuthUser].self, from: data)) ?? []
    }

    private func saveUsers(_ users: [AuthUser]) {
        guard let data = try? JSONEncoder().encode(users) else { return }
        defaults.set(data, forKey: usersKey)
    }
}

enum AuthError {
    case emptyFields
    case loginExists
    case invalidCredentials
    case termsNotAccepted
}
