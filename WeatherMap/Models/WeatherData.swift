//
//  WeatherData.swift
//  WeatherMap
//
//  Created by MacBook Pro on 18.06.26.
//

import Foundation

struct WeatherData: Codable {
    let current: Current
    let daily: [Daily]
}

struct Current: Codable {
    let temp: Double
    let feels_like: Double
    let weather: [Weather]

    //enum CodingKeys: String, CodingKey {
      //  case temp
        //case feelsLike = "feels_like"
        //case weather
}

struct Weather: Codable {
    let description: String
    let id: Int
}

struct Daily: Codable {
    let dt: Double
    let humidity: Int
    let temp: Temp
    let weather: [Weather]
}

struct Temp: Codable {
    let day: Double
}
