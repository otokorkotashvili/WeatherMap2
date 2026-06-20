//
//  NetworkService.swift
//  WeatherMap
//
//  Created by MacBook Pro on 18.06.26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

final class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {}
    
    //https://api.openweathermap.org/data/4.0/onecall/current?lat=

    let baseUrl = "https://api.openweathermap.org/data/4.0/onecall/current"
    
    func getCurrentWeather(latitude: Double, longitude: Double, lang: String = "en") async throws -> CurrentWeather {
        print("API key length:", Keys.appId.count)

        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: Keys.appId),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: lang)
        ]
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        print("URL:", url.absoluteString)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            print("Status code:", httpResponse.statusCode)
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw NetworkError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            let payload = try decoder.decode(CurrentWeatherResponse.self, from: data)
            guard let current = payload.data.first else {
                throw NetworkError.invalidData
            }
            return current
        } catch {
            print("Decoding error:", error)
            throw NetworkError.invalidData
        }
    }
    
    func getForecast(latitude: Double, longitude: Double) async throws -> WeatherData {
        
        print("API key length:", Keys.appId.count)

        let endpoint = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,alerts&appid=\(Keys.appId)&units=metric"
        //let endpoint = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,alerts&appid=\(Keys.appId)&units=metric"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        print("URL:", endpoint)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Status code:", httpResponse.statusCode)
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let weather = try decoder.decode(WeatherData.self, from: data)
            return weather
        } catch {
            print("Decoding error:", error)
            throw NetworkError.invalidData
        }
    }
    
    func getDailyForecast(latitude: Double, longitude: Double, lang: String = "en") async throws -> [ForecastDay] {
        var components = URLComponents(string: "https://api.openweathermap.org/data/3.0/onecall")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "exclude", value: "current,minutely,hourly,alerts"),
            URLQueryItem(name: "appid", value: Keys.appId),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: lang)
        ]
        guard let url = components?.url else { throw NetworkError.invalidURL }
        
        print("Daily URL:", url.absoluteString)
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            print("Status code:", (response as? HTTPURLResponse)?.statusCode ?? -1)
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw NetworkError.invalidResponse
        }
        do {
            let decoded = try JSONDecoder().decode(DailyForecastResponse.self, from: data)
            return Array(decoded.daily.prefix(7))
        } catch {
            print("Decoding error (daily):", error)
            throw NetworkError.invalidData
        }
    }
    
    func getFiveDayForecast(latitude: Double, longitude: Double, lang: String = "en") async throws -> [ForecastDay] {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: Keys.appId),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: lang)
        ]
        guard let url = components?.url else { throw NetworkError.invalidURL }
        
        print("5-day URL:", url.absoluteString)
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            print("Status code:", (response as? HTTPURLResponse)?.statusCode ?? -1)
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw NetworkError.invalidResponse
        }
        
        let decoded = try JSONDecoder().decode(FiveDayForecastResponse.self, from: data)
        
        // Group 3-hour entries by calendar day and compute a representative day temp and icon
        var byDay: [String: [ThreeHourForecast]] = [:]
        let cal = Calendar.current
        for item in decoded.list {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let key = String(format: "%04d-%02d-%02d", cal.component(.year, from: date), cal.component(.month, from: date), cal.component(.day, from: date))
            byDay[key, default: []].append(item)
        }
        
        var aggregated: [ForecastDay] = []
        for (_, items) in byDay {
            // Use midday-ish entries, else average all
            let midday = items.sorted { abs($0.dt - 12*3600) < abs($1.dt - 12*3600) }.first ?? items.first!
            let avgTemp = items.map { $0.main.temp }.reduce(0, +) / Double(items.count)
            let icon = (midday.weather.first?.icon) ?? items.first?.weather.first?.icon ?? "03d"
            let dt = items.first!.dt
            aggregated.append(ForecastDay(dt: dt, temp: ForecastTemp(day: avgTemp, min: nil, max: nil), weather: [WeatherCondition(id: 0, main: "", description: "", icon: icon)], pop: nil))
        }
        
        // Sort by dt ascending and take first 5-7 days
        aggregated.sort { $0.dt < $1.dt }
        return Array(aggregated.prefix(7))
    }
}

