//
//  Item.swift
//  WeatherApp
//
//  Created by Satish Vanamali on 07/08/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
