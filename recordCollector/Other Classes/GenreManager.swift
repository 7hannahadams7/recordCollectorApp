//
//  GenreManager.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/8/24.
//

import Foundation

class GenreManager: ObservableObject {
    @Published var genres: [String] = []
    
    init(){
    }
    
    func addGenre(_ genre: String) {
        if !(genres.contains(genre)){
            genres.append(genre)
        }
    }

    func removeGenre(_ genre: String) {
        genres.removeAll { $0 == genre }
    }
}
