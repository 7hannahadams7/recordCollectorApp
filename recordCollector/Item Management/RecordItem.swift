//
//  RecordItem.swift
//  test3
//
//  Created by Hannah Adams on 1/8/24.
//

import Foundation
import SwiftUI

struct RecordItem: Identifiable {
    var id: String
    var name: String
    var artist: String
    var coverPhoto: UIImage
    var discPhoto: UIImage
    var releaseYear: Int
    var genres: [String] = []
    var dateAdded: String
    var isBand: Bool
    // Add other properties as needed
}
//
//struct RecordItem2: Codable {
//    var id: String
//    var name: String
//    var artist: String
//    var photo: UIImage?
//    // Add other properties as needed
//}
