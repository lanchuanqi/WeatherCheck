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

var detailPageLabelColor = UIColor.white
class MainMapViewController: UIViewController{

    
    //user setting
    let defaults = UserDefaults.standard
    var currentUnit = 1

    
    // 1 is Fahrenheit, 2 is Celsius
    var FahrenheitORCelsius = 1{
        didSet{
            self.degreeUnitChanged()
        }
    }
    private func degreeUnitChanged(){
        if self.FahrenheitORCelsius == 1{
            guard let data = self.weatherData else {
                self.getWeatherInfoByCoordinate()
                return}
            guard let temp = data.main?.temp else {return}
            self.leftWeatherDegreeLabel.text = String(HelpManager.convertKelvinToFahrenheit(kelvin: temp))
            self.leftWeatherFahrenheitLabel.text = "°F"
        }
        else if self.FahrenheitORCelsius == 2{
            guard let data = self.weatherData else {
                self.getWeatherInfoByCoordinate()
                return}
            guard let temp = data.main?.temp else {return}
            self.leftWeatherDegreeLabel.text = String(HelpManager.convertKelvinToCelsius(kelvin: temp))
            self.leftWeatherFahrenheitLabel.text = "°C"
        }
    }
    
    var locationManager = CLLocationManager()
    var userDefaultLanguages: [AnyHashable]?
    var weatherData: WeatherData?
    var currentCityName = "Unknown"

    var addMarkerMood = false
    
    //main page
    var googleMapView: GMSMapView = {
        var mapview = GMSMapView()
        mapview.isMyLocationEnabled = true
        //        self.googleMapView.settings.compassButton = true
        //        self.googleMapView.settings.myLocationButton = true
        //        self.googleMapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 120)
        mapview.mapType = .terrain
        return mapview
    }()
    var leftWeatherView: UIView = {
        var view = UIView()
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
        label.textColor = #colorLiteral(red: 0.2145102024, green: 0.5638168454, blue: 0.8173175454, alpha: 1)
        return label
    }()
    var leftWeatherFahrenheitLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "°F"
        label.font = UIFont(name: "bold", size: 8)
        label.textColor = #colorLiteral(red: 0.2145102024, green: 0.5638168454, blue: 0.8173175454, alpha: 1)
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
        if addMarkerMood{
            self.addMarkerMood = false
            self.hideLongPressViews()
        }
        else{
            self.addMarkerMood = true
            self.showLongPressViews()
        }
    }
    
    // settings view
    var settingSegmentedControl: UISegmentedControl = {
        var control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.insertSegment(withTitle: "°F", at: 0, animated: false)
        control.insertSegment(withTitle: "°C", at: 1, animated: false)
        control.backgroundColor = UIColor.white
        control.tintColor = UIColor.gray //#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        control.layer.cornerRadius = 5
        control.addTarget(self, action: #selector(segmentedControlChangedState), for: .valueChanged)
        return control
    }()
    
    var settingView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.929680975, green: 0.9745903284, blue: 1, alpha: 1)
        view.alpha = 0.85
        view.layer.cornerRadius = 15
        return view
    }()
    var settingUnitLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        label.minimumScaleFactor = 0.5
        label.textColor = UIColor.gray
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.text = "Unit: "
        return label
    }()
    @objc func segmentedControlChangedState(sender: UISegmentedControl){
        //°F is 0, °C is 1
        if sender.selectedSegmentIndex == 0{
            self.FahrenheitORCelsius = 1
            self.defaults.set(1, forKey: "ForC")
        }
        else{
            self.FahrenheitORCelsius = 2
            self.defaults.set(2, forKey: "ForC")
        }
    }
    
    var settingCloseButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.addTarget(self, action: #selector(settingCloseButtonClicked), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.setTitleColor(.gray, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        return button
    }()
    @objc func settingCloseButtonClicked(sender: UIButton){
        self.hideSettingView()
    }
    
    var settingButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "setting"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.alpha = 0.9
        button.addTarget(self, action: #selector(settingButtonClicked), for: .touchUpInside)
        return button
    }()
    
    @objc func settingButtonClicked(sender: UIButton){
        self.showSettingView()
    }
    
    //add marker view and label
    var longPressAddMarkerView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.alpha = 0.8
        view.backgroundColor = UIColor.white
        return view
    }()
    var longPressAddMarkerLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Long press on map to check the weather on that area. Press + again to cancel"
        label.numberOfLines = 2
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = #colorLiteral(red: 0.2073595822, green: 0.539472878, blue: 0.8177577853, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    private func hideLongPressViews(){
        self.longPressAddMarkerView.isHidden = true
        self.longPressAddMarkerLabel.isHidden = true
    }
    private func showLongPressViews(){
        self.longPressAddMarkerView.isHidden = false
        self.longPressAddMarkerLabel.isHidden = false
    }
    
    
    //Error label
    var apiCallFailedErrorLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        label.text = "Can't get the weather info on that area, please try again later."
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.backgroundColor = UIColor.white
        label.textColor = #colorLiteral(red: 0.2145102024, green: 0.5638168454, blue: 0.8173175454, alpha: 1)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.numberOfLines = 3
        return label
    }()
    
    
    //detail page
    var popUpWeatherDetailView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.white
        return view
    }()
    var popUpWeatherImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "BGsun")
        return imageView
    }()
    var popUpCityNameLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Unknown"
        label.textColor = detailPageLabelColor
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        label.textAlignment = .center
        return label
    }()
    var popUpDegreeLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue", size: 60)
        label.text = "107"
        label.minimumScaleFactor = 0.5
        label.textAlignment = .right
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpViewFahrenheitLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "°F"
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpViewSeparatorView1: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = detailPageLabelColor
        return view
    }()
    var popUpViewSeparatorView2: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = detailPageLabelColor
        return view
    }()
    var popUpViewSeparatorView3: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = detailPageLabelColor
        return view
    }()
    var popUpViewSeparatorView4: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = detailPageLabelColor
        return view
    }()
    var popUpViewSeparatorView5: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = detailPageLabelColor
        return view
    }()
    var popUpWindLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        label.text = "Wind"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpWindDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.text = "NNW 15m/s"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpCloudLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        label.text = "Cloudiness"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpCloudDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.text = "80%"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpHumidityLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        label.text = "Humidity"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpHumidityDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.text = "60%"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpPressureLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        label.text = "Pressure"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpPressureDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.text = "1234 hPa"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpVisiablityLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        label.text = "Visiablity"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpVisiablityDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.text = "56 m"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpDescriptionLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 10)
        label.text = "Description"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpDescriptionDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.text = "Clouds"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpSunriseLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        label.text = "Sunrise"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpSunriseDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.text = "7:10"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpSunsetLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        label.text = "Sunset"
        label.textAlignment = .center
        label.textColor = detailPageLabelColor
        return label
    }()
    var popUpSunsetDetailLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.text = "17:20"
        label.minimumScaleFactor = 0.5
        label.textColor = detailPageLabelColor
        label.textAlignment = .center
        return label
    }()
    var popUpViewCloseButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissPopUpViewButtonClicked), for: .touchUpInside)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.clear
        return button
    }()
    @objc func dismissPopUpViewButtonClicked(sender: UIButton){
        self.hidePopUpView()
    }
    
    //alert blur view
    var alertBlurView: UIView = {
        var view = UIView()
        view.alpha = 0.5
        view.backgroundColor = UIColor.black
        return view
    }()
    @objc func tapLeftWeatherViewShowPopUpView(_sender: UITapGestureRecognizer){
        if let data = self.weatherData {
            setUpPopUpViewUI(data: data)
        }
        else {
            if self.locationManager.location != nil{
                self.getWeatherInfoByCoordinate()
            }
            else{
                self.addBlurViewAndShowAlert()
            }
        }
    }
    func addBlurViewAndShowAlert(){
        self.alertBlurView.isHidden = false
        let alert = UIAlertController(title: "Enable Location", message: "Enable Location to check local weather detail.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: {(alertAction) in
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else{
                alert.dismiss(animated: true, completion: nil)
                self.alertBlurView.isHidden = true
                return
            }
            UIApplication.shared.open(url, completionHandler: { (result) in
                alert.dismiss(animated: true, completion: nil)
                self.alertBlurView.isHidden = true
            })
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction) in
            alert.dismiss(animated: true, completion: nil)
            self.alertBlurView.isHidden = true
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hidePopUpView(){
        self.popUpWeatherDetailView.isHidden = true
    }
    func showPopUpView(){
        self.popUpWeatherDetailView.isHidden = false
    }
    
    func setUpPopUpViewUI(data: WeatherData){
        guard let weatherCode = data.weather?[0].id else {return}
        guard let mainDes = data.weather?[0].main else {return}
        guard let temp = data.main?.temp else {return}
        guard let pressure = data.main?.pressure else {return}
        guard let humidity = data.main?.humidity else {return}
        let visiablity = data.visibility
        guard let cityName = data.name else {return}
        guard let cloud = data.clouds?.all else {return}
        guard let sunRise = data.sys?.sunrise else {return}
        guard let sunSet = data.sys?.sunset else {return}
        
        guard let windSpeed = data.wind?.speed else {return}
        var windDirection = ""
        let windSpeedOneDecimal = Double(round(10*windSpeed)/10)
        if let windDeg = data.wind?.deg{
             windDirection = HelpManager.convertWindDegreeToDirection(degree: windDeg)
            self.popUpWindDetailLabel.text = "\(windDirection) \(windSpeedOneDecimal)m/s"
        }
        else {
            self.popUpWindDetailLabel.text = "\(windSpeedOneDecimal)m/s"
        }
        
        var fahrenheit = 0
        if self.FahrenheitORCelsius == 1{
            fahrenheit = HelpManager.convertKelvinToFahrenheit(kelvin: temp)
            self.popUpViewFahrenheitLabel.text = "°F"
        }
        else if self.FahrenheitORCelsius == 2{
            fahrenheit = HelpManager.convertKelvinToCelsius(kelvin: temp)
            self.popUpViewFahrenheitLabel.text = "°C"
        }
        
        let sunrise = HelpManager.convertEpochToReadableTime(epoch: Double(sunRise))
        let sunset = HelpManager.convertEpochToReadableTime(epoch: Double(sunSet))
        
        self.popUpWeatherImageView.image = HelpManager.getWeatherBackgroundImageBasedOnWeatherConditionCode(code: weatherCode)
        self.popUpCityNameLabel.text = "\(cityName)"
        self.popUpDegreeLabel.text = "\(fahrenheit)"
        self.popUpCloudDetailLabel.text = "\(cloud)%"
        self.popUpHumidityDetailLabel.text = "\(humidity)%"
        self.popUpPressureDetailLabel.text = "\(pressure) hPa"
        self.popUpVisiablityDetailLabel.text = "\(visiablity) m"
        self.popUpDescriptionDetailLabel.text = mainDes
        self.popUpSunriseDetailLabel.text = sunrise
        self.popUpSunsetDetailLabel.text = sunset
        
        
        self.showPopUpView()
    }
    
    func updateLocationOnMap(){
        if let myLocation = locationManager.location{
            let camera = GMSCameraPosition.camera(withLatitude: myLocation.coordinate.latitude, longitude:myLocation.coordinate.longitude, zoom: 10.0)
            googleMapView.animate(to: camera)
        }
    }
    
    func getWeatherInfoByCoordinate(){
        if let location = self.locationManager.location?.coordinate{
            APIHandler.shared.getWeatherFromLocationCoordinates(lat: Double(round(10*location.latitude)/10), long: Double(round(10*location.longitude)/10)) { (data) in
                if let weatherData = data{
                    self.weatherData = weatherData
                    DispatchQueue.main.async {
                        if self.currentUnit != self.FahrenheitORCelsius{
                            self.FahrenheitORCelsius = self.currentUnit
                        }
                        self.updateMainUIBasedOnWeatherData(data: weatherData)
                    }
                }
            }
        }
    }
    func updateMainUIBasedOnWeatherData(data: WeatherData){
        guard let weatherId = data.weather?[0].id else {return}
        guard let temp = data.main?.temp else {return}
        if self.FahrenheitORCelsius == 1{
            self.leftWeatherDegreeLabel.text = String(HelpManager.convertKelvinToFahrenheit(kelvin: temp))
        }
        else{
            self.leftWeatherDegreeLabel.text = String(HelpManager.convertKelvinToCelsius(kelvin: temp))
        }
        self.leftWeatherIcon.image = HelpManager.getWeatherIconBasedOnWeatherConditionCode(code: weatherId)
    }

    func hideSettingView(){
        self.settingView.isHidden = true
    }
    func showSettingView(){
        if self.FahrenheitORCelsius == 1{
            self.settingSegmentedControl.selectedSegmentIndex = 0
        }
        else{
            self.settingSegmentedControl.selectedSegmentIndex = 1
        }
        
        self.settingView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpLocationAndMap()
    }
    override func viewDidAppear(_ animated: Bool) {
        updateLocationOnMap()
        
        //hide views
        hidePopUpView()
        hideLongPressViews()
        hideSettingView()
        self.alertBlurView.isHidden = true
        
        // update weather
        getWeatherInfoByCoordinate()
        getUserSettings()
        self.apiCallFailedErrorLabel.alpha = 0
    }
    
    func setUpViews(){
        self.view.addSubview(googleMapView)
        googleMapView.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, bottom: self.view.bottomAnchor)
        
        //left weather view and label
        self.view.addSubview(leftWeatherView)
        leftWeatherView.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, trailing: nil, bottom: nil, padding: UIEdgeInsets.init(top: 60, left: 20, bottom: 0, right: 0), size: CGSize.init(width: 100, height: 40))
        
        self.leftWeatherView.addSubview(leftWeatherIcon)
        leftWeatherIcon.topAnchor.constraint(equalTo: self.leftWeatherView.topAnchor, constant: 5).isActive = true
        leftWeatherIcon.leftAnchor.constraint(equalTo: self.leftWeatherView.leftAnchor, constant: 5).isActive = true
        leftWeatherIcon.bottomAnchor.constraint(equalTo: self.leftWeatherView.bottomAnchor, constant: -5).isActive = true
        leftWeatherIcon.widthAnchor.constraint(equalTo: self.leftWeatherIcon.heightAnchor, multiplier: 1).isActive = true
        
        self.leftWeatherView.addSubview(leftWeatherFahrenheitLabel)
        leftWeatherFahrenheitLabel.rightAnchor.constraint(equalTo: self.leftWeatherView.rightAnchor, constant: -5).isActive = true
        leftWeatherFahrenheitLabel.topAnchor.constraint(equalTo: self.leftWeatherView.topAnchor, constant: 5).isActive = true
        leftWeatherFahrenheitLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true
        leftWeatherFahrenheitLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.leftWeatherView.addSubview(leftWeatherDegreeLabel)
        leftWeatherDegreeLabel.topAnchor.constraint(equalTo: self.leftWeatherView.topAnchor, constant: 0).isActive = true
        leftWeatherDegreeLabel.leftAnchor.constraint(equalTo: self.leftWeatherIcon.rightAnchor, constant: 5).isActive = true
        leftWeatherDegreeLabel.bottomAnchor.constraint(equalTo: self.leftWeatherView.bottomAnchor, constant: -5).isActive = true
        leftWeatherDegreeLabel.rightAnchor.constraint(equalTo: self.leftWeatherFahrenheitLabel.leftAnchor, constant: 0).isActive = true
        
        let showPopUpViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapLeftWeatherViewShowPopUpView))
        self.leftWeatherView.addGestureRecognizer(showPopUpViewGesture)
        
        // setting button and plus button
        self.view.addSubview(settingButton)
        settingButton.centerYAnchor.constraint(equalTo: self.leftWeatherView.centerYAnchor).isActive = true
        settingButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40).isActive = true
        settingButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.view.addSubview(addCityMarkerButton)
        addCityMarkerButton.anchor(top: nil, leading: nil, trailing: self.view.trailingAnchor, bottom: self.view.bottomAnchor, padding: UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 50), size: CGSize.init(width: 60, height: 60))
        
        // settings view
        self.view.addSubview(settingView)
        settingView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40).isActive = true
        settingView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40).isActive = true
        settingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        settingView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5).isActive = true
        
        self.settingView.addSubview(settingUnitLabel)
        settingUnitLabel.anchor(top: settingView.topAnchor, leading: settingView.leadingAnchor, trailing: nil, bottom: nil, padding: UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 0), size: CGSize.init(width: 50, height: 30))
        
        self.settingView.addSubview(settingCloseButton)
        settingCloseButton.bottomAnchor.constraint(equalTo: self.settingView.bottomAnchor, constant: -20).isActive = true
        settingCloseButton.centerXAnchor.constraint(equalTo: self.settingView.centerXAnchor).isActive = true
        settingCloseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        settingCloseButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.settingView.addSubview(settingSegmentedControl)
        settingSegmentedControl.topAnchor.constraint(equalTo: settingView.topAnchor, constant: 20).isActive = true
        settingSegmentedControl.leftAnchor.constraint(equalTo: self.settingUnitLabel.rightAnchor, constant: 10).isActive = true
        settingSegmentedControl.widthAnchor.constraint(equalToConstant: 100).isActive = true
        settingSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        // Pop Up View
        self.view.addSubview(popUpWeatherDetailView)
        popUpWeatherDetailView.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, bottom: self.view.bottomAnchor, padding: UIEdgeInsets.init(top: 60, left: 30, bottom: 30, right: 30), size: .zero)
        
        self.popUpWeatherDetailView.addSubview(popUpWeatherImageView)
        popUpWeatherImageView.anchor(top: self.popUpWeatherDetailView.topAnchor, leading: self.popUpWeatherDetailView.leadingAnchor, trailing: self.popUpWeatherDetailView.trailingAnchor, bottom: self.popUpWeatherDetailView.bottomAnchor)
        
        self.popUpWeatherDetailView.addSubview(popUpCityNameLabel)
        popUpCityNameLabel.topAnchor.constraint(equalTo: self.popUpWeatherDetailView.topAnchor, constant: 5).isActive = true
        popUpCityNameLabel.centerXAnchor.constraint(equalTo: self.popUpWeatherDetailView.centerXAnchor).isActive = true
        popUpCityNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        popUpCityNameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpViewCloseButton)
        popUpViewCloseButton.bottomAnchor.constraint(equalTo: self.popUpWeatherDetailView.bottomAnchor, constant: -10).isActive = true
        popUpViewCloseButton.centerXAnchor.constraint(equalTo: self.popUpWeatherDetailView.centerXAnchor).isActive = true
        popUpViewCloseButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        popUpViewCloseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpDegreeLabel)
        popUpDegreeLabel.topAnchor.constraint(equalTo: self.popUpCityNameLabel.bottomAnchor, constant: 15).isActive = true
        popUpDegreeLabel.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor, constant: 10).isActive = true
        popUpDegreeLabel.widthAnchor.constraint(equalToConstant: 110).isActive = true
        popUpDegreeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpViewFahrenheitLabel)
        popUpViewFahrenheitLabel.topAnchor.constraint(equalTo: popUpDegreeLabel.topAnchor).isActive = true
        popUpViewFahrenheitLabel.leftAnchor.constraint(equalTo: self.popUpDegreeLabel.rightAnchor, constant: 5).isActive = true
        popUpViewFahrenheitLabel.widthAnchor.constraint(equalToConstant: 25).isActive = true
        popUpViewFahrenheitLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let popUpViewWidth = self.view.frame.size.width - 60
        
        self.popUpWeatherDetailView.addSubview(popUpViewSeparatorView1)
        popUpViewSeparatorView1.bottomAnchor.constraint(equalTo: self.popUpViewCloseButton.topAnchor, constant: -20).isActive = true
        popUpViewSeparatorView1.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor, constant: popUpViewWidth/3).isActive = true
        popUpViewSeparatorView1.widthAnchor.constraint(equalToConstant: 1).isActive = true
        popUpViewSeparatorView1.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpViewSeparatorView2)
        popUpViewSeparatorView2.bottomAnchor.constraint(equalTo: self.popUpViewCloseButton.topAnchor, constant: -20).isActive = true
        popUpViewSeparatorView2.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor, constant: popUpViewWidth/3*2).isActive = true
        popUpViewSeparatorView2.widthAnchor.constraint(equalToConstant: 1).isActive = true
        popUpViewSeparatorView2.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpViewSeparatorView3)
        popUpViewSeparatorView3.bottomAnchor.constraint(equalTo: self.popUpViewSeparatorView1.topAnchor, constant: -20).isActive = true
        popUpViewSeparatorView3.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor, constant: popUpViewWidth/3).isActive = true
        popUpViewSeparatorView3.widthAnchor.constraint(equalToConstant: 1).isActive = true
        popUpViewSeparatorView3.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpViewSeparatorView4)
        popUpViewSeparatorView4.bottomAnchor.constraint(equalTo: self.popUpViewSeparatorView2.topAnchor, constant: -20).isActive = true
        popUpViewSeparatorView4.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor, constant: popUpViewWidth/3*2).isActive = true
        popUpViewSeparatorView4.widthAnchor.constraint(equalToConstant: 1).isActive = true
        popUpViewSeparatorView4.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpViewSeparatorView5)
        popUpViewSeparatorView5.bottomAnchor.constraint(equalTo: self.popUpViewSeparatorView3.topAnchor, constant: -20).isActive = true
        popUpViewSeparatorView5.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor, constant: popUpViewWidth/2).isActive = true
        popUpViewSeparatorView5.widthAnchor.constraint(equalToConstant: 1).isActive = true
        popUpViewSeparatorView5.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        self.popUpWeatherDetailView.addSubview(popUpWindLabel)
        popUpWindLabel.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor).isActive = true
        popUpWindLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView3.leftAnchor).isActive = true
        popUpWindLabel.topAnchor.constraint(equalTo: self.popUpViewSeparatorView3.topAnchor, constant: 5).isActive = true
        popUpWindLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpWindDetailLabel)
        popUpWindDetailLabel.topAnchor.constraint(equalTo: self.popUpWindLabel.bottomAnchor).isActive = true
        popUpWindDetailLabel.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor).isActive = true
        popUpWindDetailLabel.rightAnchor.constraint(equalTo: popUpViewSeparatorView3.leftAnchor).isActive = true
        popUpWindDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpCloudLabel)
        popUpCloudLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView3.rightAnchor).isActive = true
        popUpCloudLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView4.leftAnchor).isActive = true
        popUpCloudLabel.topAnchor.constraint(equalTo: popUpViewSeparatorView3.topAnchor, constant: 5).isActive = true
        popUpCloudLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpCloudDetailLabel)
        popUpCloudDetailLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView3.rightAnchor).isActive = true
        popUpCloudDetailLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView4.leftAnchor).isActive = true
        popUpCloudDetailLabel.topAnchor.constraint(equalTo: popUpCloudLabel.bottomAnchor).isActive = true
        popUpCloudDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpHumidityLabel)
        popUpHumidityLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView4.rightAnchor).isActive = true
        popUpHumidityLabel.rightAnchor.constraint(equalTo: self.popUpWeatherDetailView.rightAnchor).isActive = true
        popUpHumidityLabel.topAnchor.constraint(equalTo: popUpViewSeparatorView4.topAnchor, constant: 5).isActive = true
        popUpHumidityLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpHumidityDetailLabel)
        popUpHumidityDetailLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView4.rightAnchor).isActive = true
        popUpHumidityDetailLabel.rightAnchor.constraint(equalTo: self.popUpWeatherDetailView.rightAnchor).isActive = true
        popUpHumidityDetailLabel.topAnchor.constraint(equalTo: popUpHumidityLabel.bottomAnchor).isActive = true
        popUpHumidityDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpPressureLabel)
        popUpPressureLabel.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor).isActive = true
        popUpPressureLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView1.leftAnchor).isActive = true
        popUpPressureLabel.topAnchor.constraint(equalTo: popUpViewSeparatorView1.topAnchor, constant: 5).isActive = true
        popUpPressureLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpPressureDetailLabel)
        popUpPressureDetailLabel.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor).isActive = true
        popUpPressureDetailLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView1.leftAnchor).isActive = true
        popUpPressureDetailLabel.topAnchor.constraint(equalTo: popUpPressureLabel.bottomAnchor).isActive = true
        popUpPressureDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpVisiablityLabel)
        popUpVisiablityLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView1.rightAnchor).isActive = true
        popUpVisiablityLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView2.leftAnchor).isActive = true
        popUpVisiablityLabel.topAnchor.constraint(equalTo: popUpViewSeparatorView1.topAnchor, constant: 5).isActive = true
        popUpVisiablityLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpVisiablityDetailLabel)
        popUpVisiablityDetailLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView1.rightAnchor).isActive = true
        popUpVisiablityDetailLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView2.leftAnchor).isActive = true
        popUpVisiablityDetailLabel.topAnchor.constraint(equalTo: popUpVisiablityLabel.bottomAnchor).isActive = true
        popUpVisiablityDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.popUpWeatherDetailView.addSubview(popUpDescriptionLabel)
        popUpDescriptionLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView2.rightAnchor).isActive = true
        popUpDescriptionLabel.rightAnchor.constraint(equalTo: self.popUpWeatherDetailView.rightAnchor).isActive = true
        popUpDescriptionLabel.topAnchor.constraint(equalTo: popUpViewSeparatorView1.topAnchor, constant: 5).isActive = true
        popUpDescriptionLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpDescriptionDetailLabel)
        popUpDescriptionDetailLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView2.rightAnchor).isActive = true
        popUpDescriptionDetailLabel.rightAnchor.constraint(equalTo: self.popUpWeatherDetailView.rightAnchor).isActive = true
        popUpDescriptionDetailLabel.topAnchor.constraint(equalTo: popUpDescriptionLabel.bottomAnchor).isActive = true
        popUpDescriptionDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.popUpWeatherDetailView.addSubview(popUpSunriseLabel)
        popUpSunriseLabel.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor).isActive = true
        popUpSunriseLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView5.leftAnchor).isActive = true
        popUpSunriseLabel.topAnchor.constraint(equalTo: popUpViewSeparatorView5.topAnchor, constant: 5).isActive = true
        popUpSunriseLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        self.popUpWeatherDetailView.addSubview(popUpSunriseDetailLabel)
        popUpSunriseDetailLabel.leftAnchor.constraint(equalTo: self.popUpWeatherDetailView.leftAnchor).isActive = true
        popUpSunriseDetailLabel.rightAnchor.constraint(equalTo: self.popUpViewSeparatorView5.leftAnchor).isActive = true
        popUpSunriseDetailLabel.topAnchor.constraint(equalTo: popUpSunriseLabel.bottomAnchor).isActive = true
        popUpSunriseDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

        self.popUpWeatherDetailView.addSubview(popUpSunsetLabel)
        popUpSunsetLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView5.rightAnchor).isActive = true
        popUpSunsetLabel.rightAnchor.constraint(equalTo: self.popUpWeatherDetailView.rightAnchor).isActive = true
        popUpSunsetLabel.topAnchor.constraint(equalTo: popUpViewSeparatorView5.topAnchor, constant: 5).isActive = true
        popUpSunsetLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        self.popUpWeatherDetailView.addSubview(popUpSunsetDetailLabel)
        popUpSunsetDetailLabel.leftAnchor.constraint(equalTo: self.popUpViewSeparatorView5.rightAnchor).isActive = true
        popUpSunsetDetailLabel.rightAnchor.constraint(equalTo: self.popUpWeatherDetailView.rightAnchor).isActive = true
        popUpSunsetDetailLabel.topAnchor.constraint(equalTo: popUpSunsetLabel.bottomAnchor).isActive = true
        popUpSunsetDetailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        //long press notification view and label
        self.view.addSubview(longPressAddMarkerView)
        longPressAddMarkerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150).isActive = true
        longPressAddMarkerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        longPressAddMarkerView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        longPressAddMarkerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.view.addSubview(longPressAddMarkerLabel)
        longPressAddMarkerLabel.centerXAnchor.constraint(equalTo: self.longPressAddMarkerView.centerXAnchor).isActive = true
        longPressAddMarkerLabel.centerYAnchor.constraint(equalTo: self.longPressAddMarkerView.centerYAnchor).isActive = true
        longPressAddMarkerLabel.leftAnchor.constraint(equalTo: self.longPressAddMarkerView.leftAnchor, constant: 5).isActive = true
        longPressAddMarkerLabel.rightAnchor.constraint(equalTo: self.longPressAddMarkerView.rightAnchor, constant: -5).isActive = true
        
        self.view.addSubview(apiCallFailedErrorLabel)
        apiCallFailedErrorLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        apiCallFailedErrorLabel.topAnchor.constraint(equalTo: self.longPressAddMarkerView.bottomAnchor, constant: 20).isActive = true
        apiCallFailedErrorLabel.leftAnchor.constraint(equalTo: self.longPressAddMarkerView.leftAnchor, constant: 5).isActive = true
        apiCallFailedErrorLabel.rightAnchor.constraint(equalTo: self.longPressAddMarkerView.rightAnchor, constant: -5).isActive = true
        
        self.view.addSubview(alertBlurView)
        alertBlurView.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, bottom: self.view.bottomAnchor)
    }
    
    func setUpLocationAndMap(){
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()

        self.googleMapView.delegate = self
    }
    func getUserSettings(){
        let degreeSetting = self.defaults.integer(forKey: "ForC")
        
        if degreeSetting == 0{
            //means this value does not exist and set default as F
            self.defaults.set(1, forKey: "ForC")
        }
        else{
            self.currentUnit = degreeSetting
            //self.FahrenheitORCelsius = degreeSetting
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


extension MainMapViewController: GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if self.addMarkerMood{
            APIHandler.shared.getWeatherFromLocationCoordinates(lat: coordinate.latitude, long: coordinate.longitude, completion: { (data) in
                if let weatherData = data{
                    self.addMarkerToGoogleMap(mapView, coordinate: coordinate, data: weatherData)
                }
                else{
                    self.showErrorMessageForThreeSecond()
                }
            })
            self.addMarkerMood = false
            self.hideLongPressViews()
        }
    }
    private func showErrorMessageForThreeSecond(){
        DispatchQueue.main.async {
            self.apiCallFailedErrorLabel.alpha = 1
            UIView.animate(withDuration: 2, delay: 1, options: .allowAnimatedContent, animations: {
                self.apiCallFailedErrorLabel.alpha = 0
            })
        }
    }
    
    private func addMarkerToGoogleMap(_ mapView: GMSMapView, coordinate: CLLocationCoordinate2D, data: WeatherData){
        let marker = GMSMarker(position: coordinate)
        guard let weatheCode = data.weather?[0].id else {return}
        marker.map = mapView
        marker.userData = data
        marker.icon = HelpManager.getWeatherMarkerIconBasedOnWeatherConditionCode(code: weatheCode)
        marker.appearAnimation = .pop
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let weatherDetail = marker.userData as? WeatherData else {
            print("can't get weather detail")
            return false}
        self.setUpPopUpViewUI(data: weatherDetail)
        return true
    }
}







//known bug

/*
 1. degree still is F every time open app, after add core data should be fine
 */












