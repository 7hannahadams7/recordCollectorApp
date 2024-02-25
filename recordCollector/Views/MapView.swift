//
//  MapView.swift
//  recordCollector
//
//  Created by Hannah Adams on 2/25/24.
//

import SwiftUI
import MapKit
import CoreLocation

class RecordStoreViewModel: ObservableObject {
    @Published var coordinates: [String: CLLocationCoordinate2D] = [:]

    func fetchCoordinates() {
        var newCoordinates: [String: CLLocationCoordinate2D] = [:]

        let recordStores = [
            "CD Cellar": "105 Park Ave, Falls Church, VA 22046",
            "Deep Groove Records": "317 N Robinson St, Richmond, VA 23220"
            // Add more record stores as needed
        ]

        let group = DispatchGroup()

        for (store, address) in recordStores {
            group.enter()

            forwardGeocoding(address: address) { location in
                if let coordinate = location?.coordinate {
                    newCoordinates[store] = coordinate
                }

                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.coordinates = newCoordinates
        }
    }

    func forwardGeocoding(address: String, completion: @escaping (CLLocation?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Failed to retrieve location with error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("No matching location found")
                completion(nil)
                return
            }

            completion(location)
        }
    }
}

struct RecordStoreMapView: View {
    @StateObject private var viewModel = RecordStoreViewModel()

    var body: some View {
        Map() {
            ForEach(Array(viewModel.coordinates.keys), id: \.self) { storeName in
                Marker(storeName, coordinate: viewModel.coordinates[storeName]!)
            }
        }
        .onAppear {
            viewModel.fetchCoordinates()
        }
    }
}

struct RecordStoreMapView_Previews: PreviewProvider {
    static var previews: some View {
        RecordStoreMapView()
    }
}
