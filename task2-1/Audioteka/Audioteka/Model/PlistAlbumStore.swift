//
//  PlistAlbumStore.swift
//  Audioteka
//
//  Загрузка каталога альбомов из файла albums.plist.
//

import Foundation

/// Хранилище альбомов, читаемое из plist в бандле приложения.
final class PlistAlbumStore {

    static let shared = PlistAlbumStore()

    private let fileName = "albums"

    private init() {}

    /// Возвращает все альбомы из plist или пустой массив при ошибке.
    func fetchAll() -> [Album] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "plist") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode([Album].self, from: data)
        } catch {
            return []
        }
    }
}
