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

