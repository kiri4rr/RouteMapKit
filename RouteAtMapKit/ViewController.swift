//
//  ViewController.swift
//  RouteAtMapKit
//
//  Created by Kirill Romanenko on 09.03.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var addAdressButton: UIButton!
    @IBOutlet weak var searchSelfLocationButton: UIButton!
    
    private var arrayOfAnnotation = [MKPointAnnotation]()
    let locationManager = CLLocationManager()
    var selfLocation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfigOfButtons()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkLocationEnabled()
    }
    
    private func setConfigOfButtons() {
        setConfigOfRouteButton()
        setConfigOfResetButton()
        setConfigOfAddAdressButton()
        setConfigOfSearchSelfLocationButton()
    }
    
    private func setConfigOfRouteButton(){
        routeButton.addTarget(self, action: #selector(targetForRouteButton), for: .touchUpInside)
    }
    
    @objc func targetForRouteButton(_ sender: UIButton){
        deleteAllFromMapView()
        for index in 0 ... arrayOfAnnotation.count - 2 {
            createDirectionRequest(arrayOfAnnotation[index].coordinate, arrayOfAnnotation[index + 1].coordinate)
        }
        
        mapView.showAnnotations(arrayOfAnnotation, animated: true)
        
    }
    
    private func setConfigOfResetButton(){
        resetButton.addTarget(self, action: #selector(targetForResetButton), for: .touchUpInside)
    }
    
    @objc func targetForResetButton(_ sender: UIButton){
        deleteAllFromMapView()
        arrayOfAnnotation.removeAll()
        routeButton.isEnabled = false
        
    }
    
    private func setConfigOfAddAdressButton(){
        addAdressButton.addTarget(self, action: #selector(targetForAddAdressButton), for: .touchUpInside)
    }
    
    @objc func targetForAddAdressButton(_ sender: UIButton){
        addAdress("Add", "Write adress") { [weak self] (text) in
            guard let self = self else { return }
            self.setupPlaceMark(text)
        }
    }
    
    private func setConfigOfSearchSelfLocationButton(){
        searchSelfLocationButton.addTarget(self, action: #selector(targetForSearchSelfLocationButton), for: .touchUpInside)
    }
    
    @objc func targetForSearchSelfLocationButton(_ sender: UIButton){
        showMyLocation()
    }
    
    private func setupPlaceMark(_ adress: String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(adress) { [weak self] (placeMarks, error) in
            guard let self = self else { return }
            guard let placeMarks = placeMarks else {
                self.errorAlert("Erorr", error?.localizedDescription ?? "")
                return
            }
            
            let placeMark = placeMarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = adress
            guard let location = placeMark?.location else { return }
            annotation.coordinate = location.coordinate
            
            self.arrayOfAnnotation.append(annotation)
            
            if self.arrayOfAnnotation.count >= 2 {
                self.routeButton.isEnabled = true
            }
            
            self.mapView.showAnnotations(self.arrayOfAnnotation, animated: true)
        }
    }
    
    private func createDirectionRequest(_ start: CLLocationCoordinate2D, _ finish: CLLocationCoordinate2D){
        
        let startLocation = MKPlacemark(coordinate: start)
        let finishLocation = MKPlacemark(coordinate: finish)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: finishLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        let diraction = MKDirections(request: request)
        diraction.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            guard let response = response else {
                self.errorAlert("Error", error?.localizedDescription ?? "Route is not available")
                return
            }
            
            var minRoute = response.routes[0]
            response.routes.forEach { (route) in
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
        
    }
    
    private func deleteAllFromMapView(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
    
    private func checkAuthorization(){
        switch locationManager.authorizationStatus {
        case .authorizedAlways :
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .denied:
            showAlertLocation("You denied using your location",
                              "Do you want to change?",
                              URL(string: UIApplication.openSettingsURLString))
            
        case .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func showAlertLocation(_ title: String, _ massage: String, _ url: URL?){
        let alert = UIAlertController(title: title,
                                      message: massage,
                                      preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings",
                                           style: .default) { (alert) in
            
            if url != nil {
                UIApplication.shared.open(url!,
                                          options: [:],
                                          completionHandler: nil)
            } else {
                return
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func checkLocationEnabled(){
        if CLLocationManager.locationServicesEnabled() {
            setConfigOfLocationManager()
        } else {
            showAlertLocation("Location service off",
                              "Please switch on your location service",
                              URL(string: "App-Prefs:root=LOCATION_SERVICES"))
        }
    }
    
    private func setConfigOfLocationManager(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func showMyLocation(){
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        arrayOfAnnotation.append(selfLocation)
        print(selfLocation.coordinate)
        self.mapView.showAnnotations(self.arrayOfAnnotation, animated: true)
    }
}
