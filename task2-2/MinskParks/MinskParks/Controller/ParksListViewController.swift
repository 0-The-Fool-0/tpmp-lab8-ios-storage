//
//  ParksListViewController.swift
//  MinskParks
//
//  Список парков и мероприятий района (UITableView).
//

import MapKit
import UIKit

/// Таблица парков выбранного района с мероприятиями.
final class ParksListViewController: UIViewController {

    private let district: District
    private let repository = DistrictRepository()
    private var parks: [Park] = []

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    init(district: District) {
        self.district = district
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = district.name
        view.backgroundColor = .systemBackground
        parks = repository.parks(in: district)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "parkCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "eventCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "map"),
            style: .plain,
            target: self,
            action: #selector(showParkOnMap)
        )
    }

    @objc private func showParkOnMap() {
        guard let park = parks.first else { return }
        let coordinate = CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = park.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

extension ParksListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        parks.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        parks[section].name
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        parks[section].parkDescription
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repository.events(in: parks[section]).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let events = repository.events(in: parks[indexPath.section])
        let event = events[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = event.title
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        let dateText = formatter.string(from: event.eventDate ?? Date())
        config.secondaryText = "\(dateText) — \(event.eventDescription ?? "")"
        config.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}
