//
//  FavouritesLocationCell.swift
//  WeatherMap
//
//  Created by MacBook Pro on 09.06.26.
//

import UIKit
import MapKit

class FavouritesLocationCell: UICollectionViewCell {
    
    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.isZoomEnabled = false
        mv.isScrollEnabled = false
        mv.isUserInteractionEnabled = false
        return mv
    }()
    
    let viewToBlur: UIView = {
        let view = UIView()
        return view
    }()
    
    let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        return blurView
    }()
    
    let cityLabel = UILabel(font: .systemFont(ofSize: 16, weight: .semibold))
    let countryLabel = UILabel(font: .systemFont(ofSize: 16))
    
    var city: String? {
        didSet {
            self.cityLabel.text = city
        }
    }
    
    var country: String? {
        didSet {
            self.countryLabel.text = country
        }
    }
    
    var coordinates: CLLocationCoordinate2D? {
        didSet {
            guard let coordinates = coordinates else { return }
            let zoom = 20.0
            
            let location = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
            self.zoomLocation(location: location, radius: zoom)
            UIView.animate(withDuration: 0.4) {
                self.viewToBlur.alpha = 1
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        contentView.addSubViews(viewToBlur, cityLabel, countryLabel)
        viewToBlur.addSubViews(mapView, blurView)
        
        contentView.clipsToBounds = true
        viewToBlur.fillSuperview()
        mapView.fillSuperview()
        
        blurView.anchor(top: cityLabel.topAnchor, leading: viewToBlur.leadingAnchor,
                        bottom: viewToBlur.bottomAnchor, trailing: viewToBlur.trailingAnchor,
                        paddingTop: 4)
        
        cityLabel.anchor(leading: contentView.leadingAnchor, bottom: countryLabel.topAnchor,
                         trailing: contentView.trailingAnchor,
                         paddingLeading: 12, paddingBottom: 4, paddingTrailing: 12)
        
        countryLabel.anchor(leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor,
                            trailing: contentView.trailingAnchor,
                            paddingLeading: 12, paddingBottom: 12, paddingTrailing: 12)
        contentView.layer.cornerRadius = 16
        
        viewToBlur.alpha = 0
    }
    
    func zoomLocation(location: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let span = radius * 2000
        let region = MKCoordinateRegion(center: location, latitudinalMeters: span, longitudinalMeters: span)
        mapView.setRegion(region, animated: true)
    }
}
 
