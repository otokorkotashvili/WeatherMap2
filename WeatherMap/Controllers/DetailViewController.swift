//
//  DetailViewController.swift
//  WeatherMap
//
//  Created by MacBook Pro on 28.05.26.
//
import MapKit
import UIKit

class DetailViewController : UIViewController {
    
    var cityLabel = UILabel(font: .systemFont(ofSize: 16, weight: .heavy))
    var countryLabel = UILabel(font: .systemFont(ofSize: 14, weight: .bold))
    var dateLabel = UILabel(font: .systemFont(ofSize: 16, weight: .semibold), textColor: .secondaryLabel)
    var containerView = UIView()
    private var isShowingLoading = false
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
    
    var viewModel: DetailViewModel?
    
    // Deprecated shim for backward compatibility:
    var locationCoordinates: CLLocationCoordinate2D? {
        didSet {
            if let coord = locationCoordinates {
                if viewIfLoaded == nil { _ = self.view } // ensure view is loaded
                if viewModel == nil {
                    configure(with: coord)
                } else {
                    viewModel?.updateCoordinate(coord)
                }
            }
        }
    }
    
    func configure(with coordinate: CLLocationCoordinate2D) {
        let vm = DetailViewModel(coordinate: coordinate)
        bind(to: vm)
        self.viewModel = vm
        // kick off data
        vm.resolvePlace()
        vm.fetchWeather()
    }
    
    private func bind(to vm: DetailViewModel) {
        vm.onCityCountryChange = { [weak self] city, country in
            DispatchQueue.main.async {
                self?.cityLabel.text = city
                self?.countryLabel.text = country
            }
        }
        vm.onCurrentChange = { [weak self] current in
            guard let data = current else { return }
            DispatchQueue.main.async {
                self?.tempLabel.text = String(format: "%.1f", data.temp) + "℃"
                self?.weatherLabel.text = data.weather.first?.description
                self?.feelsTempLabel.text = "Feels like" + String(format: "%.1f", data.feels_like) + "℃"
            }
        }
        vm.onForecastsChange = { [weak self] _ in
            DispatchQueue.main.async { self?.tableView.reloadData() }
        }
        vm.onFavouriteChange = { [weak self] isFav in
            DispatchQueue.main.async {
                if isFav {
                    self?.favouritesButton.setTitle("Remove from favourites", for: .normal)
                    self?.favouritesButton.setTitleColor(.systemRed, for: .normal)
                } else {
                    self?.favouritesButton.setTitle("add to favourites", for: .normal)
                    self?.favouritesButton.setTitleColor(.systemPurple, for: .normal)
                }
            }
        }
        vm.onLoadingChange = { [weak self] isLoading in
            if isLoading { self?.showLoadingIndicator() } else { self?.dismissLoadingIndicator() }
        }
        vm.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupUI()
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Detail")
        tableView.setHeight(300)
        tableView.setWidth(view.frame.size.width)
        tableView.anchor(top: currentStack.bottomAnchor, paddingTop: 8)
        view.addSubview(favouritesButton)
        favouritesButton.setTitle("add to favourites", for: .normal)
        favouritesButton.setTitleColor(.systemPurple, for: .normal)
        favouritesButton.anchor(top: tableView.bottomAnchor, paddingTop: 8)
        favouritesButton.centerX(inView: view)
        favouritesButton.addTarget(self, action: #selector(toggleFavouriteTapped), for: .touchUpInside)
        
    }
    
    @objc private func toggleFavouriteTapped() {
        favouritesButton.isEnabled = false
        viewModel?.toggleFavourite()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.favouritesButton.isEnabled = true
        }
    }
    
    func showLoadingIndicator(){
        guard !isShowingLoading else { return }
        isShowingLoading = true
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
            self.isShowingLoading = false
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let vm = viewModel, indexPath.row < vm.forecasts.count else {
            return UITableViewCell()
        }
        let day = vm.forecasts[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Detail", for: indexPath)

        var config = cell.defaultContentConfiguration()

        // Weekday text
        let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE"
        config.text = formatter.string(from: date)

        // Day temperature
        config.secondaryText = String(format: "%.1f℃", day.temp.day)

        // Default system icon based on OpenWeather icon code
        if let iconCode = day.weather.first?.icon {
            let symbol = UIImage(systemName: symbolName(for: iconCode))
            config.image = symbol
            config.imageProperties.tintColor = .systemPurple
        }

        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.forecasts.count ?? 0
    }
    
    private func symbolName(for iconCode: String) -> String {
        if iconCode.hasPrefix("01") { return "sun.max" }
        if iconCode.hasPrefix("02") { return "cloud.sun" }
        if iconCode.hasPrefix("03") { return "cloud" }
        if iconCode.hasPrefix("04") { return "cloud.fill" }
        if iconCode.hasPrefix("09") { return "cloud.drizzle" }
        if iconCode.hasPrefix("10") { return "cloud.rain" }
        if iconCode.hasPrefix("11") { return "cloud.bolt.rain" }
        if iconCode.hasPrefix("13") { return "snowflake" }
        if iconCode.hasPrefix("50") { return "cloud.fog" }
        return "cloud"
    }
}

