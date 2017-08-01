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
import GooglePlaces
import GooglePlacePicker

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var placesClient: GMSPlacesClient!
    
    var addedPin:LocationFood? = nil
    
    var selectedPin: LocationFood!
    
    var mapRegion: UserRegion!
    
    var userLocation : CLLocation!
    
    let locationManager = CLLocationManager()
    
    var editMode = false;
    
   
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        placesClient = GMSPlacesClient.shared()
        
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
        
        longPressGesture.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(longPressGesture)
        
        loadMap()
        
        mapView.addAnnotations(fetchAllPins())
        
        mapView.delegate = self
    }
    

    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
    
    func fetchAllPins() -> [LocationFood] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationFood")
        
        var pins:[LocationFood] = []
        
        do {
            let results = try sharedContext.fetch(fetchRequest)
            pins = results as! [LocationFood]
        } catch let error as NSError {
            
            print("An error has occured while trying to access the managed object context \(error.localizedDescription)")
        }
        
        return pins
    }

    
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        
        
        if editMode {
            return
        }
        
        let touchArea = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchArea, toCoordinateFrom: mapView)
        addedPin = LocationFood(coordinate: newCoordinates, context: sharedContext)
        mapView.addAnnotation(addedPin!)
        CoreDataStack.sharedInstance().save()
    
    }
    
    @IBAction func googlePlaces(_ sender: Any) {
        
        pickPlace();
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
    
    
    func deletePin(_ pin: LocationFood) {
        mapView.removeAnnotation(pin)
        sharedContext.delete(pin)
        CoreDataStack.sharedInstance().save()
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation as! LocationFood
        
        selectedPin = annotation
        
        if(editMode){
            
            let alert = UIAlertController(title: "Delete Pin", message: "Do you want to remove this pin?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                self.selectedPin = nil
                print(annotation)
                self.deletePin(annotation)
                
            }))
            
            present(alert, animated: true, completion: nil)
            
        }
        
        else {
        
            performSegue(withIdentifier: "CollectionViewSegue", sender: self)
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        saveMap()
    }
    
    
    func saveMap(){
        
    
        if mapRegion == nil {
            
            mapRegion = UserRegion(region:mapView.region, context: sharedContext)
        }
            
        else{
            
            mapRegion!.region = mapView.region
        }
        
        CoreDataStack.sharedInstance().save()
    }
    
    
    
    func loadMap() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserRegion")
        
        var region:[UserRegion] = []
       
        do {
            let results = try sharedContext.fetch(fetchRequest)
            region = results as! [UserRegion]
        } catch let error as NSError {
            
            print("An error occured accessing managed object context \(error.localizedDescription)")
        }
        
        if(region.count == 0 ){
            
           
        }
            
        else {
            mapRegion = region[0]
            mapView.region = mapRegion!.region
        }
        
    }
   

    @IBAction func edit(_ sender: Any) {
        
        editButton.title = editMode ? "Edit" : "Done"
        editMode = !editMode

    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        mapView.deselectAnnotation(selectedPin as MKAnnotation?, animated: false)
        let controller = segue.destination as! LocationImagesViewController
        controller.pin = selectedPin
    }

    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.region = region
       // print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func pickPlace() {
       
    if userLocation != nil {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                
                let userPlace = LocationFood(coordinate: place.coordinate ,placeID: place.placeID as NSString, context: self.sharedContext)
                 self.selectedPin = userPlace
                 CoreDataStack.sharedInstance().save()
                 self.performSegue(withIdentifier: "CollectionViewSegue", sender: self)
            }
        })
            
        }
        
        else {
            
            print("error")
        }
    }
    
    
    
    
    @IBAction func performSegueToReturnBack()  {
        
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
}

