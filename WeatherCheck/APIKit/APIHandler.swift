//
//  APIHandler.swift
//  WeatherCheck
//
//  Created by logan on 28/12/2017.
//  Copyright © 2017 Chuanqi. All rights reserved.
//

import Foundation
import Alamofire

class APIHandler{
    private let openWeatherMapAPIKey = "86367f486270c15891fed058da0c65fe"
    private let openWeatherMapBaseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    
    func getWeatherFromCityName(city: String, completion: @escaping (WeatherData?) -> ()) {
        guard let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)") else{
            completion(nil)
            return
        }
        
        // The data task retrieves the data.
        let dataTask = URLSession.shared.dataTask(with: weatherRequestURL) { (data, response, error) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                print("Error:\n\(error)")
            }
            else {
                //let dataString = String(data: data!, encoding: String.Encoding.utf8)
                guard let datas = data else { return }
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: datas)
                    completion(weatherData)
                }
                catch _{
                    print("error")
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
    
    
}
