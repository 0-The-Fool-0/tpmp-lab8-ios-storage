//
//  LocationViewController.swift
//  LocationDemo — пример 1.3: CoreLocation
//

import CoreLocation
import UIKit

final class LocationViewController: UIViewController, CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Геолокация"
        view.backgroundColor = .systemBackground
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Нажмите кнопку для определения координат"
        label.translatesAutoresizingMaskIntoConstraints = false
        let button = UIButton(type: .system)
        button.setTitle("Получить координаты", for: .normal)
        button.addTarget(self, action: #selector(requestLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    @objc private func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        label.text = String(format: "Широта: %.5f\nДолгота: %.5f", loc.coordinate.latitude, loc.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        label.text = "Ошибка: \(error.localizedDescription)"
    }
}
