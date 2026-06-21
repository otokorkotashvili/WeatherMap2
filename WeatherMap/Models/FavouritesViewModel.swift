//
//  FavouritesViewModel.swift
//  WeatherMap
//
//  Created by Assistant on 20.06.26.
//
import Foundation
internal import CoreData
import MapKit

final class FavouritesViewModel {
    // Exposed read-only favourites array for the view layer
    private(set) var locations: [Favourites] = []

    // Callbacks to notify the view when data changes
    var onChange: (() -> Void)?

    private let coreData: CoreDataService
    private var notificationObserver: NSObjectProtocol?

    init(coreData: CoreDataService = .shared) {
        self.coreData = coreData
        // Initial load
        reload()
        // Observe Core Data context changes to keep favourites in sync
        notificationObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reload()
        }
    }

    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func reload() {
        locations = coreData.fetchLocations()
        onChange?()
    }

    // Convenience accessors
    func numberOfItems() -> Int { locations.count }
    func item(at indexPath: IndexPath) -> Favourites { locations[indexPath.item] }
}
