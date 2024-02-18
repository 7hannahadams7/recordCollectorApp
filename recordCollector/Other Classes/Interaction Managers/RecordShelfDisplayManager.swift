//
//  RecordManager.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/18/24.
//

import Foundation
import SwiftUI
import Combine

// Record Item pull and update for HomePageView
class RecordShelfDisplayManager: ObservableObject {
    @ObservedObject var viewModel: LibraryViewModel
    
    private var randomizedRecords: [RecordItem] = []
    @Published var shownRecords: [RecordItem] = []
    private var instanceMarker: Int = -1
    private var changeMarker: Int = 0
    private var fullSize: Int = 0
    private var shownSize: Int = 0
    
    
    init(viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        pullInitialRecords()
        
        // Listener to viewModel changes
        viewModel.$recordDictionaryByID
            .sink { [weak self] _ in
                self?.pullInitialRecords()
            }
            .store(in: &cancellables)
    }

    // Fill initial arrays and show defaults if needed
    private func pullInitialRecords() {
        randomizedRecords = Array(viewModel.recordDictionaryByID.values).shuffled()
        if randomizedRecords.count < 7 {
            let additionalInstancesNeeded = 7 - randomizedRecords.count
            let additionalInstances = defaultRecordItems.prefix(additionalInstancesNeeded)
            randomizedRecords += additionalInstances
        }
        shownRecords = Array(randomizedRecords.prefix(7))
        
        instanceMarker = shownRecords.count % randomizedRecords.count //Marker for next item for change
        fullSize = randomizedRecords.count //Total items
    }

    // Iterate next item in shownRecords to next randomizedRecords item
    func updateArray() {
        // Check if empty if viewModel hasn't finished fetch before update
        if !randomizedRecords.isEmpty && !shownRecords.isEmpty{
            shownRecords[changeMarker] = randomizedRecords[instanceMarker]
            instanceMarker = (instanceMarker + 1) % fullSize
            changeMarker = (changeMarker + 1) % 7
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
}
