//
//  WeatherAppViewModel.swift
//  WeatherApp
//
//  Created by Satish Vanamali on 10/08/25.
//

import Foundation
import Combine

class WeatherAppViewModel: ObservableObject {
    private let apiKey = "TestAPIKey"
    @Published var suggestions: [CitySuggestion] = []
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var cityName: String = ""
    @Published var temperature: Double = 0
    @Published var weatherDescription: String = ""
    @Published var iconString: String? = nil
    @Published var searchHistory: Set<String> = []
    private let historyKey = "SearchHistory"
    
    private var cancellables = Set<AnyCancellable>()
    
    
    func fetchSuggestions(for city: String) {
        guard !city.isEmpty else {
            suggestions = []
            return
        }
//        construct the url with city name and limit 5 and along with APIKey
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=5&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            handleError(.unknownError(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result in
//         confirm the response and check it as http response and its status is 200
                guard let response = result.response as? HTTPURLResponse else {
                    throw WeatherAPIError.unknownError(URLError(.badServerResponse))
                }
                guard response.statusCode == 200 else {
                    throw WeatherAPIError.serverError(statusCode: response.statusCode)
                }
               
                return result.data
            }
            .decode(type: [CitySuggestion].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
//                    handle error and show in a alert
                    self?.handleError(self?.mapError(error) ?? .unknownError(error))
                case .finished:
                    break
                }
            } receiveValue: { [weak self] cities in
                self?.suggestions = cities
            }
            .store(in: &cancellables)
    }
    
    private func mapError(_ error: Error) -> WeatherAPIError {
        if error is URLError {
            return .networkError
        } else if let _ = error as? DecodingError {
            return .decodingError
        } else if let weatherError = error as? WeatherAPIError {
            return weatherError
        } else {
            return .unknownError(error)
        }
    }

    private func handleError(_ error: WeatherAPIError) {
        alertMessage = error.errorDescription
        showAlert = true
    }
    
    func fetchWeather(for city: String) {
        guard !city.isEmpty else {
            handleError(.unknownError(URLError(.badURL)))
            return
        }
        
        let cityQuery = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityQuery)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            handleError(.unknownError(URLError(.badURL)))
            return
        }
        
        isLoading = true
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result in
//         confirm the response and check it as http response and its status is 200
                guard let response = result.response as? HTTPURLResponse else {
                    throw WeatherAPIError.unknownError(URLError(.badServerResponse))
                }
                guard response.statusCode == 200 else {
                    throw WeatherAPIError.serverError(statusCode: response.statusCode)
                }
                return result.data
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.handleError(self?.mapError(error) ?? .unknownError(error))
                }
            } receiveValue: { [weak self] weatherData in
                guard let self = self else { return}
                updateSearchHistory(cityName: cityQuery)
                cityName = weatherData.name
                temperature = weatherData.main.temp
                weatherDescription = weatherData.weather.first?.description ?? "No description"
                iconString = weatherData.weather.first?.icon
            }
            .store(in: &cancellables)
    }
    
    func removeHistory(_ item: String) {
        searchHistory.remove(item)
        saveSearchHistory()
    }

    private func saveSearchHistory() {
        let arrayToSave = Array(searchHistory)
        UserDefaults.standard.set(arrayToSave, forKey: historyKey)
    }

    func loadSearchHistory() {
        if let savedArray = UserDefaults.standard.array(forKey: historyKey) as? [String] {
            searchHistory = Set(savedArray)
        }
    }


    private func updateSearchHistory(cityName:String) {
        if let decodedCity = cityName.removingPercentEncoding {
            searchHistory.insert(decodedCity)
        } else {
            searchHistory.insert(cityName)
        }
        saveSearchHistory()
    }
    
}
