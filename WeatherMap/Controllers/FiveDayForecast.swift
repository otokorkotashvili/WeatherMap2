//
//  FiveDayForecast.swift
//  WeatherMap
//
//  Created by Assistant on 20.06.26.
//
import Foundation

struct FiveDayForecastResponse: Decodable {
    let list: [ThreeHourForecast]
}

struct ThreeHourForecast: Decodable {
    let dt: Int
    let main: MainInfo
    let weather: [WeatherCondition]
}

struct MainInfo: Decodable {
    let temp: Double
    let temp_min: Double?
    let temp_max: Double?
}
