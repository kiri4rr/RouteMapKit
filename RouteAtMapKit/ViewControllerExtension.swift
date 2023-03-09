//
//  ViewControllerExtension.swift
//  RouteAtMapKit
//
//  Created by Kirill Romanenko on 09.03.2023.
//

import UIKit
import MapKit

extension UIViewController: MKMapViewDelegate {
    
    func addAdress(_ title: String, _ placeHolder: String, compition: @escaping (String)->()){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = placeHolder
        }
        
        let alertOk = UIAlertAction(title: "Ok", style: .default) { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            compition(text)
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
            print("cancel action")
        }
        
        alert.addAction(alertOk)
        alert.addAction(alertCancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func errorAlert(_ title: String, _ message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        print(location)
        guard let coordinate = manager.location?.coordinate else {return}
        
//        let region = MKCoordinateRegion(center: location.coordinate,
//                                        latitudinalMeters: 1000,
//                                        longitudinalMeters: 1000)
//        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = "My location"
        annotation.coordinate = coordinate
        
        selfLocation = annotation
//        mapView.addAnnotation(annotation)
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
}

