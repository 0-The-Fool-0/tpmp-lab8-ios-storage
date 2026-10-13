//
//  AlbumsViewController.swift
//  Audioteka
//
//  Список альбомов в UICollectionView (данные из plist).
//

import UIKit

/// Главный экран каталога альбомов.
final class AlbumsViewController: UIViewController {

    private var albums: [Album] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBackground
        collection.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.reuseId)
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("albums_title", comment: "")
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("auth_logout", comment: ""),
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        albums = PlistAlbumStore.shared.fetchAll()
        collectionView.reloadData()
    }

    @objc private func logoutTapped() {
        AuthService.shared.logout()
        if let scene = view.window?.windowScene,
           let delegate = scene.delegate as? SceneDelegate {
            delegate.showLogin()
        }
    }
}

extension AlbumsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        albums.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumCollectionViewCell.reuseId,
            for: indexPath
        ) as? AlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: albums[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = AlbumDetailViewController(album: albums[indexPath.item])
        navigationController?.pushViewController(detail, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = 2
        let inset: CGFloat = 16
        let spacing: CGFloat = 12
        let totalSpacing = inset * 2 + spacing * (columns - 1)
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width + 52)
    }
}
