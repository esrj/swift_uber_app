//
//  PickupViewController.swift
//  proj1
//
//  Created by sam on 2023/9/29.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class PickupViewController: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var pickupRiderButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let reference = Database.database().reference()
    
    var isPickup = false
    var riderInfo : [String:Any] = [:]
    var riderCooridate = CLLocationCoordinate2D()
    var driverCooridate = CLLocationCoordinate2D()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if isPickup == true{
            reference.child("riderRequest").queryOrdered(byChild: "email").queryEqual(toValue: riderInfo["email"] as? String ).observeSingleEvent(of: DataEventType.childAdded) { DataSnapshot in
                
                
                
                DataSnapshot.ref.updateChildValues(["driverLat": self.driverCooridate.latitude,"driverLon":self.driverCooridate.longitude,"isServe":true])
                
                DataSnapshot.ref.removeAllObservers()
                
            }
        }
        
        if let coordinate = locationManager.location?.coordinate{
            
            let latDelta = ((riderInfo["latitude"] as! Double ) - (coordinate.latitude as Double))*2.25
            let lonDelta = ((riderInfo["longitude"] as! Double ) - (coordinate.longitude as Double))*2.25
            
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: abs(latDelta), longitudeDelta: abs(lonDelta))
            let region : MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)

            mapView.setRegion(region, animated: true)
            self.driverCooridate = coordinate
        }
        
        
        
        mapView.removeAnnotations(mapView.annotations)
        
        let driverAnnotation = MKPointAnnotation()
        let riderAnnotation = MKPointAnnotation()
        driverAnnotation.title = "your location"
        riderAnnotation.title = riderInfo["email"] as? String
        
        riderCooridate = CLLocationCoordinate2D(latitude: riderInfo["latitude"] as! CLLocationDegrees, longitude: riderInfo["longitude"] as! CLLocationDegrees )
        
        riderAnnotation.coordinate = riderCooridate
        driverAnnotation.coordinate = self.driverCooridate

        mapView.addAnnotation(riderAnnotation)
        mapView.addAnnotation(driverAnnotation)
        
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func pickupRider(_ sender: Any) {
        
        isPickup = true
        reference.child("riderRequest").queryOrdered(byChild: "email").queryEqual(toValue: riderInfo["email"] as? String ).observeSingleEvent(of: DataEventType.childAdded) { DataSnapshot in
            
            
            
            DataSnapshot.ref.updateChildValues(["driverLat": self.driverCooridate.latitude,"driverLon":self.driverCooridate.longitude,"isServe":true])
            
            DataSnapshot.ref.removeAllObservers()
            
        }
        
        let riderCLLocation = CLLocation(latitude: riderCooridate.latitude, longitude: riderCooridate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(riderCLLocation) { (placemarks, error) in
            if error != nil{
                print(error!)
            }else{
                if let okPlacemarks = placemarks{
                    if okPlacemarks.count > 0{
                        print(okPlacemarks[0])
                        // 真實地址
                        let placemark = MKPlacemark(placemark: okPlacemarks[0])
                        
                        let mapItem = MKMapItem(placemark: placemark)
                        
                        mapItem.name = self.riderInfo["email"] as? String
                        
                        let alertController = UIAlertController(title: "成功", message: "尋習已發送給這位乘客，請問是否要開啟導航（若離開此app將會唔發讓乘客時刻追蹤您的位置）", preferredStyle: .alert)

                        let confirmAction = UIAlertAction(title: "開啟導航", style: .default) { (action) in
                            
                            // 開啟導航
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                        }
                        alertController.addAction(confirmAction)

                        let cancelAction = UIAlertAction(title: "留在 app", style: .cancel) { (action) in
                            
                        }
                        alertController.addAction(cancelAction)

                        // 顯示警告框
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
