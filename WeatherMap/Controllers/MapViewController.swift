//
//  MapViewController.swift
//  WeatherMap
//
//  Created by MacBook Pro on 28.05.26.
//

import UIKit
import MapKit
import CoreLocationUI
internal import CoreData

class MapViewController : UIViewController {
    
    let map = MKMapView()
    let locationManager = CLLocationManager()
    let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    private var didShowCurrentLocationDetail = false
    
    var currentMap : MKMapType = .satellite{
        
        didSet{
            map.mapType = currentMap
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(map)
        map.fillSuperview()
        setupregion()
        addsegmentedcontrol()
        locationButton()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        map.userTrackingMode = .follow
        map.addGestureRecognizer(longPress)
        longPress.addTarget(self, action: #selector(didAddAnnotation))
        populateMapWithAnnotations()
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        map.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    func setupregion(){
        // Show user location and follow when available
        map.showsUserLocation = true
        map.userTrackingMode = .follow
    }
    
    func addsegmentedcontrol(){
        
        let segments = ["Standard"  ,"Satellite"]
        let control = UISegmentedControl(items: segments)
        control.selectedSegmentIndex =  0
        control.selectedSegmentTintColor = .systemPurple
        control.addTarget(self, action: #selector(handleMapChange(_ :)), for: .valueChanged)
        
        view.addSubview(control)
        control.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        control.centerX(inView: view)
    }
    
    @objc func handleMapChange(_ segmentedControl:UISegmentedControl){
        
        switch(segmentedControl.selectedSegmentIndex){
        case 0 :
            currentMap = .standard
        case 1 :
            currentMap = .satellite
        default:
            break
        }
        
    }
    
    func locationButton(){
        let locationButton = CLLocationButton()
        locationButton.cornerRadius = 25
        locationButton.icon = .arrowFilled
        
        view.addSubview(locationButton)
        locationButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,trailing:
                 view.trailingAnchor, paddingBottom: 8, paddingTrailing:8)
        locationButton.backgroundColor = .white
        locationButton.tintColor = .systemPurple
        locationButton.setSize(height: 64, width: 64)
        locationButton.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
    }
    
    func createAnnotation(city: String? = nil, country: String? = nil, latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> MKPointAnnotation {
        
        let locationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let locationFromCity = CLLocation(latitude: latitude, longitude: longitude)
        
        let marker = MKPointAnnotation()
        
        if let city = city, let country = country{
            marker.title = city
            marker.subtitle = country
        }else {
            locationFromCity.fetchLocationInformation{city, country, error in
                
                guard let city = city, let country = country, error == nil else{
                    return
                }
                marker.title = city
                marker.subtitle = country
            }
        }
        marker.coordinate = locationCoordinates
        return marker
        
    }
    
    func populateMapWithAnnotations(){
        
        for annotation in map.annotations{
            map.removeAnnotation(annotation)
        }
        let favourites = CoreDataService.shared.fetchLocations()
        
        for location in favourites {
            
            map.addAnnotation(createAnnotation(city: location.name, country: location.country, latitude: location.latitude, longitude: location.longitude))
        }
        
    }
    
    @objc func getCurrentLocation(){
        self.locationManager.startUpdatingLocation()
    }
    @objc func didAddAnnotation(sender : UILongPressGestureRecognizer){
        if sender.state != UIGestureRecognizer.State.began{
            return
        }
        let pressedLocation = sender.location(in: map)
        let pressedCoordinates: CLLocationCoordinate2D = map.convert(pressedLocation, toCoordinateFrom: map)
            
        map.addAnnotation(createAnnotation(latitude: pressedCoordinates.latitude, longitude: pressedCoordinates.longitude ))
        
        }
    
    @objc func contextObjectsDidChange(_ notification: Notification){
        populateMapWithAnnotations()
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            map.userTrackingMode = .follow
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            map.userTrackingMode = .follow
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        map.setRegion(MKCoordinateRegion(center: location.coordinate,span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
        locationManager.stopUpdatingLocation()

        if !didShowCurrentLocationDetail {
            didShowCurrentLocationDetail = true
            let vc = DetailViewController()
            vc.locationCoordinates = location.coordinate
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
    }
}


extension MapViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        
        annotationView.glyphImage = UIImage(systemName: "network")
        annotationView.markerTintColor = .systemPurple
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let vc = DetailViewController()
        vc.locationCoordinates = view.annotation?.coordinate
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

