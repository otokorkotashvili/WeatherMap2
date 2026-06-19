//
//  NetworkService.swift
//  WeatherMap
//
//  Created by MacBook Pro on 18.06.26.
//

import Foundation

enum NetworkErro: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

final class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {}
    
    //https://api.openweathermap.org/data/4.0/onecall/current?lat=

    let baseUrl = "https://api.openweathermap.org/data/2.5/onecall"
    
    func getForecast(latitude: Double, longitude: Double) async throws -> WeatherData {
        
        print("API key length:", Keys.appId.count)

        let endpoint = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,alerts&appid=\(Keys.appId)&units=metric"
        //let endpoint = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,alerts&appid=\(Keys.appId)&units=metric"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkErro.invalidURL
        }
        
        print("URL:", endpoint)
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkErro.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Status code:", httpResponse.statusCode)
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw NetworkErro.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let weather = try decoder.decode(WeatherData.self, from: data)
            return weather
        } catch {
            print("Decoding error:", error)
            throw NetworkErro.invalidData
        }
    }
}

