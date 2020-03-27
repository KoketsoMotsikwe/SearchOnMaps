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
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var tableView: UITableView!
  
    var matchingItems:[MKMapItem] = []
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 0
    var previousLocation: CLLocation?
    var searchString = ""
    let geoCoder = CLGeocoder()
    var selectedItem: MKMapItem!

    var directionsArray = [MKDirections]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        checkLocationServices()
//        var selectedItem: MKMapItem!

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ABk") {
            let nextScreen = segue.destination as! SecondScreenViewController
            nextScreen.matchingItems = selectedItem
        }
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
            startTrackingUserLocation()
            
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
    func startTrackingUserLocation(){
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude =  mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    func getDirections(){
        guard let location = locationManager.location?.coordinate else{
            return
        }
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        
        
        directions.calculate { [unowned self] (response, error) in
            guard let response  = response else {return }
           
            for route in response.routes{
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
        }
    }
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate        = getCenterLocation(for: mapView).coordinate
        let startingLocation             = MKPlacemark(coordinate: coordinate)
        let destination                  = MKPlacemark(coordinate: destinationCoordinate)
        
        
        let request                      = MKDirections.Request()
        request.source                   = MKMapItem(placemark: startingLocation)
        request.destination              = MKMapItem(placemark: destination)
        request.transportType            = .automobile
        request.requestsAlternateRoutes  = true
         
        return request
    }

    func resetMapView(withNew directions: MKDirections){
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map{$0.cancel()}
    }

    @IBAction func goButtonTapped(_ sender: UIButton) {
        getDirections()
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
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        guard let location = locations.last else{ return }
    //        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    //        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
    //        mapView.setRegion(region, animated: true)
    
    //    }
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
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = matchingItems[indexPath.row]
        print(selectedItem.name ?? "NOTHING")
        
          self.performSegue(withIdentifier: "ABk", sender: self)
    }
    
}

extension MapsScreen: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else{return}
        guard center.distance(from: previousLocation) > 50 else{return}
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center){ [weak self ] (placemarks, error) in
            guard let self = self else {return}
            if let _ = error{
                return
            }
            guard let placemark = placemarks?.first else{
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    
}
}



