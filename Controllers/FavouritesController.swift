//
//  Favourites.swift
//  WeatherMap
//
//  Created by MacBook Pro on 28.05.26.
//
internal import CoreData
import MapKit
import UIKit

class FavouritesController: UIViewController {
    
    var locations: [Favourites] = []
    let coreDataService = CoreDataService()
    
    var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var favouritesCellRegistration: UICollectionView.CellRegistration<FavouritesLocationCell, Favourites>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favourites"
        locations = CoreDataService.shared.fetchLocations()
        setupCollectionView()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
        //locations = coreDataService.fetchLocations()
        collectionView.reloadData()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.collectionViewLayout = layout
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                              bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                              paddingLeading: 8, paddingBottom: 8, paddingTrailing: 8)
        
        favouritesCellRegistration = UICollectionView.CellRegistration(handler: { (cell: FavouritesLocationCell, indexPath, favourite: Favourites) in
            
            let coordinates = CLLocationCoordinate2D(latitude: favourite.latitude, longitude: favourite.longitude)
            cell.coordinates = coordinates
            
            let placeMark = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            placeMark.fetchLocationInformation { city, country, error in
                guard let city = city, let country = country, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    cell.city = city
                    cell.country = country
                }
            }
        })
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    @objc func contextObjectsDidChange(_ notification: Notification){
        locations = CoreDataService.shared.fetchLocations()
        collectionView.reloadData()

}

        
}
// MARK: - UICollectionViewDataSource
extension FavouritesController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favouritesLocation = locations[indexPath.row]
        return collectionView.dequeueConfiguredReusableCell(
            using: favouritesCellRegistration,
            for: indexPath,
            item: favouritesLocation
        )
    }
}

extension FavouritesController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailViewController()
        
        vc.locationCoordinates = CLLocationCoordinate2D(latitude: locations[indexPath.row].latitude, longitude: locations[indexPath.row].longitude)
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension FavouritesController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let size = CGFloat((Float(view.frame.size.width) - Float(16) * 3) / 2)
        let width = (collectionView.frame.width - 48) / 2
        return CGSize(width: width, height: width)
    }
}

