//
//  DetailViewController.swift
//  WeatherMap
//
//  Created by MacBook Pro on 28.05.26.
//
import MapKit
import UIKit

class DetailViewController : UIViewController {
    
    var latitude: Double = 0
    var longitude: Double = 0
    var city = "", country = ""
    var locationCoordinates: CLLocationCoordinate2D?
    var cityLabel = UILabel(font: .systemFont(ofSize: 16, weight: .heavy))
    var countryLabel = UILabel(font: .systemFont(ofSize: 14, weight: .bold))
    var dateLabel = UILabel(font: .systemFont(ofSize: 16, weight: .semibold), textColor: .secondaryLabel)
    var containerView = UIView()
    var tempLabel = UILabel(font: .systemFont(ofSize: 62, weight: .black))
    let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .black, scale: .large)
    
    var favouritesButton: UIButton = {
        let bt = UIButton()
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return bt
    }()
    
    lazy var backButton = UIImage(systemName: "arrowshape.left.circle.fill", withConfiguration: configuration)?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
    
    var weatherLabel = UILabel(font: .systemFont(ofSize: 32),textColor: .label)
    var feelsTempLabel = UILabel(font: .systemFont(ofSize: 16, weight: .semibold), textColor: .gray)
    var tableView = UITableView()
    var forecasts:[Daily] = []
    
    var current: Current? {
        
        didSet {
            guard let data = current else {
                return
            }
            DispatchQueue.main.async{
                self.tempLabel.text = String(format: "%.1f", data.temp) + "℃"
                self.weatherLabel.text = data.weather[0].description
                self.feelsTempLabel.text = "Feels like" + String(format: "%.1f", data.feels_like) + "℃"
                
            }
        }
    }
    
    var weather : WeatherData? {
        didSet {
            if let data = weather {
                for day in data.daily.dropFirst(){
                    forecasts.append(day)
                }
            }
            
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupUI()
        checkCoordinates()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backIndicatorImage = backButton
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButton
        
        
    }
    
    
    func setupUI(){
        
        let infoStack = UIStackView(arrangedSubviews: [
            dateLabel,
            cityLabel,
            countryLabel
        ])
        view.addSubview(infoStack)
        infoStack.axis = .vertical
        infoStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 4)
        infoStack.centerX(inView: view)
        
        let currentTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: currentTime)
        
        view.addSubview(tempLabel)
        tempLabel.anchor(top: infoStack.bottomAnchor, leading: view.leadingAnchor, paddingTop: 8, paddingLeading: 16)
        let currentStack = UIStackView(arrangedSubviews: [
            weatherLabel,
            feelsTempLabel
        ])
        
        view.addSubview(currentStack)
        currentStack.anchor(top: tempLabel.bottomAnchor, leading: view.leadingAnchor, paddingTop: 8, paddingLeading: 8)
        
        currentStack.axis = .vertical
        currentStack.spacing = 4
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.register(DetailTableCell.self, forCellReuseIdentifier: "Detail")
        tableView.setHeight(300)
        tableView.setWidth(view.frame.size.width)
        tableView.anchor(top: currentStack.bottomAnchor, paddingTop: 8)
        view.addSubview(favouritesButton)
        favouritesButton.setTitle("add to favourites", for: .normal)
        favouritesButton.setTitleColor(.systemPurple, for: .normal)
        favouritesButton.anchor(top: tableView.bottomAnchor, paddingTop: 8)
        favouritesButton.centerX(inView: view)
        
    }
    
    func checkCoordinates(){
        if let checkedLatitude = locationCoordinates?.latitude, let checkedLongitude = locationCoordinates?.longitude {
            latitude = checkedLatitude
            longitude = checkedLongitude
            
            let placeMark = CLLocation(latitude: latitude, longitude: longitude)
            placeMark.fetchLocationInformation{[weak self] city, country, error in
                guard let self = self, let city = city, let country = country, error == nil else {
                    return
                }
                
                self.city = city
                self.country = country
                self.updateValues()
                self.checkIfLocationIsSaved()
                
            }
        }
        getWeather()
        checkIfLocationIsSaved()
    }
    
    func updateValues(){
        cityLabel.text = city
        countryLabel.text = country
    }
    func getWeather(){
        showLoadingIndicator()
        
        Task {
            do{
                let weather = try await NetworkService.shared.getForecast(latitude: latitude, longitude: longitude)
                
                self.dismissLoadingIndicator()
                
                print (weather)
                
                self.current = weather.current
                self.weather = weather
                
            }catch let error {
                
                print(error)
                self.dismissLoadingIndicator() 
                
            }
        }
    }
    func showLoadingIndicator(){
        view.addSubview(containerView)
        containerView.fillSuperview()
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25){
            self.containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        activityIndicator.center(inView: view)
        activityIndicator.startAnimating()
        activityIndicator.color = .systemPurple
    }
    
    func  dismissLoadingIndicator(){
        DispatchQueue.main.async{
            self.containerView.removeFromSuperview()
        }
    }
    func checkIfLocationIsSaved(){
        
        if CoreDataService.shared.locationExists(latitude: latitude, longitude: longitude){
            favouritesButton.setTitle( "Remove from favourites", for: .normal)
            favouritesButton.setTitleColor(.systemRed, for: .normal)
            
            favouritesButton.addTarget(self, action: #selector(removeLocationFromCoreData), for: .touchUpInside)
        }else{
            favouritesButton.setTitle( "add to favourites", for: .normal)
            favouritesButton.setTitleColor(.systemPurple, for: .normal)
            
            favouritesButton.addTarget(self, action: #selector(addLocationToCoreData), for: .touchUpInside)
        }
    }
    
    @objc func removeLocationFromCoreData(){
        print("removed")
        CoreDataService.shared.deleteLocation(latitude: latitude, longitude: longitude)
        checkIfLocationIsSaved()
    }
    @objc func addLocationToCoreData(){
        print("Added")
        CoreDataService.shared.addLocation(name: city, country: country, longitude: longitude, latitude: latitude)
        checkIfLocationIsSaved()
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = forecasts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Detail", for: indexPath) as!
        DetailTableCell
        
        cell.day = day
        return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return forecasts.count
    }
    
}
//import UIKit
//import CoreLocation

//class DetailViewController: UIViewController {
    
 //   var coordinate: CLLocationCoordinate2D?
 //   var locationName: String?
    
 //   override func viewDidLoad() {
  //      super.viewDidLoad()
   //     view.backgroundColor = .systemMint
   //    title = locationName
        
        // აქ მოგვიწევს ამინდის API-დან მონაცემების fetch-ი
        // coordinate property-ით
    //}
//}

