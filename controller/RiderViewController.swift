//
//  RiderViewController.swift
//  proj1
//
//  Created by sam on 2023/9/25.
//

import UIKit
import FirebaseAuth
import MapKit
import FirebaseDatabase

class RiderViewController: UIViewController, MKMapViewDelegate  ,CLLocationManagerDelegate{

    @IBOutlet weak var callUberButton: UIButton!
    var isCall:Bool = false
    var isServe: Bool = false
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    var userLocation = CLLocationCoordinate2D()
    
    let reference : DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let riderEmail = Auth.auth().currentUser?.email!
        reference.child("riderRequest").queryOrdered(byChild: "email").queryEqual(toValue: riderEmail).observe(DataEventType.childAdded) { DataSnapshot in
            
            if let okDataSnapshot = DataSnapshot.value as? [String:Any] {
                if let isServe = okDataSnapshot["isServe"] as? Bool{
                    self.isServe = isServe
                }
                self.isCall = true
                
                if self.isServe == true{
                    if let okDataSnapshot = DataSnapshot.value as? [String:Any] {
                        if let driverLat = okDataSnapshot["driverLat"] as? CLLocationDegrees{
                            if let driverLon = okDataSnapshot["driverLon"] as? CLLocationDegrees{
                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                let driverLocation = CLLocation(latitude: self.driverLocation.latitude, longitude: self.driverLocation.longitude)
                                let riderLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                let distance = round(driverLocation.distance(from: riderLocation))/1000
                                self.callUberButton.backgroundColor = UIColor.systemRed
                                self.callUberButton.setTitle("driver distance is "+String(distance)+" km", for: .normal)

                            }
                        }
                    }
                }else if self.isCall == true{
                    self.callUberButton.backgroundColor = UIColor.systemRed
                    self.callUberButton.setTitle( "cancel", for: .normal)
                }
                
            }
            DataSnapshot.ref.removeAllObservers()
        }
        
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // 獲取最新位置
        let userLocaltion = locations[0]
        let latitude :CLLocationDegrees = userLocaltion.coordinate.latitude
        let longitude : CLLocationDegrees = userLocaltion.coordinate.longitude
        
        
        if self.isServe == true{
            
            
            reference.child("riderRequest").queryOrdered(byChild: "email").queryEqual(toValue: Auth.auth().currentUser?.email).observe(DataEventType.childChanged) { DataSnapshot in
                if let okDataSnapshot = DataSnapshot.value as? [String:Any] {
                    if let driverLat = okDataSnapshot["driverLat"] as? CLLocationDegrees{
                        if let driverLon = okDataSnapshot["driverLon"] as? CLLocationDegrees{
                            
                            
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            
                            
                        }
                    }
                }
            }
            let driverCLLocation = CLLocation(latitude: self.driverLocation.latitude, longitude: self.driverLocation.longitude)
            let riderLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
            let distance = round(driverCLLocation.distance(from: riderLocation))/1000
            self.callUberButton.backgroundColor = UIColor.systemRed
            self.callUberButton.setTitle("driver distance is "+String(distance)+" km", for: .normal)
            
            let LatDalta = (userLocaltion.coordinate.latitude as Double) - (self.driverLocation.latitude as Double)
            let LonDalta = (userLocaltion.coordinate.longitude as Double) - (self.driverLocation.longitude as Double)
            
            print(LatDalta)
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: abs(LatDalta)*2.25, longitudeDelta: abs(LonDalta)*2.25)
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region : MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)

            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            let driverAnnotation = MKPointAnnotation()

            annotation.title = "my location"
            driverAnnotation.title = "driver location"

            driverAnnotation.coordinate = driverLocation
            annotation.coordinate = CLLocationCoordinate2D(latitude: userLocaltion.coordinate.latitude, longitude: userLocaltion.coordinate.longitude)

            mapView.addAnnotation(driverAnnotation)
            mapView.addAnnotation(annotation)

            self.userLocation = CLLocationCoordinate2D(latitude: userLocaltion.coordinate.latitude, longitude: userLocaltion.coordinate.longitude)
        }else{
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.0018, longitudeDelta: 0.0018)
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region : MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.title = "my location"
            annotation.coordinate = CLLocationCoordinate2D(latitude: userLocaltion.coordinate.latitude, longitude: userLocaltion.coordinate.longitude)
            mapView.addAnnotation(annotation)
            
            self.userLocation = CLLocationCoordinate2D(latitude: userLocaltion.coordinate.latitude, longitude: userLocaltion.coordinate.longitude)
        }
    }
    
   
    
    
    @IBAction func logout(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "userLoggedIn")
            
            performSegue(withIdentifier: "riderBackToLoginView", sender: self)
        }catch{
              
        }
    }
    
    @IBAction func callAnUber(_ sender: Any) {
        
        if isCall == true {
            callUberButton.backgroundColor = UIColor.systemGreen
            callUberButton.setTitle( "Call an uber", for: .normal)
            
            if let email = Auth.auth().currentUser?.email{
                
                reference.child("riderRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(DataEventType.childAdded) { DataSnapshot in
                    DataSnapshot.ref.removeValue()
                    self.reference.child("riderRequest").removeAllObservers()
                }
            }
            isCall = false
            
        }else {
            callUberButton.backgroundColor = UIColor.systemRed
            callUberButton.setTitle( "cancel", for: .normal)
            
            var riderData = [String:Any]()
            riderData["email"] = Auth.auth().currentUser?.email!
            riderData["latitude"] = userLocation.latitude
            riderData["longitude"] = userLocation.longitude
            riderData["isServe"] = false
            self.reference.child("riderRequest").childByAutoId().setValue(riderData)
            
            isCall = true
        }
    }
}
