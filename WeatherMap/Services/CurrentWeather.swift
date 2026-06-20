//
//  CurrentWeather.swift
//  WeatherMap
//
//  Created by Assistant on 20.06.26.
//
import Foundation

struct CurrentWeatherResponse: Decodable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezone_offset: Int
    let data: [CurrentWeather]
}

struct CurrentWeather: Decodable {
    let dt: Int
    let sunrise: Int?
    let sunset: Int?
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double?
    let uvi: Double?
    let clouds: Int?
    let visibility: Int?
    let wind_speed: Double?
    let wind_deg: Int?
    let wind_gust: Double?
    let weather: [WeatherCondition]
    let alerts: [String]?
}

struct WeatherCondition: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
