//
//  LastTrain.swift
//  last train
//
//

import Foundation
import Alamofire
import SwiftyJSON
import Kanna
import CoreLocation

class LastTrain {
    
    static public func getNearTrainStop(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let parameters: [String: Any] = ["latitude":latitude, "longitude":longitude, "output":"json"]
        
        Alamofire.request("http://map.simpleapi.net/stationapi", parameters: parameters) // SimpleAPIから最寄駅を取得
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                
                let json = JSON(object)
                if json[0] != nil {
                    let ud = UserDefaults.standard
                    
                    let nearTrainStopName: String = json[0]["name"].rawString()!
                    
                    ud.set(nearTrainStopName.replacingOccurrences(of: "駅", with: ""), forKey: "nearTrainStopName")
                    ud.set(json[0]["distance"].int, forKey: "nearTrainStopDistance")
                    ud.set(json[0]["traveltime"].string, forKey: "nearTrainStopTraveltime")
                    ud.synchronize()
                }
        }
    }
    
    static public func getLastTrainTime() {
        let ud = UserDefaults.standard
        
        if let nearTrainStopName: String = ud.object(forKey: "nearTrainStopName") as? String {
            let parameters: [String: Any] = ["key":"LE_CSXyYNn9FG4fN", "from":nearTrainStopName, "to":"武蔵中原", "searchType":"lastTrain"]
            
            Alamofire.request("https://api.ekispert.jp/v1/json/search/course/light", parameters: parameters) // 駅すぱーとAPIからURLを取得
                .responseJSON { response in
                    guard let object = response.result.value else {
                        return
                    }
                    
                    let json = JSON(object)
                    json.forEach { (_, json) in
                        Alamofire.request(json["ResourceURI"].string!).responseString{ response in
                            guard let doc = HTML(html: response.data!, encoding: .utf8) else {
                                return
                            }
                            for link in doc.xpath("//*[@id=\"route01\"]/div/table[1]/tr[1]/td[2]/div[1]") {
                                
                                for lastTrainTime in self.getMatchStrings(targetString: link.text!, pattern: "^\n[0-9][0-9]:[0-9][0-9]")  {
                                    print(lastTrainTime)
                                    ud.set(lastTrainTime, forKey: "lastTrainTime")
                                    ud.synchronize()
                                }
                            }
                        }
                        
                    }
                    
            }
            
        }
        
        
    }
    
    // 正規表現にマッチした文字列を格納した配列を返す
    static func getMatchStrings(targetString: String, pattern: String) -> [String] {
        
        var matchStrings:[String] = []
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let targetStringRange = NSRange(location: 0, length: (targetString as NSString).length)
            
            let matches = regex.matches(in: targetString, options: [], range: targetStringRange)
            
            for match in matches {
                
                // rangeAtIndexに0を渡すとマッチ全体が、1以降を渡すと括弧でグループにした部分マッチが返される
                let range = match.rangeAt(0)
                let result = (targetString as NSString).substring(with: range)
                
                matchStrings.append(result)
            }
            
            return matchStrings
            
        } catch {
            print("error: getMatchStrings")
        }
        return []
    }

}
