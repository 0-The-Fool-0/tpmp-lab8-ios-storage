//
//  MapViewController.swift
//  MinskParks
//
//  Интерактивная карта парков Минска (MapKit + CoreLocation).
//

import CoreLocation
import MapKit
import UIKit

/// Карта с выбором района длинным нажатием.
final class MapViewController: UIViewController {

    private let repository = DistrictRepository()
    private var selectedDistrict: District?
    private var districtAnnotations: [MKPointAnnotation] = []

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    private let districtLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = NSLocalizedString("map_hint", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let parksButton = MapViewController.makeActionButton(titleKey: "button_parks_list")
    private let weatherButton = MapViewController.makeActionButton(titleKey: "button_weather")

    private lazy var myLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.addTarget(self, action: #selector(centerOnUser), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("map_title", comment: "")
        view.backgroundColor = .systemBackground
        mapView.delegate = self
        setupLayout()
        setupMap()
        loadDistrictPins()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPress)
        parksButton.addTarget(self, action: #selector(showParks), for: .touchUpInside)
        weatherButton.addTarget(self, action: #selector(showWeather), for: .touchUpInside)
        parksButton.isEnabled = false
        weatherButton.isEnabled = false
        LocationManager.shared.requestAuthorizationIfNeeded()
    }

    private func setupLayout() {
        let buttonStack = UIStackView(arrangedSubviews: [parksButton, weatherButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let bottomStack = UIStackView(arrangedSubviews: [districtLabel, buttonStack])
        bottomStack.axis = .vertical
        bottomStack.spacing = 12
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapView)
        view.addSubview(bottomStack)
        view.addSubview(myLocationButton)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -8),
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            parksButton.heightAnchor.constraint(equalToConstant: 44),
            myLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
    }

    private func setupMap() {
        let minsk = CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590)
        let region = MKCoordinateRegion(
            center: minsk,
            latitudinalMeters: 22000,
            longitudinalMeters: 22000
        )
        mapView.setRegion(region, animated: false)
    }

    private func loadDistrictPins() {
        districtAnnotations.forEach { mapView.removeAnnotation($0) }
        districtAnnotations.removeAll()
        for district in repository.fetchAllDistricts() {
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: district.latitude, longitude: district.longitude)
            pin.title = district.name
            pin.subtitle = NSLocalizedString("district_pin_subtitle", comment: "")
            mapView.addAnnotation(pin)
            districtAnnotations.append(pin)
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        selectDistrict(at: coordinate)
    }

    private func selectDistrict(at coordinate: CLLocationCoordinate2D) {
        guard let district = repository.nearestDistrict(to: coordinate) else {
            districtLabel.text = NSLocalizedString("district_not_found", comment: "")
            selectedDistrict = nil
            parksButton.isEnabled = false
            weatherButton.isEnabled = false
            return
        }
        selectedDistrict = district
        districtLabel.text = String(
            format: NSLocalizedString("district_selected_format", comment: ""),
            district.name ?? ""
        )
        parksButton.isEnabled = true
        weatherButton.isEnabled = true
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: district.latitude, longitude: district.longitude),
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        mapView.setRegion(region, animated: true)
    }

    @objc private func showParks() {
        guard let district = selectedDistrict else { return }
        let controller = ParksListViewController(district: district)
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func showWeather() {
        guard let district = selectedDistrict else { return }
        WeatherService.shared.fetchForecast(
            latitude: district.latitude,
            longitude: district.longitude
        ) { [weak self] result in
            self?.presentWeatherResult(result, districtName: district.name ?? "")
        }
    }

    @objc private func centerOnUser() {
        LocationManager.shared.onLocationUpdate = { [weak self] location in
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 3000,
                longitudinalMeters: 3000
            )
            self?.mapView.setRegion(region, animated: true)
            self?.selectDistrict(at: location.coordinate)
        }
        LocationManager.shared.onAuthorizationDenied = { [weak self] in
            self?.showAlert(
                title: NSLocalizedString("alert_error", comment: ""),
                message: NSLocalizedString("location_denied", comment: "")
            )
        }
        LocationManager.shared.requestLocation()
    }

    private func presentWeatherResult(_ result: Result<WeatherForecast, WeatherServiceError>, districtName: String) {
        switch result {
        case .success(let forecast):
            let message = String(
                format: NSLocalizedString("weather_format", comment: ""),
                districtName,
                forecast.temperature,
                forecast.condition,
                forecast.windSpeed
            )
            showAlert(title: NSLocalizedString("weather_title", comment: ""), message: message)
        case .failure(let error):
            let message: String
            switch error {
            case .missingApiKey:
                message = NSLocalizedString("weather_missing_key", comment: "")
            case .invalidResponse:
                message = NSLocalizedString("weather_invalid_response", comment: "")
            case .network(let underlying):
                message = underlying.localizedDescription
            }
            showAlert(title: NSLocalizedString("alert_error", comment: ""), message: message)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_ok", comment: ""), style: .default))
        present(alert, animated: true)
    }

    private static func makeActionButton(titleKey: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString(titleKey, comment: ""), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let identifier = "districtPin"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.annotation = annotation
        view.markerTintColor = .systemGreen
        view.canShowCallout = true
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        selectDistrict(at: coordinate)
    }
}
