//
//  DataModel.swift
//  Assignment5
//
//  Created by Yi Ding on 2/10/20.
//  Copyright © 2020 Yi Ding. All rights reserved.
//

import Foundation
import MapKit


//for decoding
//https://useyourloaf.com/blog/using-swift-codable-with-property-lists/
//https://learnappmaking.com/plist-property-list-swift-how-to/
struct PropertyPlace : Codable {
    var name : String
    var description: String
    var lat: Double
    var long: Double
    var type : Int
}

struct Plistitem : Codable{
    var region : [Double]
    var places : [PropertyPlace]
}


public class DataManager {
    var placeArray : [Place]
    //store index in placeArray instead of place objects to save space 
    var favourites : [Int]
    let defaults = UserDefaults.standard
    //singleton:
    public static let sharedInstance = DataManager()
    
    //this prevents others from using the default () initializer
    fileprivate init() {
        self.placeArray = []
        self.favourites = defaults.object(forKey: "favourites") as? [Int] ?? [Int]()
    }
    
    //decode the property list......
    func loadAnnotationFromPlist(plistfilename: String) {
        if let path = Bundle.main.path(forResource: plistfilename, ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path),
        let plist = try? PropertyListDecoder().decode(Plistitem.self, from: xml)
        {
            for (i,oneplace) in plist.places.enumerated() {
                let thislocation = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(oneplace.lat), longitude: CLLocationDegrees(oneplace.long))
                let newplace = Place(name:oneplace.name,descp: oneplace.description,location: thislocation, ind: i)
                self.placeArray.append(newplace)
            }
        }
    }
    
    func saveFavourites(index : Int) { // here index is the index in placeArray
        if isInFavourites(index: index) {
            print(index, " Already in favourite")
            return
        }
        self.favourites.append(index)
        defaults.set(self.favourites, forKey: "favourites")
        self.placeArray[index].inFavourites = true
    }
    
    func deleteFavourites(index : Int) { // here index is the index in placeArray
        if !isInFavourites(index: index) {
            print(index, " Not in favourite")
            return
        }
        let leng = self.favourites.count
        for i in 0..<leng {
            if self.placeArray[self.favourites[i]].index == index {
                self.placeArray[index].inFavourites = false
                self.favourites.remove(at: i)
                defaults.set(self.favourites, forKey: "favourites")
                break
            }
        }
    }
    
    func listFavourites() {
    }
    
    func isInFavourites(index : Int) -> Bool { // here index is the index in placeArray
        let leng = self.favourites.count
        for i in 0..<leng {
            if (self.favourites[i] == index) {
                return true
            }
        }
        return false
    }
}



