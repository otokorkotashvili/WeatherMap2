//
//  DailyForecast.swift
//  WeatherMap
//
//  Created by Assistant on 20.06.26.
//
import Foundation

struct DailyForecastResponse: Decodable {
    let daily: [ForecastDay]
}

struct ForecastDay: Decodable {
    let dt: Int
    let temp: ForecastTemp
    let weather: [WeatherCondition]
    let pop: Double?
}

struct ForecastTemp: Decodable {
    let day: Double
    let min: Double?
    let max: Double?
}
