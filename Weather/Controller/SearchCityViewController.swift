//
//  SearchCityViewController.swift
//  Weather
//
//  Created by Ashish Ashish on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
   
    let arr = ["Seattle WA, USA", "Seaside CA, USA"]
    
    var arrCityInfo : [CityInfo] = [CityInfo]()

    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        getCitiesFromSearch(searchText)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // You will change this to arrCityInfo.count
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cityInfo = arrCityInfo[indexPath.row]
        cell.textLabel?.text = "\(cityInfo.localizedName) \(cityInfo.administrativeID), \(cityInfo.countryLocalizedName)"
        
        
        return cell
    }
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    func getCitiesFromSearch(_ searchText : String) {
        // Network call from there
        let url = getSearchURL(searchText)
    
        AF.request(url).responseJSON { response in
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            self.arrCityInfo.removeAll()
            guard let cities = JSON( response.data!).array else {
                self.tblView.reloadData()
                return
            }
            for cityJson in cities {
                let cityInfo = CityInfo()
                cityInfo.key = cityJson["Key"].stringValue
                cityInfo.type = cityJson["Type"].stringValue
                cityInfo.localizedName = cityJson["LocalizedName"].stringValue
                cityInfo.countryLocalizedName = cityJson["Country"]["LocalizedName"].stringValue
                cityInfo.administrativeID = cityJson["AdministrativeArea"]["ID"].stringValue

                self.arrCityInfo.append(cityInfo)
            }
            self.tblView.reloadData()
            // You will receive JSON array
            // Parse the JSON array
            // Add values in arrCityInfo
            // Reload table with the values
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        print(arrCityInfo[indexPath.row])
        do{
            let realm = try Realm()
            try realm.write({
                realm.add(arrCityInfo[indexPath.row], update: .modified)
                navigationController?.popViewController(animated: true)
                print(arrCityInfo[indexPath.row])
            })
       }catch{
           print("Error in reading Database \(error)")
       }
    }

}
