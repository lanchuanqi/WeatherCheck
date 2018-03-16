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
        return Int(kelvin * 1.8 - 459.67)
    }
    
    static func convertKelvinToCelsius(kelvin: Double) -> Int{
        return Int(kelvin - 273.15)
    }
    
    static func convertCelsiusToFahrenheit(celsius: Double) -> Int{
        return Int(celsius * 1.8 - 32)
    }
    
    static func convertFahrenheitToCelsius(fahrenheit: Double) -> Int{
        return Int((fahrenheit - 32)/1.8)
    }
    
    static func convertEpochToReadableTime(epoch: Double) -> String{
        let date = Date(timeIntervalSince1970: epoch)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = NSTimeZone.system
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        return "\(hour):\(minutes)"
    }
    
    static func getWeatherIconBasedOnWeatherConditionCode(code: Int) -> UIImage{
        switch code {
        case 200 ..< 233:
            //Thunderstorm
            return #imageLiteral(resourceName: "thunderstorm")
        case 300 ..< 322:
            //Drizzle
            return #imageLiteral(resourceName: "drizzle")
        case 500 ..< 532:
            //rain
            return #imageLiteral(resourceName: "rain")
        case 600 ..< 623:
            //snow
            return #imageLiteral(resourceName: "heavySnow")
        case 701 ..< 782:
            //Atmosphere
            return #imageLiteral(resourceName: "fog")
        case 800:
            //clear sky
            return #imageLiteral(resourceName: "sun")
        case 801 ..< 803:
            //clouds
            return #imageLiteral(resourceName: "smallCloud")
        case 803 ..< 805:
            //broken cloud
            return #imageLiteral(resourceName: "cloud")
        case 951 ..< 957:
            //Additional wind conditions
            return #imageLiteral(resourceName: "wind-1")
        case 957 ..< 963:
            //hurricane
            return #imageLiteral(resourceName: "hurricane")
        case 900 ..< 907:
            //Extreme conditions
            return #imageLiteral(resourceName: "wind")
        default:
            //Unknown conditions
            return #imageLiteral(resourceName: "sun")
        }
    }
    
    static func getWeatherMarkerIconBasedOnWeatherConditionCode(code: Int) -> UIImage{
        switch code {
        case 200 ..< 233:
            //Thunderstorm
            return #imageLiteral(resourceName: "markerThunderstorm")
        case 300 ..< 322:
            //Drizzle
            return #imageLiteral(resourceName: "markerDizzle")
        case 500 ..< 532:
            //rain
            return #imageLiteral(resourceName: "markerRain")
        case 600 ..< 623:
            //snow
            return #imageLiteral(resourceName: "markerHeavySnow")
        case 701 ..< 782:
            //Atmosphere
            return #imageLiteral(resourceName: "markerFog")
        case 800:
            //clear sky
            return #imageLiteral(resourceName: "markerSun")
        case 801 ..< 803:
            //clouds
            return #imageLiteral(resourceName: "markerSmallCloud")
        case 803 ..< 805:
            //broken cloud
            return #imageLiteral(resourceName: "markerCloud")
        case 951 ..< 957:
            //Additional wind conditions
            return #imageLiteral(resourceName: "markerWind")
        case 957 ..< 963:
            //hurricane
            return #imageLiteral(resourceName: "markerHurricane")
        case 900 ..< 907:
            //Extreme conditions
            return #imageLiteral(resourceName: "markerWind-1")
        default:
            //Unknown conditions
            return #imageLiteral(resourceName: "markerSun")
        }
    }
    
    static func getWeatherBackgroundImageBasedOnWeatherConditionCode(code: Int) -> UIImage{
        switch code {
        case 200 ... 233:
            //Thunderstorm leibao
            return #imageLiteral(resourceName: "BGrain")
        case 300 ... 322:
            //Drizzle  xiaoyu
            return #imageLiteral(resourceName: "BGrain")
        case 500 ... 532:
            //rain   dayu
            return #imageLiteral(resourceName: "BGrain")
        case 600 ... 623:
            //snow   xiaxue
            return #imageLiteral(resourceName: "BGsnow")
            
            
            
        case 701 ... 782:
            //Atmosphere wu
            return #imageLiteral(resourceName: "BGsun")
        case 800:
            //clear sky  qingtian
            return #imageLiteral(resourceName: "BGsun")
        case 801 ... 805:
            //clouds   shaoyun
            return #imageLiteral(resourceName: "BGcloud")
        case 951 ... 957:
            //Additional wind conditions   calm  weifeng
            return #imageLiteral(resourceName: "BGsun")
        case 957 ... 963:
            //hurricane
            return #imageLiteral(resourceName: "BGsun")
        case 900 ... 907:
            //Extreme conditions
            return #imageLiteral(resourceName: "BGsun")
        default:
            //Unknown conditions
            return #imageLiteral(resourceName: "BGsun")
        }
    }
    
    
    
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
    
//    func getCityNameByCoordinate(location: CLLocationCoordinate2D, completion: @escaping (String?) -> ()){
//        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//        userDefaultLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [AnyHashable]
//        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
//        let geoCoder = CLGeocoder()
//        geoCoder.reverseGeocodeLocation(currentLocation) { (resultMarker, error) in
//            UserDefaults.standard.set(self.userDefaultLanguages, forKey: "AppleLanguages")
//            if let markerData = resultMarker?[0]{
//                if let city = markerData.locality{
//                    completion(city)
//                }
//                else{
//                    print("get city name failed.")
//                    completion(nil)
//                }
//            }
//            else{
//                print("get marker data failed.")
//                completion(nil)
//            }
//        }
//    }
}


