//
//  Album.swift
//  Audioteka
//
//  Лабораторная работа №8, вариант 3 (задание 2.1)
//  Автор: студент группы ПИ
//

import Foundation

/// Модель музыкального альбома из plist.
struct Album: Codable, Hashable {
    let id: String
    let title: String
    let artist: String
    let year: Int
    let coverImage: String
    let description: String
}
