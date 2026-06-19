//
//  NetworkErro.swift
//  WeatherMap
//
//  Created by MacBook Pro on 18.06.26.
//

import Foundation


enum NetworkError : String, Error {
    case unableToCompleteNetworkCall = "Unable to complete Network Call"
    case invalidResponse = "Invalid Response"
    case invalidData = "Invalid Data"
    
}
