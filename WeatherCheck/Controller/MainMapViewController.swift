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
    var detailTableCellId = "detailTableCell"
    var weatherDetailList = [String]()
    var weatherData: WeatherData?
    
    
    
    //main page
    var googleMapView: GMSMapView = {
        var mapview = GMSMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    var leftWeatherView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
        return view
    }()
    var leftWeatherIcon: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "sun")
        imageView.backgroundColor = UIColor.white
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    var leftWeatherDegreeLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        label.text = "0"
        label.minimumScaleFactor = 0.5
        label.textAlignment = .right
        return label
    }()
    var leftWeatherFahrenheitLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "°F"
        label.font = UIFont(name: "bold", size: 8)
        return label
    }()
    
    var addCityMarkerButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(addMarkerButtonClicked), for: .touchUpInside)
        return button
    }()
    
    @objc func addMarkerButtonClicked(sender: UIButton){
        print("add marker")
    }
    
    
    var barView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 1, green: 0.4054822537, blue: 0.3988908923, alpha: 1)
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
        print("home button clicked")
    }

    //detail page
    var popUpWeatherDetailView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = #colorLiteral(red: 1, green: 0.4054822537, blue: 0.3988908923, alpha: 1)
        return view
    }()

    var todayWeatherLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        
        return label
    }()
    var weatherDeatilTableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 15
        return tableView
    }()
    
    var dismissPopUpViewButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 0.4054822537, blue: 0.3988908923, alpha: 1), for: .normal)
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
        self.todayWeatherLabel.isHidden = true
        self.weatherDeatilTableView.isHidden = true
    }
    func showPopUpView(){
        self.popUpWeatherDetailView.isHidden = false
        self.dismissPopUpViewButton.isHidden = false
        self.todayWeatherLabel.isHidden = false
        self.weatherDeatilTableView.isHidden = false
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
                    self.todayWeatherLabel.text = "Today's Weather at " + city
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
    func getWeatherInfoByCoordinate(){
        guard let location = self.getCurrentLocation() else {return}
        APIHandler().getWeatherFromLocationCoordinates(lat: location.latitude, long: location.longitude) { (data) in
            if let weatherData = data{
                DispatchQueue.main.async {
                    self.updateMainUIBasedOnWeatherData(data: weatherData)
                }
                
            }
        }
    }
    func updateMainUIBasedOnWeatherData(data: WeatherData){
        guard let weatherId = data.weather?[0].id else {return}
        guard let temp = data.main?.temp else {return}
        self.leftWeatherDegreeLabel.text = String(HelpManager.convertKelvinToFahrenheit(kelvin: temp))
        self.leftWeatherIcon.image = HelpManager.getWeatherIconBasedOnWeatherConditionCode(code: weatherId)
    }
    
    
    func getWeatherInfoByCityName(){
        guard let location = self.getCurrentLocation() else{return}
        let camera = GMSCameraPosition.camera(withLatitude: (location.latitude), longitude: (location.longitude), zoom: 10.0)
        self.googleMapView.animate(to: camera)
        self.getCityNameByCoordinate(location: location) { (name) in
            if let cityName = name{
                APIHandler().getWeatherFromCityName(city: cityName, completion: { (weatherData) in
                    if let data = weatherData{
                        DispatchQueue.main.async {
                            self.setDetailViewLabels(data: data)
//                            self.weatherDeatilTableView.reloadData()
//                            self.showPopUpView()
                        }
                    }
                })
            }
        }
    }
    func setDetailViewLabels(data: WeatherData){
        guard let base = data.base else {return}
        guard let mainDes = data.weather?[0].description else {return}
        guard let temp = data.main?.temp else {return}
        guard let pressure = data.main?.pressure else {return}
        guard let humidity = data.main?.humidity else {return}
//        guard let tempMin = data.main?.temp_min else {return}
//        guard let tempMax = data.main?.temp_max else {return}
        let visiablity = data.visibility
        guard let windSpeed = data.wind?.speed else {return}
        guard let windDeg = data.wind?.deg else {return}
        guard let cloud = data.clouds?.all else {return}
        guard let sunrise = data.sys?.sunrise else {return}
        guard let sunset = data.sys?.sunset else {return}
        
//        self.weatherDetailList.removeAll()
//        self.weatherDetailList.append("Base Description: \(base)")
//        self.weatherDetailList.append("Main Description: \(mainDes)")
//        self.weatherDetailList.append("Current Temperature: \(temp)")
//        self.weatherDetailList.append("Today's Temperature: \(tempMin) - \(tempMax)")
//        self.weatherDetailList.append("Humidity: \(humidity)%")
//        self.weatherDetailList.append("Atmospheric Pressure: \(pressure)")
//        self.weatherDetailList.append("Visiablity: \(visiablity)")
//        self.weatherDetailList.append("WindSpeed: \(windSpeed)")
//        self.weatherDetailList.append("WindDegree: \(windDeg)")
//        self.weatherDetailList.append("Cloud: \(cloud)")
//        self.weatherDetailList.append("Sunrise to Sunset: \(sunrise) - \(sunset)")
        
        let fahrenheit = HelpManager.convertKelvinToFahrenheit(kelvin: temp)
        self.leftWeatherDegreeLabel.text = "\(Int(fahrenheit))"
        
        let windDirection = HelpManager.convertWindDegreeToDirection(degree: windDeg)
        let windSpeedOneDecimal = Double(round(10*windSpeed)/10)
        print("\(windDirection) \(windSpeedOneDecimal)m/s")
        
        let cloudiness = Int(cloud)
        print("cloudiness: \(cloudiness)%")
        print("Atmospheric pressure: \(pressure)hPa")
        print("Humidity: \(humidity)%")
        print("sunrise: \(sunrise), sunset: \(sunset)")
        print("visiablity: \(visiablity)")
        print("mainDes: \(mainDes)")
        print("base: \(base)")
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpLocationAndMap()
        setUpTableView()
    }
    override func viewDidAppear(_ animated: Bool) {
        updateLocationOnMap()
        hidePopUpView()
        getWeatherInfoByCoordinate()
    }
    
    func setUpViews(){
        self.view.addSubview(googleMapView)
        googleMapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        googleMapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        googleMapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        googleMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
//        self.view.addSubview(barView)
//        barView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        barView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        barView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        barView.heightAnchor.constraint(equalToConstant: 80).isActive = true
//
        
        self.view.addSubview(leftWeatherView)
        leftWeatherView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        leftWeatherView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        leftWeatherView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        leftWeatherView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.leftWeatherView.addSubview(leftWeatherIcon)
        leftWeatherIcon.topAnchor.constraint(equalTo: self.leftWeatherView.topAnchor, constant: 5).isActive = true
        leftWeatherIcon.leftAnchor.constraint(equalTo: self.leftWeatherView.leftAnchor, constant: 5).isActive = true
        leftWeatherIcon.bottomAnchor.constraint(equalTo: self.leftWeatherView.bottomAnchor, constant: -5).isActive = true
        leftWeatherIcon.widthAnchor.constraint(equalTo: self.leftWeatherIcon.heightAnchor, multiplier: 1).isActive = true
        
        self.leftWeatherView.addSubview(leftWeatherFahrenheitLabel)
        leftWeatherFahrenheitLabel.rightAnchor.constraint(equalTo: self.leftWeatherView.rightAnchor, constant: -5).isActive = true
        leftWeatherFahrenheitLabel.topAnchor.constraint(equalTo: self.leftWeatherView.topAnchor, constant: 12).isActive = true
        leftWeatherFahrenheitLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true
        leftWeatherFahrenheitLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.leftWeatherView.addSubview(leftWeatherDegreeLabel)
        leftWeatherDegreeLabel.topAnchor.constraint(equalTo: self.leftWeatherView.topAnchor, constant: 5).isActive = true
        leftWeatherDegreeLabel.leftAnchor.constraint(equalTo: self.leftWeatherIcon.rightAnchor, constant: 5).isActive = true
        leftWeatherDegreeLabel.bottomAnchor.constraint(equalTo: self.leftWeatherView.bottomAnchor, constant: -5).isActive = true
        leftWeatherDegreeLabel.rightAnchor.constraint(equalTo: self.leftWeatherFahrenheitLabel.leftAnchor, constant: 0).isActive = true
        
        self.view.addSubview(homeButton)
        homeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        homeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        homeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        homeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        
        self.view.addSubview(addCityMarkerButton)
        addCityMarkerButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -50).isActive = true
        addCityMarkerButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        addCityMarkerButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addCityMarkerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Pop Up View
        self.view.addSubview(popUpWeatherDetailView)
        popUpWeatherDetailView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
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
        
        self.popUpWeatherDetailView.addSubview(weatherDeatilTableView)
        weatherDeatilTableView.topAnchor.constraint(equalTo: todayWeatherLabel.bottomAnchor, constant: 10).isActive = true
        weatherDeatilTableView.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor, constant: 10).isActive = true
        weatherDeatilTableView.rightAnchor.constraint(equalTo: self.popUpWeatherDetailView.rightAnchor, constant: -10).isActive = true
        weatherDeatilTableView.bottomAnchor.constraint(equalTo: self.dismissPopUpViewButton.topAnchor, constant: -10).isActive = true
        
        
    }
    
    func setUpLocationAndMap(){
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        self.googleMapView.delegate = self
        self.googleMapView.isMyLocationEnabled = true
    }
    
    func setUpTableView(){
        self.weatherDeatilTableView.delegate = self
        self.weatherDeatilTableView.dataSource = self
        self.weatherDeatilTableView.register(WeatherDetailTableViewCell.self, forCellReuseIdentifier: detailTableCellId)
        self.weatherDeatilTableView.separatorColor = #colorLiteral(red: 1, green: 0.4054822537, blue: 0.3988908923, alpha: 1)
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
extension MainMapViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherDetailList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: detailTableCellId, for: indexPath) as! WeatherDetailTableViewCell

        cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.4054822537, blue: 0.3988908923, alpha: 1)
        cell.textLabel?.text = self.weatherDetailList[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}





