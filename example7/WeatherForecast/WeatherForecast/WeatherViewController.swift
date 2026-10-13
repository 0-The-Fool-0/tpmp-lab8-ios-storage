//
//  WeatherViewController.swift
//  WeatherForecast — пример 1.7: OpenWeatherMap + URLSession
//

import UIKit

final class WeatherViewController: UIViewController {

    private let cityField = UITextField()
    private let resultLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Прогноз погоды"
        view.backgroundColor = .systemBackground
        cityField.placeholder = "Город (например Minsk)"
        cityField.borderStyle = .roundedRect
        cityField.text = "Minsk"
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        let currentButton = makeButton(title: "Погода для текущей локации", action: #selector(currentWeather))
        let cityButton = makeButton(title: "Погода для города", action: #selector(cityWeather))
        let stack = UIStackView(arrangedSubviews: [cityField, cityButton, currentButton, resultLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func cityWeather() {
        guard let city = cityField.text, !city.isEmpty else { return }
        fetchWeather(query: "q=\(city)")
    }

    @objc private func currentWeather() {
        fetchWeather(query: "lat=53.9&lon=27.56")
    }

    private func fetchWeather(query: String) {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String,
              key != "YOUR_OPENWEATHER_KEY" else {
            resultLabel.text = "Укажите OpenWeatherAPIKey в Info.plist"
            return
        }
        let urlString = "https://api.openweathermap.org/data/2.5/weather?\(query)&appid=\(key)&units=metric&lang=ru"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString) else { return }
        resultLabel.text = "Загрузка..."
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error { self?.resultLabel.text = error.localizedDescription; return }
                guard let data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let main = json["main"] as? [String: Any],
                      let temp = main["temp"] as? Double,
                      let name = json["name"] as? String else {
                    self?.resultLabel.text = "Ошибка разбора ответа"
                    return
                }
                self?.resultLabel.text = "\(name): \(Int(temp))°C"
            }
        }.resume()
    }

    private func makeButton(title: String, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }
}
