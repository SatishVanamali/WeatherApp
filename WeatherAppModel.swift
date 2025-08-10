//
//  WeatherAppModel.swift
//  WeatherApp
//
//  Created by Satish Vanamali on 10/08/25.
//

import Foundation

struct CitySuggestion: Decodable, Identifiable {
    var id: String { "\(lat)-\(lon)" }
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}
