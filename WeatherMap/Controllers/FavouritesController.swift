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
    
    private let viewModel = FavouritesViewModel()
    
    var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var favouritesCellRegistration: UICollectionView.CellRegistration<FavouritesLocationCell, Favourites>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favourites"
        setupCollectionView()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Bind view model changes to UI updates
        viewModel.onChange = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        // Trigger initial reload (in case the view model already loaded before binding)
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
}
        
// MARK: - UICollectionViewDataSource
extension FavouritesController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favouritesLocation = viewModel.item(at: indexPath)
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
        let item = viewModel.item(at: indexPath)
        vc.locationCoordinates = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension FavouritesController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 48) / 2
        return CGSize(width: width, height: width)
    }
}

