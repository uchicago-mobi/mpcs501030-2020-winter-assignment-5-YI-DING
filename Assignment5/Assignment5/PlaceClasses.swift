//
//  PlaceClasses.swift
//  Assignment5
//
//  Created by Yi Ding on 2/10/20.
//  Copyright © 2020 Yi Ding. All rights reserved.
//

import Foundation
import MapKit

//got the idea from demo app with the happiest places on earth
class Place: MKPointAnnotation {
    let name: String?
    let longDescription: String?
    var inFavourites : Bool
    let index : Int
    init(name: String, descp: String, location: CLLocationCoordinate2D, ind : Int) {
        self.name = name
        self.longDescription = descp
        self.inFavourites = false
        self.index = ind
        super.init()
        self.coordinate = location
    }
}

class PlaceMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            //clusteringIdentifier = "Place"
            // not going to implement cluster click since it is too complicated and not required/mentioned
            displayPriority = .defaultLow
            markerTintColor = .systemBlue
            glyphImage = UIImage(systemName: "pin.fill")
        }
    }
}
