//
//  CommonModel.swift
//  WeatherApp
//
//  Created by Satish Vanamali on 10/08/25.
//

import Foundation

enum WeatherAPIError: LocalizedError {
    case networkError
    case decodingError
    case serverError(statusCode: Int)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed. Please check your internet."
        case .decodingError:
            return "Could not read the data. Please try again."
        case .serverError(let statusCode):
            return "Server returned error \(statusCode)."
        case .unknownError(let error):
            return "Something went wrong: \(error.localizedDescription)"
        }
    }
}
