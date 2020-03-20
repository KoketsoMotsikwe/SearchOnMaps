//
//  ViewController.swift
//  FindMallsOnMap
//
//  Created by Koketso Motsikwe (ZA) on 2020/03/19.
//  Copyright © 2020 Koketso Motsikwe (ZA). All rights reserved.


import UIKit
import MapKit
import CoreLocation

class MapsScreen: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var resultSearchController:UISearchController? = nil
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    var matchingItems:[MKMapItem] = []
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 200
    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        checkLocationServices()
        
    }

    
    func setUpLocationManager(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
        
    }
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAuthorization()
            
            
            
            
        }else{
            
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
            
        case .authorizedWhenInUse:
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
}
extension MapsScreen: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchString = searchBar.text ?? ""
       makeAPICall()
    }
    func makeAPICall(){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchString
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response =  response else{
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}


extension MapsScreen: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{ return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.tableView.reloadData()
    }
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
     }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "MallCell", for: indexPath) as? MallTableViewCell
           let mall = matchingItems[indexPath.row]
        cell?.populate(matchingItem: mall)
           return cell!
       }
   func numberOfSections(in tableView: UITableView) -> Int {
       return 1
   }

}



