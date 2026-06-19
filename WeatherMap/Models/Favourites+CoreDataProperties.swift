//
//  Favourites+CoreDataProperties.swift
//  WeatherMap
//
//  Created by MacBook Pro on 09.06.26.
//
//

public import Foundation
public import CoreData


public typealias FavouritesCoreDataPropertiesSet = NSSet

extension Favourites {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourites> {
        return NSFetchRequest<Favourites>(entityName: "Favourites")
    }

    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var country: String?

}

extension Favourites : Identifiable {

}
