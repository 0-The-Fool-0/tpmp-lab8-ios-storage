//
//  DistrictRepository.swift
//  MinskParks
//

import CoreData
import CoreLocation

/// Поиск районов и парков в Core Data.
final class DistrictRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetchAllDistricts() -> [District] {
        let request = District.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    /// Ближайший район к указанным координатам (в пределах ~6 км).
    func nearestDistrict(to coordinate: CLLocationCoordinate2D) -> District? {
        let districts = fetchAllDistricts()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let matched = districts
            .map { district -> (District, CLLocationDistance) in
                let districtLocation = CLLocation(latitude: district.latitude, longitude: district.longitude)
                return (district, location.distance(from: districtLocation))
            }
            .sorted { $0.1 < $1.1 }
        guard let best = matched.first, best.1 < 6000 else { return nil }
        return best.0
    }

    func parks(in district: District) -> [Park] {
        let set = district.parks as? Set<Park> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    func events(in park: Park) -> [ParkEvent] {
        let set = park.events as? Set<ParkEvent> ?? []
        return set.sorted { ($0.eventDate ?? .distantPast) < ($1.eventDate ?? .distantPast) }
    }
}
