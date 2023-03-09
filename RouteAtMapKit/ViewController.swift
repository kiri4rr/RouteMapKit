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
    
    private var arrayOfAnnotation = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfigOfButtons()
        mapView.delegate = self
    }
    
    private func setConfigOfButtons() {
        setConfigOfRouteButton()
        setConfigOfResetButton()
        setConfigOfAddAdressButton()
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
        request.transportType = .walking
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
}
