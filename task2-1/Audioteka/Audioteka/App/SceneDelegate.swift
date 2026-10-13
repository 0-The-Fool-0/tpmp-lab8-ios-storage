//
//  SceneDelegate.swift
//  Audioteka
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        if AuthService.shared.isLoggedIn {
            showAlbums()
        } else {
            showLogin()
        }
        window.makeKeyAndVisible()
    }

    func showLogin() {
        let login = LoginViewController()
        login.onAuthSuccess = { [weak self] in
            self?.showAlbums()
        }
        window?.rootViewController = UINavigationController(rootViewController: login)
    }

    func showAlbums() {
        let albums = AlbumsViewController()
        window?.rootViewController = UINavigationController(rootViewController: albums)
    }
}
