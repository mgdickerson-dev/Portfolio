//
//  SearchViewController.swift
//  LearnXP
//
//  Created by Michael Dickerson on 8/12/19.
//  Copyright © 2019 Michael Dickerson. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class SearchViewController: UIViewController{

    var delegate: TeacherSignUpViewController! = nil
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var selectedSchool: Location? = nil
    var locationSearchTable: LocationTableViewController? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "locationSearchTable") as? LocationTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "School Name"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        locationSearchTable!.mapView = mapView
        locationSearchTable!.handleMapSearchDelegate = self
    }
}

extension SearchViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {  print("error:: \(error)") }
   
}

extension SearchViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
       
        selectedSchool = locationSearchTable?.selectedSchool
        self.navigationController?.popViewController(animated: true)
        delegate.didFinishSearch(controller: self)
        
    }
}

extension SearchViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.canShowCallout = true
        return pinView
    }
}
