//
//  MapDemoViewController.swift
//  MapDemo — пример 1.4: MapKit + CoreLocation
//

import CoreLocation
import MapKit
import UIKit

final class MapDemoViewController: UIViewController, MKMapViewDelegate {

    private let mapView = MKMapView()
    private let infoLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Карта"
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 0
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        view.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            infoLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        let minsk = CLLocationCoordinate2D(latitude: 53.9, longitude: 27.56)
        mapView.setRegion(MKCoordinateRegion(center: minsk, latitudinalMeters: 8000, longitudinalMeters: 8000), animated: false)
        infoLabel.text = "Долгое нажатие — поставить метку и определить город"
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        mapView.addGestureRecognizer(longPress)
    }

    @objc private func onLongPress(_ g: UILongPressGestureRecognizer) {
        guard g.state == .began else { return }
        let point = g.location(in: mapView)
        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] marks, _ in
            let city = marks?.first?.locality ?? "не определён"
            DispatchQueue.main.async {
                self?.infoLabel.text = String(format: "Координаты: %.4f, %.4f\nГород: %@", coord.latitude, coord.longitude, city)
            }
        }
    }
}
