//
//  CoreDataService.swift
//  WeatherMap
//
//  Created by MacBook Pro on 28.05.26.
//

internal import CoreData
import UIKit

class CoreDataService {
    

    static let shared = CoreDataService()
    
    let persistenceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavouritesModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistenceContainer.viewContext
    }
    
    func addLocation(name: String, country: String, longitude: Double, latitude: Double) {
        
        let context = persistenceContainer.viewContext
        let location = Favourites(context: context)
        location.name = name
        location.country = country
        location.latitude = latitude
        location.longitude = longitude
        
        do {
            try context.save()
        } catch let error {
            print("Failed to save location. \(error)")
        }
    }
    
    func fetchLocations() -> [Favourites] {
        let context = persistenceContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Favourites>(entityName: "Favourites")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let locationList = try context.fetch(fetchRequest)
            return locationList
        } catch let error {
            print("Failed to fetch locations from Core Data \(error.localizedDescription)")
            return []
        }
    }
    
    func locationExists(latitude: Double, longitude: Double) -> Bool{
        
        let context = persistenceContainer.viewContext
  
        let fetchRequest = NSFetchRequest<Favourites>(entityName: "Favourites")
        
       
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Favourites.latitude), latitude as NSNumber, #keyPath(Favourites.longitude), longitude as NSNumber)
        
        fetchRequest.predicate = predicate
        var results:[NSManagedObject] = []
        
        do{
            results = try context.fetch(fetchRequest) as [NSManagedObject]
        }
        catch {
            print("Error executing fetch request: \(error)")
        }
        return !results.isEmpty
    }
    
    func deleteLocation(latitude: Double, longitude: Double) {
        
        let context = persistenceContainer.viewContext
        let fetchRequest = NSFetchRequest<Favourites>(entityName: "Favourites")
        // ✅ დაემატა დამხურავი ფრჩხილი
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Favourites.latitude), latitude as NSNumber, #keyPath(Favourites.longitude), longitude as NSNumber)
        fetchRequest.predicate = predicate
        
        do{
            let locationToRemove = try context.fetch(fetchRequest) as [NSManagedObject]
            
            locationToRemove.forEach{ locationToRemove in context.delete(locationToRemove)
            }
            // ✅ დაემატა ცვლილებების შენახვა (Save), რათა წაშლილი ლოკაციები ბაზიდანაც გაქრეს
            try context.save()
            
        } catch let error{
            print("Failed to Delete \(error.localizedDescription)")
        }
        
    }
}

