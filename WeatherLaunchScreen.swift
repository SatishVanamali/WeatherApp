//
//  WeatherLaunchScreen.swift
//  WeatherApp
//
//  Created by Satish Vanamali on 07/08/25.
//

import SwiftUI

struct WeatherLaunchScreen: View {
    @StateObject var weatherAppVM = WeatherAppViewModel()
    @State private var searchField: String = ""

    var body: some View {
        VStack {
            Text("Weather App")
                .font(.largeTitle)
            Text("Search Weather Forecast by City.")
                .font(.subheadline)

            HStack {
                TextField("Search by city name", text: $searchField)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchField) {
                        weatherAppVM.fetchSuggestions(for: searchField)
                    }
                    .padding(.trailing, 5)

                if !searchField.isEmpty {
                    Button(action: {
                        searchField = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            if !weatherAppVM.suggestions.isEmpty {
                List(weatherAppVM.suggestions) { city in
                    Text("\(city.name), \(city.country)")
                        .onTapGesture {
                            searchField = city.name
                            weatherAppVM.suggestions.removeAll()
                        }
                }
                .listStyle(.plain)
                .frame(maxHeight: 200)
            }
            
            HistoryView(searchField: $searchField)

            Button("Get Weather") {
                weatherAppVM.fetchWeather(for: searchField)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)

            if weatherAppVM.isLoading {
                ProgressView()
                    .padding()
            }

            Spacer()

            if !weatherAppVM.cityName.isEmpty {
                WeatherDetails()
            }

            Spacer()
        }
        .environmentObject(weatherAppVM)
        .padding()
        .alert("Error", isPresented: $weatherAppVM.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(weatherAppVM.alertMessage ?? "Unknown error")
        }
        .onAppear() {
            weatherAppVM.loadSearchHistory()
        }
    }
}

struct WeatherDetails: View {
    @EnvironmentObject var weatherAppVM: WeatherAppViewModel

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("City:")
                    .bold()
                Spacer()
                Text(weatherAppVM.cityName)
            }
            HStack {
                Text("Temperature (°C):")
                    .bold()
                Spacer()
                Text(String(format: "%.1f", weatherAppVM.temperature))
            }
            HStack(spacing: 10) {
                Text("Weather Conditions:")
                    .bold()
                Spacer()
                Text(weatherAppVM.weatherDescription)
                WeatherIconView()
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct HistoryView: View {
    @EnvironmentObject var weatherAppVM: WeatherAppViewModel
    @Binding var searchField:String
    var body: some View {
        if !weatherAppVM.searchHistory.isEmpty {
            let historyArray = Array(weatherAppVM.searchHistory) // break expression
            
            List {
                Section(header: Text("Search History").font(.subheadline)) {
                    ForEach(historyArray, id: \.self) { history in
                        HStack {
                            Text(history)
                                .onTapGesture {
                                    searchField = history
                                }
                            Spacer()
                            Button(action: {
                                weatherAppVM.removeHistory(history)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .frame(maxHeight: 200)
        }
    }
}

struct WeatherIconView: View {
    @EnvironmentObject var weatherAppVM: WeatherAppViewModel

    var body: some View {
        if let icon = weatherAppVM.iconString, !icon.isEmpty,
           let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
        }
    }
}


