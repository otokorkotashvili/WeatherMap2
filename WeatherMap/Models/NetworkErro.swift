//
//  NetworkErro.swift
//  WeatherMap
//
//  Created by MacBook Pro on 18.06.26.
//

import Foundation


enum NetworkErro : String, Error {
    case unableToCompleteNetworkCall = "Unable to complete Network Call"
    case invalidResponse = "Invalid Response"
    case invalidData = "Invalid Data"
    
}
