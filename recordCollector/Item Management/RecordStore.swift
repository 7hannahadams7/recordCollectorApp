//
//  RecordStore.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/28/24.
//

import Foundation
import MapKit

struct RecordStore: Identifiable {
    var id: String
    var addressString: String
    var location: CLLocationCoordinate2D?
    var recordIDs: Set<String> = Set<String>()
//    var recordIDs: [String] = []
}
