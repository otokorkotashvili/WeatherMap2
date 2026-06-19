//
//  MainTabBarController.swift
//  WeatherMap
//
//  Created by MacBook Pro on 28.05.26.
//

import UIKit


class MainTabBarController : UITabBarController {
    
    let configuration = UIImage.SymbolConfiguration(weight: .heavy)


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = .cyan
        setupTabs()
    }
    
    func setupTabs(){
        viewControllers = [
            createNavigationController(
                rootViewController: MapViewController(),
                title: "Maps",
                image: UIImage(systemName: "map.circle", withConfiguration: configuration)!,
                selectedImage: UIImage(systemName: "map.circle.fill", withConfiguration: configuration)!
            ),
            createNavigationController(
                rootViewController: SearchViewController(),
                title: "Search",
                image: UIImage(systemName: "magnifyingglass.circle", withConfiguration: configuration)!,
                selectedImage: UIImage(systemName: "magnifyingglass.circle.fill", withConfiguration: configuration)!
            ),
            createNavigationController(
                rootViewController: FavouritesController(),
                title: "Favourites",
                image: UIImage(systemName: "heart.circle", withConfiguration: configuration)!,
                selectedImage: UIImage(systemName: "heart.circle.fill", withConfiguration: configuration)!
            )
        ]
    }
    
    func createNavigationController(rootViewController: UIViewController, title: String, image : UIImage, selectedImage : UIImage) -> UIViewController {
         
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image //.withConfiguration(configuration)
        navController.tabBarItem.selectedImage = selectedImage //.withConfiguration(configuration)
        navController.navigationBar.prefersLargeTitles = false
        navController.navigationItem.title = title
        
        UITabBar.appearance().tintColor = .systemPurple
        UITabBar.appearance().barTintColor = .white
          
        return navController
    }
        
    
}

