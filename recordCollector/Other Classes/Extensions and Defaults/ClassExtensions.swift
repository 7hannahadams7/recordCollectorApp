//
//  ClassExtensions.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/8/24.
//

import Foundation
import SwiftUI

// Text consistency
extension Text {
    func largeHeadlineText() -> some View{
        self.font(.system(size:20)).bold()
    }
    
    func smallHeadlineText() -> some View{
        self.font(.system(size: 16)).bold()
    }
    
    func mainText() -> some View{
        self.font(.system(size: 16))
    }
    
    func subtitleText() -> some View {
        self.font(.system(size: 12))
    }
    
    func italicSubtitleText() -> some View{
        self.font(.system(size: 12)).italic()
    }
}

// For removing duplicates of Spotify results
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var result = [Element]()
        var seen = Set<Element>()

        for element in self {
            if seen.insert(element).inserted {
                result.append(element)
            }
        }

        return result
    }
}

// Converting a Date to String for dateAdded editing and fetching
extension Date {
    static func dateToString(date: Date, format: String = "MM-dd-yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

// Converting a String to Date for dateAdded editing and fetching
extension String {
    static func stringToDate(from string: String, format: String = "MM-dd-yyyy") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

// For converting my custom hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
