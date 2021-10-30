//
//  ViewController.swift
//  Weather
//
//  Created by Ashish Ashish on 10/28/21.
//  Edited by Menghui Wang on 10/29/21
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()

    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 141
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCurrentWeather.count // You will replace this with arrCurrentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("WeatherTableViewCell", owner: self, options: nil)?.first as! WeatherTableViewCell
        let currentWeather = arrCurrentWeather[indexPath.row]
        cell.lblCity.text = "\(currentWeather.cityInfoName[0]), \(currentWeather.cityInfoName[1])"
        cell.lblCountry.text = "\(currentWeather.cityInfoName[2])"
        cell.lblTemp.text = "\(currentWeather.temp) ˚F"
        
        
        if !currentWeather.isDayTime {
            cell.imgDayNight.loadGif(name: "night")
            cell.lblTemp.textColor = UIColor.white
            cell.lblCity.textColor = UIColor.white
            cell.lblCountry.textColor = UIColor.white
        }
        cell.imgDayNight.loadGif(name: "day")
        let url = URL(string: currentWeather.weatherIconUrl)
        let data = try? Data(contentsOf: url!)

        if let imageData = data {
            cell.imgWeather.image = UIImage(data: imageData)
        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = arrCurrentWeather[indexPath.row].cityInfoName // replace this with values from arrCurrentWeather array
        return cell
    }
    
    
    func loadCurrentConditions(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Read all the values from realm DB and fill up the arrCityInfo
        
        // for each city info het the city key and make a NW call to current weather condition
        // wait for all the promises to be fulfilled
        // Once all the promises are fulfilled fill the arrCurrentWeather array
        // call for reload of tableView
        
        do{
            let realm = try Realm()
            let cities = realm.objects(CityInfo.self)
            self.arrCurrentWeather.removeAll()
            
            getAllCurrentWeather(Array(cities)).done { currentWeather in
                for weather in currentWeather {
                    self.arrCurrentWeather.append(weather)
                }
                print(self.arrCurrentWeather)
                
                self.tblView.reloadData()
            }
            .catch { error in
               print(error)
            }
       }catch{
           print("Error in reading Database \(error)")
       }
        
        
        
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            
            var promises: [Promise< CurrentWeather>] = []
            
            for i in 0 ..< cities.count {
                promises.append( getCurrentWeather(cities[i]) )
            }
            
            return when(fulfilled: promises)
            
        }
    
    
    func getCurrentWeather(_ city : CityInfo) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = "\(currentConditionURL)\(city.key)?apikey=\(apiKey)"
                print("############")
                print(url)
                
                AF.request(url).responseJSON { response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                  
//                    var cityKey : String = ""
//                    var cityInfoName : String = ""
//                    var weatherText : String = ""
//                    var epochTime : Int = Int.min
//                    var isDayTime : Bool = true
//                    var temp : Int = Int.min
                    let currentWeather = CurrentWeather()
                    let weatherInfo = JSON(response.data!).array?.first
                    currentWeather.cityKey = city.key
                    currentWeather.cityInfoName.append(city.localizedName)
                    currentWeather.cityInfoName.append(city.administrativeID)
                    currentWeather.cityInfoName.append(city.countryLocalizedName)
                    currentWeather.weatherText = weatherInfo!["WeatherText"].stringValue
                    currentWeather.epochTime = weatherInfo!["EpochTime"].intValue
                    currentWeather.isDayTime = weatherInfo!["IsDayTime"].boolValue
                    currentWeather.temp = weatherInfo!["Temperature"]["Imperial"]["Value"].intValue
                    let imageNumber = weatherInfo!["WeatherIcon"].intValue
                    var imageUrl = "https://developer.accuweather.com/sites/default/files/\(imageNumber)-s.png"
                    if imageNumber < 10 {
                        imageUrl = "https://developer.accuweather.com/sites/default/files/0\(imageNumber)-s.png"
                    }
                    currentWeather.weatherIconUrl = imageUrl
                    print(currentWeather)
                    seal.fulfill(currentWeather)
                    
                }
            }
    }

}

