//
//  ViewController.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-03-18.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var addedPin:LocationFood? = nil
    
    var selectedPin: LocationFood!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        
        longPressGesture.minimumPressDuration = 0.5
        
        mapView.addGestureRecognizer(longPressGesture)
        
        mapView.delegate = self
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        
        let touchArea = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchArea, toCoordinateFrom: mapView)
        addedPin = LocationFood(coordinate: newCoordinates, context: sharedContext)
        mapView.addAnnotation(addedPin!)
        CoreDataStack.sharedInstance().save()
    
    }
    
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false

        }
            
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation as! LocationFood
        
        selectedPin = annotation
        
       performSegue(withIdentifier: "CollectionViewSegue", sender: self)
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        mapView.deselectAnnotation(selectedPin as MKAnnotation?, animated: false)
        let controller = segue.destination as! LocationImagesViewController
        controller.pin = selectedPin
    }

    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.region = region
       // print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    
    @IBAction func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

