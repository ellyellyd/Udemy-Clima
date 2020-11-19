//
//  WeatherManager.swift
//  Clima
//
//  Created by Эллаиса Даценко on 27.10.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)//for what we need weatherManager parameter?
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL =
    "https://api.openweathermap.org/data/2.5/weather?appid=ced9c88bd8fe54a06cfbea3e8823cac0&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
   
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest (with urlString: String){
        //1. Create a URL
        
        if let url = URL(string: urlString){//URL is optional
            //2. Create a URL Session
            
            let session = URLSession(configuration: .default)
            //3. Give a URL Session Task
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){//needs "self." for uderstanding what method should be call in clouser
                        self.delegate?.didUpdateWeather(self, weather: weather)//what a doing "self"?
                    }
                }
            }
            //4. Start the Task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temperature = decodeData.main.temp
            let name = decodeData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temperature)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
