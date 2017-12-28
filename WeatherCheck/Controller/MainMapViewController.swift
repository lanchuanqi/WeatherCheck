//
//  ViewController.swift
//  WeatherCheck
//
//  Created by logan on 28/12/2017.
//  Copyright © 2017 Chuanqi. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation
import MapKit


class MainMapViewController: UIViewController, GMSMapViewDelegate{
    var locationManager = CLLocationManager()

    
    var googleMapView: GMSMapView = {
        var mapview = GMSMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    var barView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return view
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpLocationAndMap()
    }
    override func viewDidAppear(_ animated: Bool) {
        updateLocationOnMap()
    }
    
    func setUpViews(){
        self.view.addSubview(googleMapView)
        googleMapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        googleMapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        googleMapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        googleMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.view.addSubview(barView)
        barView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        barView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        barView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        barView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
    }
    
    func setUpLocationAndMap(){
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        self.googleMapView.delegate = self
        self.googleMapView.isMyLocationEnabled = true
    }
    
    func updateLocationOnMap(){
        if let myLocation = locationManager.location{
            let camera = GMSCameraPosition.camera(withLatitude: myLocation.coordinate.latitude, longitude:myLocation.coordinate.longitude, zoom: 18.0)
            googleMapView.animate(to: camera)
        }
    }
    
    
}

extension MainMapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            self.updateLocationOnMap()
            break
        case .authorizedAlways:
            self.updateLocationOnMap()
            break
        default:
            break
        }
    }
}
