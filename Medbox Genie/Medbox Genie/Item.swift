//
//  Item.swift
//  Medbox Genie
//
//  Created by Beemnet Andualem Belete on 10/28/24.
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
