import Foundation
import MapKit

final class DetailViewModel {
    // Inputs
    private(set) var coordinate: CLLocationCoordinate2D

    // Outputs (observables via callbacks)
    private(set) var city: String = "" { didSet { onCityCountryChange?(city, country) } }
    private(set) var country: String = "" { didSet { onCityCountryChange?(city, country) } }
    private(set) var current: CurrentWeather? { didSet { onCurrentChange?(current) } }
    private(set) var forecasts: [ForecastDay] = [] { didSet { onForecastsChange?(forecasts) } }
    private(set) var isFavourite: Bool = false { didSet { onFavouriteChange?(isFavourite) } }

    // State callbacks
    var onLoadingChange: ((Bool) -> Void)?
    var onCityCountryChange: ((String, String) -> Void)?
    var onCurrentChange: ((CurrentWeather?) -> Void)?
    var onForecastsChange: (([ForecastDay]) -> Void)?
    var onFavouriteChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    // Dependencies
    private let coreData: CoreDataService
    private let network: NetworkService

    init(coordinate: CLLocationCoordinate2D,
         coreData: CoreDataService = .shared,
         network: NetworkService = .shared) {
        self.coordinate = coordinate
        self.coreData = coreData
        self.network = network
        // Initial evaluation
        updateFavouriteState()
    }

    func updateCoordinate(_ newValue: CLLocationCoordinate2D) {
        // Avoid redundant work if same coordinate
        if newValue.latitude == coordinate.latitude && newValue.longitude == coordinate.longitude {
            return
        }
        coordinate = newValue
        updateFavouriteState()
        resolvePlace()
        fetchWeather()
    }

    func resolvePlace() {
        let place = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        place.fetchLocationInformation { [weak self] city, country, error in
            guard let self = self, let city = city, let country = country, error == nil else { return }
            self.city = city
            self.country = country
        }
    }

    func fetchWeather(lang: String = "en") {
        guard coordinate.latitude.isFinite,
              coordinate.longitude.isFinite,
              (-90.0...90.0).contains(coordinate.latitude),
              (-180.0...180.0).contains(coordinate.longitude) else {
            onError?("Invalid coordinates.")
            onLoadingChange?(false)
            return
        }
        onLoadingChange?(true)
        Task { [coordinate] in
            do {
                let current = try await network.getCurrentWeather(latitude: coordinate.latitude, longitude: coordinate.longitude, lang: lang)
                self.current = current
                do {
                    let daily = try await network.getDailyForecast(latitude: coordinate.latitude, longitude: coordinate.longitude, lang: lang)
                    self.forecasts = daily
                } catch {
                    let fiveDay = try await network.getFiveDayForecast(latitude: coordinate.latitude, longitude: coordinate.longitude, lang: lang)
                    self.forecasts = fiveDay
                }
            } catch {
                self.onError?("Couldn't load weather. Please try again.")
                // keep previous values, but you could expose an error callback if needed
            }
            self.onLoadingChange?(false)
        }
    }

    func updateFavouriteState() {
        isFavourite = coreData.locationExists(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func toggleFavourite() {
        if isFavourite {
            coreData.deleteLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        } else {
            let safeCity = city.isEmpty ? "Unknown" : city
            let safeCountry = country.isEmpty ? "Unknown" : country
            coreData.addLocation(name: safeCity, country: safeCountry, longitude: coordinate.longitude, latitude: coordinate.latitude)
        }
        updateFavouriteState()
    }
}
