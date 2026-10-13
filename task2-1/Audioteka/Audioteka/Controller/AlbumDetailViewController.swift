//
//  AlbumDetailViewController.swift
//  Audioteka
//
//  Детальное описание выбранного альбома.
//

import UIKit

/// Экран с подробной информацией об альбоме.
final class AlbumDetailViewController: UIViewController {

    private let album: Album

    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.title
        view.backgroundColor = .systemBackground

        let cover = UIImageView()
        cover.contentMode = .scaleAspectFit
        cover.translatesAutoresizingMaskIntoConstraints = false
        if let image = UIImage(named: album.coverImage) {
            cover.image = image
        } else {
            cover.image = UIImage(systemName: "opticaldisc.fill")
            cover.tintColor = .systemIndigo
        }

        let artistLabel = makeLabel(text: album.artist, font: .boldSystemFont(ofSize: 20))
        let yearLabel = makeLabel(
            text: String(format: NSLocalizedString("album_year_format", comment: ""), album.year),
            font: .systemFont(ofSize: 16),
            color: .secondaryLabel
        )
        let descriptionLabel = makeLabel(text: album.description, font: .systemFont(ofSize: 16))
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [cover, artistLabel, yearLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        view.addSubview(scroll)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            cover.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    private func makeLabel(text: String, font: UIFont, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
}
