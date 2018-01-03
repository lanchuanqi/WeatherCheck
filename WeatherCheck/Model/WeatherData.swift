//
//  WeatherData.swift
//  WeatherCheck
//
//  Created by logan on 28/12/2017.
//  Copyright © 2017 Chuanqi. All rights reserved.
//

import Foundation

struct WeatherData: Decodable{
    var coord: WeatherCoordinate?
    var weather: [Weather]?
    var base: String?
    var main:WeatherMain?
    var visibility: Int
    var wind: WeatherWind?
    var clouds: WeatherClouds?
    var dt: Int?
    var sys: WeatherSys?
    var id: Int?
    var name: String?
    var cod: Int?
    
}

struct WeatherCoordinate: Decodable{
    var lon: Double?
    var lat: Double?
}

struct Weather: Decodable{
    var id: Int?
    var main: String?
    var description: String?
    var icon: String
}

struct WeatherMain: Decodable{
    var temp: Double?
    var pressure: Int?
    var humidity: Int?
    var temp_min: Double?
    var temp_max: Double?
}

struct WeatherWind: Decodable{
    var speed: Double?
    var deg: Double?
}

struct WeatherClouds: Decodable{
    var all: Int?
}

struct WeatherSys: Decodable{
    var type: Int?
    var id: Int?
    var message: Double?
    var country: String?
    var sunrise: Int?
    var sunset: Int?
}
