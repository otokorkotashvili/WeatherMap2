//
//  SearchViewController.swift
//  WeatherMap
//
//  Created by MacBook Pro on 28.05.26.
//

import UIKit
import MapKit

class SearchViewController: UITableViewController {
    
    let searchController = UISearchController()
    var matchingLocations: [MKMapItem] = []
    
    private var searchTimer: Timer?
    private var currentSearch: MKLocalSearch?
    private var lastQuery: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        addSearchController()
    }
    
    func addSearchController() {
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = .systemPurple
        searchController.searchBar.searchTextField.leftView?.tintColor = .systemPurple
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    deinit {
        searchTimer?.invalidate()
        currentSearch?.cancel()
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Debounce input to avoid spamming requests on every keystroke
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            self?.performSearch()
        }
    }
    
    func performSearch() {
        guard let rawText = searchController.searchBar.text else { return }
        let query = rawText.trimmingCharacters(in: .whitespacesAndNewlines)

        // If query is empty, cancel any in-flight search and clear results
        if query.isEmpty {
            currentSearch?.cancel()
            currentSearch = nil
            lastQuery = ""
            matchingLocations = []
            tableView.reloadData()
            return
        }

        // Cancel any in-flight search before starting a new one
        currentSearch?.cancel()
        lastQuery = query

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        currentSearch = search

        search.start { [weak self] response, error in
            guard let self = self else { return }
            defer { self.currentSearch = nil }

            if let nsError = error as NSError? {
                // Ignore cancellations
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled { return }
                print("Search Failed", nsError)
                return
            }

            guard let response = response else { return }

            // Only apply results if they match the most recent query
            if query == self.lastQuery {
                self.matchingLocations = response.mapItems
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Cancel pending debounce and any in-flight search
            searchTimer?.invalidate()
            currentSearch?.cancel()
            currentSearch = nil
            lastQuery = ""
            matchingLocations = []
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = matchingLocations[indexPath.row].placemark
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        configuration.imageToTextPadding = 20
        configuration.secondaryText = location.country
        configuration.attributedText = NSAttributedString(
            string: location.name ?? "",
            attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        )
        
        configuration.image = UIImage(systemName: "location.fill.viewfinder")
        configuration.imageProperties.tintColor = .systemPurple
        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        if let location = matchingLocations[indexPath.row].placemark.location?.coordinate{
            
            vc.locationCoordinates = location
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
