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
    
    
    static func convertEpochToReadableTime(epoch: Int) -> NSDate{
        let date = NSDate(timeIntervalSince1970: 1415637900)
        return date
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
    
    
    
}


