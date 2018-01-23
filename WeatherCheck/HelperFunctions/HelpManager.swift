//
//  HelpManager.swift
//  WeatherCheck
//
//  Created by logan on 16/01/2018.
//  Copyright © 2018 Chuanqi. All rights reserved.
//

import Foundation
import UIKit

struct HelpManager{
    static func convertWindDegreeToDirection(degree: Double) -> String{
        switch degree {
        case 348.75 ... 360:
            return "N"
        case 0 ... 11.25:
            return "N"
        case 11.25 ... 33.75:
            return "NNE"
        case 33.75 ... 56.25:
            return "NE"
        case 56.25 ... 78.75:
            return "ENE"
        case 78.75 ... 101.25:
            return "E"
        case 101.25 ... 123.75:
            return "ESE"
        case 123.75 ... 146.25:
            return "SE"
        case 146.25 ... 168.75:
            return "SSE"
        case 168.75 ... 191.25:
            return "S"
        case 191.25 ... 213.75:
            return "SSW"
        case 213.75 ... 236.25:
            return "SW"
        case 236.25 ... 258.75:
            return "WSW"
        case 258.75 ... 281.25:
            return "W"
        case 281.25 ... 303.75:
            return "WNW"
        case 303.75 ... 326.25:
            return "NW"
        case 326.25 ... 348.75:
            return "NNW"
        default:
            return "Unknow Direction"
        }
    }
    
    static func convertKelvinToFahrenheit(kelvin: Double) -> Int{
        return Int(kelvin * 9/5 - 459.67)
    }
    
    
    static func convertEpochToReadableTime(epoch: Double) -> String{
        let date = Date(timeIntervalSince1970: epoch)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = NSTimeZone.local
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        return "\(hour):\(minutes)"
    }
    
    static func getWeatherIconBasedOnWeatherConditionCode(code: Int) -> UIImage{
        switch code {
        case 200 ... 233:
            //should be Thunderstorm
            return #imageLiteral(resourceName: "rain")
        case 300 ... 322:
            //Drizzle
            return #imageLiteral(resourceName: "rain")
        case 500 ... 532:
            //rain
            return #imageLiteral(resourceName: "rain")
        case 600 ... 623:
            //snow
            return #imageLiteral(resourceName: "snow")
        case 701 ... 782:
            //Atmosphere
            return #imageLiteral(resourceName: "wind")
        case 800:
            //clear sky
            return #imageLiteral(resourceName: "sun")
        case 801 ... 805:
            //clouds
            return #imageLiteral(resourceName: "cloud")
        case 951 ... 963:
            //Additional wind conditions   calm -> hurricane
            return #imageLiteral(resourceName: "wind")
        case 900 ... 907:
            //Extreme conditions
            return #imageLiteral(resourceName: "cloud")
        default:
            //Unknown conditions
            return #imageLiteral(resourceName: "cloud")
        }
    }
    
//        func getCityNameByCoordinate(location: CLLocationCoordinate2D, completion: @escaping (String?) -> ()){
//            let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//    
//            userDefaultLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [AnyHashable]
//            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
//            let geoCoder = CLGeocoder()
//            geoCoder.reverseGeocodeLocation(currentLocation) { (resultMarker, error) in
//                UserDefaults.standard.set(self.userDefaultLanguages, forKey: "AppleLanguages")
//                if let markerData = resultMarker?[0]{
//                    if let city = markerData.locality{
//    //                    self.todayWeatherLabel.text = "Today's Weather at " + city
//                        completion(city)
//                    }
//                    else{
//                        print("get city name failed.")
//                        completion(nil)
//                    }
//                }
//                else{
//                    print("get marker data failed.")
//                    completion(nil)
//                }
//            }
//        }
    
    //    func getWeatherInfoByCityName(){
    //        guard let location = self.getCurrentLocation() else{return}
    //        let camera = GMSCameraPosition.camera(withLatitude: (location.latitude), longitude: (location.longitude), zoom: 10.0)
    //        self.googleMapView.animate(to: camera)
    //        self.getCityNameByCoordinate(location: location) { (name) in
    //            if let cityName = name{
    //                APIHandler().getWeatherFromCityName(city: cityName, completion: { (weatherData) in
    //                    if let data = weatherData{
    //                        DispatchQueue.main.async {
    //                            self.setDetailViewLabels(data: data)
    ////                            self.weatherDeatilTableView.reloadData()
    ////                            self.showPopUpView()
    //                        }
    //                    }
    //                })
    //            }
    //        }
    //    }
    
    //    func setDetailViewLabels(data: WeatherData){
    //        guard let base = data.base else {return}
    //        guard let mainDes = data.weather?[0].description else {return}
//            guard let temp = data.main?.temp else {return}
//            guard let pressure = data.main?.pressure else {return}
//            guard let humidity = data.main?.humidity else {return}
//    
//            let visiablity = data.visibility
//            guard let windSpeed = data.wind?.speed else {return}
//            guard let windDeg = data.wind?.deg else {return}
//            guard let cloud = data.clouds?.all else {return}
//            guard let sunrise = data.sys?.sunrise else {return}
//            guard let sunset = data.sys?.sunset else {return}
//    
//            let fahrenheit = HelpManager.convertKelvinToFahrenheit(kelvin: temp)
//            self.leftWeatherDegreeLabel.text = "\(Int(fahrenheit))"
//    
//            let windDirection = HelpManager.convertWindDegreeToDirection(degree: windDeg)
//            let windSpeedOneDecimal = Double(round(10*windSpeed)/10)
    //        print("\(windDirection) \(windSpeedOneDecimal)m/s")
    //
    //        let cloudiness = Int(cloud)
    //        print("cloudiness: \(cloudiness)%")
    //        print("Atmospheric pressure: \(pressure)hPa")
    //        print("Humidity: \(humidity)%")
    //        print("sunrise: \(sunrise), sunset: \(sunset)")
    //        print("visiablity: \(visiablity)")
    //        print("mainDes: \(mainDes)")
    //        print("base: \(base)")
    //
    //    }
}


