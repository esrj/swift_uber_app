//
//  DriverTableViewController.swift
//  proj1
//
//  Created by sam on 2023/9/27.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class DriverTableViewController: UITableViewController ,CLLocationManagerDelegate{
    
    let reference : DatabaseReference = Database.database().reference()
    let locationManager = CLLocationManager()
    var AllRiderRequest : [[String:Any]] = []
    var driverCoordinate = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        retrieve()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { Timer in
            self.tableView.reloadData()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.driverCoordinate = manager.location!.coordinate
    }

    
    func retrieve(){
        reference.child("riderRequest").observe(.childAdded) { dataSnapshop in
            if let okDataSnapshop = dataSnapshop.value as? [String:Any]{
                self.AllRiderRequest.append(okDataSnapshop)
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData() // 在主线程刷新表格
                }
            }
        }
    }
    
    


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.AllRiderRequest.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! UserInfoTableViewCell
        let riderRequest = AllRiderRequest[indexPath.row]
        let riderLocation = CLLocation(latitude: riderRequest["latitude"] as! CLLocationDegrees , longitude: riderRequest["longitude"] as! CLLocationDegrees)
        let driverLocation = CLLocation(latitude: driverCoordinate.latitude, longitude: driverCoordinate.longitude)
        let distance = driverLocation.distance(from: riderLocation)/1000
        cell.userEmail.text = riderRequest["email"] as? String
        cell.detail.text = String(round(distance*1000)/1000)+" km"
//
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let riderInfo = self.AllRiderRequest[indexPath.row]        
        performSegue(withIdentifier: "pickUpRider", sender:  riderInfo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickUpRider"{
            if let PickupView = segue.destination as? PickupViewController{
                if let riderInfo = sender as? [String:Any]{
                    PickupView.riderInfo = riderInfo
                }
            }
        }
    }
    

    @IBAction func signOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "userLoggedIn")
            performSegue(withIdentifier: "DriverBackToLogin", sender: nil)

        }catch{
            
        }
    }
}
