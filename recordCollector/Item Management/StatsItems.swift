//
//  StatsItems.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/29/24.
//

import Foundation

struct StatsNameItem: Identifiable{
    var id: UUID
    var name: String
    var amount: Int
    var records: [String] = []
}

struct StatsValueItem: Identifiable{
    var id: UUID
    var value: Int
    var amount: Int
    var records: [String] = []
}
