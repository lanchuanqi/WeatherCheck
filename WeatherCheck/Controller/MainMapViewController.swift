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
    var userDefaultLanguages: [AnyHashable]?
    
    //main page
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
    var homeButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(homeButtonClicked), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "weather"), for: .normal)
        return button
    }()
    
    @objc func homeButtonClicked(sender: UIButton){
        guard let location = self.getCurrentLocation() else{return}
        
        let camera = GMSCameraPosition.camera(withLatitude: (location.latitude), longitude: (location.longitude), zoom: 10.0)
        self.googleMapView.animate(to: camera)
        self.getCityNameByCoordinate(location: location) { (name) in
            if let cityName = name{
                APIHandler().getWeatherFromCityName(city: cityName, completion: { (weatherData) in
                    if let data = weatherData{
                        DispatchQueue.main.async {
                            self.setDetailViewLabels(data: data)
                            self.showPopUpView()
                        }
                    }
                })
            }
        }
    }
    func setDetailViewLabels(data: WeatherData){
        guard let mainDes = data.weather?[0].description else {return}
        self.weatherDescriptionLabel.text = mainDes
    }
    
    //detail page
    var popUpWeatherDetailView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = #colorLiteral(red: 1, green: 0.4054822537, blue: 0.3988908923, alpha: 1)
        return view
    }()
    var weatherDescriptionLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    var todayWeatherLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Today's Weather"
        label.textAlignment = .center
        
        return label
    }()
    var dismissPopUpViewButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(dismissPopUpViewButtonClicked), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    @objc func dismissPopUpViewButtonClicked(sender: UIButton){
        self.hidePopUpView()
    }
    
    func hidePopUpView(){
        self.popUpWeatherDetailView.isHidden = true
        self.dismissPopUpViewButton.isHidden = true
        self.weatherDescriptionLabel.isHidden = true
        self.todayWeatherLabel.isHidden = true
    }
    func showPopUpView(){
        self.popUpWeatherDetailView.isHidden = false
        self.dismissPopUpViewButton.isHidden = false
        self.weatherDescriptionLabel.isHidden = false
        self.todayWeatherLabel.isHidden = false
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
            let camera = GMSCameraPosition.camera(withLatitude: myLocation.coordinate.latitude, longitude:myLocation.coordinate.longitude, zoom: 10.0)
            googleMapView.animate(to: camera)
        }
    }
    func getCurrentLocation() -> CLLocationCoordinate2D?{
        if locationManager.location?.coordinate != nil {
            let location = locationManager.location?.coordinate
            self.locationManager.stopUpdatingLocation()
            return location
        } else {
            locationManager.requestWhenInUseAuthorization()
            return nil
        }
    }
    
    
    func getCityNameByCoordinate(location: CLLocationCoordinate2D, completion: @escaping (String?) -> ()){
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        userDefaultLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [AnyHashable]
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { (resultMarker, error) in
            UserDefaults.standard.set(self.userDefaultLanguages, forKey: "AppleLanguages")
            if let markerData = resultMarker?[0]{
                if let city = markerData.locality{
                    print(city)
                    completion(city)
                }
                else{
                    print("get city name failed.")
                    completion(nil)
                }
            }
            else{
                print("get marker data failed.")
                completion(nil)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpLocationAndMap()
    }
    override func viewDidAppear(_ animated: Bool) {
        updateLocationOnMap()
        hidePopUpView()
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
        
        self.view.addSubview(homeButton)
        homeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        homeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        homeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        homeButton.bottomAnchor.constraint(equalTo: self.barView.bottomAnchor, constant: -5).isActive = true
        
        self.view.addSubview(popUpWeatherDetailView)
        popUpWeatherDetailView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 30).isActive = true
        popUpWeatherDetailView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        popUpWeatherDetailView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        popUpWeatherDetailView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(dismissPopUpViewButton)
        dismissPopUpViewButton.centerXAnchor.constraint(equalTo: popUpWeatherDetailView.centerXAnchor).isActive = true
        dismissPopUpViewButton.bottomAnchor.constraint(equalTo: popUpWeatherDetailView.bottomAnchor, constant: -20).isActive = true
        dismissPopUpViewButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissPopUpViewButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.popUpWeatherDetailView.addSubview(todayWeatherLabel)
        todayWeatherLabel.topAnchor.constraint(equalTo: popUpWeatherDetailView.topAnchor, constant: 10).isActive = true
        todayWeatherLabel.leftAnchor.constraint(equalTo: popUpWeatherDetailView.leftAnchor, constant: 10).isActive = true
        todayWeatherLabel.rightAnchor.constraint(equalTo: popUpWeatherDetailView.rightAnchor, constant: -10).isActive = true
        todayWeatherLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.popUpWeatherDetailView.addSubview(weatherDescriptionLabel)
        weatherDescriptionLabel.topAnchor.constraint(equalTo: todayWeatherLabel.bottomAnchor, constant: 10).isActive = true
        weatherDescriptionLabel.leftAnchor.constraint(equalTo: popUpWeatherDetailView.leftAnchor, constant: 10).isActive = true
        weatherDescriptionLabel.rightAnchor.constraint(equalTo: popUpWeatherDetailView.rightAnchor, constant: -10).isActive = true
        weatherDescriptionLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
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
