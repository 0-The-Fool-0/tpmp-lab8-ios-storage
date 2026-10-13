//
//  WeatherService.swift
//  MinskParks
//
//  Прогноз погоды через OpenWeatherMap API.
//  Документация: https://openweathermap.org/api
//

import CoreLocation
import Foundation

/// Краткий прогноз погоды.
struct WeatherForecast {
    let temperature: Int
    let condition: String
    let windSpeed: Double
}

/// Ошибки сетевого запроса к API погоды.
enum WeatherServiceError: Error {
    case missingApiKey
    case invalidResponse
    case network(Error)
}

/// Клиент OpenWeatherMap Current Weather API.
final class WeatherService {

    static let shared = WeatherService()

    private let session = URLSession.shared

    private init() {}

    /// Ключ задаётся в Info.plist как `OpenWeatherAPIKey`.
    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String
    }

    func fetchForecast(
        latitude: Double,
        longitude: Double,
        completion: @escaping (Result<WeatherForecast, WeatherServiceError>) -> Void
    ) {
        guard let key = apiKey, !key.isEmpty, key != "YOUR_OPENWEATHER_KEY" else {
            completion(.failure(.missingApiKey))
            return
        }
        let lang = Locale.current.language.languageCode?.identifier ?? "ru"
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: key),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: lang)
        ]
        guard let url = components.url else {
            completion(.failure(.invalidResponse))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(.network(error))) }
                return
            }
            guard let data,
                  let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let main = json["main"] as? [String: Any],
                  let temp = main["temp"] as? Double else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
                return
            }
            let condition = Self.parseCondition(from: json)
            let wind = Self.parseWindSpeed(from: json)
            let forecast = WeatherForecast(
                temperature: Int(temp.rounded()),
                condition: condition,
                windSpeed: wind
            )
            DispatchQueue.main.async { completion(.success(forecast)) }
        }.resume()
    }

    private static func parseCondition(from json: [String: Any]) -> String {
        guard let weather = json["weather"] as? [[String: Any]],
              let first = weather.first else {
            return NSLocalizedString("weather_unknown_condition", comment: "")
        }
        if let description = first["description"] as? String, !description.isEmpty {
            return description.capitalized
        }
        if let main = first["main"] as? String, !main.isEmpty {
            return main
        }
        return NSLocalizedString("weather_unknown_condition", comment: "")
    }

    private static func parseWindSpeed(from json: [String: Any]) -> Double {
        guard let wind = json["wind"] as? [String: Any] else { return 0 }
        if let speed = wind["speed"] as? Double { return speed }
        if let speed = wind["speed"] as? Int { return Double(speed) }
        if let speed = wind["speed"] as? NSNumber { return speed.doubleValue }
        return 0
    }
}
