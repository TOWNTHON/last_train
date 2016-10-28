//
//  ViewController.swift
//  last train
//
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Kanna

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var dispMyTrainStopLabel: UILabel!
    
    
    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var lm: CLLocationManager!
    // 取得した緯度を保持するインスタンス
    var latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var longitude: CLLocationDegrees!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // フィールドの初期化
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // CLLocationManagerをDelegateに指定
        lm.delegate = self
        
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        lm.requestAlwaysAuthorization()
        // 位置情報の精度を指定．任意，
        // lm.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する．任意．
        // lm.distanceFilter = 1000
        
        // GPSの使用を開始する
        lm.startUpdatingLocation()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func myTrainStopSetButton(sender: AnyObject) {
        dispMyTrainStopLabel.text = "設定済み"
    }
    
    /* 位置情報取得成功時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        // 取得した緯度がnewLocation.coordinate.longitudeに格納されている
        latitude = newLocation!.coordinate.latitude
        // 取得した経度がnewLocation.coordinate.longitudeに格納されている
        longitude = newLocation!.coordinate.longitude
        // TODO
        // 取得した緯度・経度をLogに表示
        NSLog("latiitude: \(latitude) , longitude: \(longitude)")
        
        getNearTrainStop()
        getLastTrainTime()
        
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        lm.stopUpdatingLocation()
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // この例ではLogにErrorと表示するだけ．
        NSLog("Error")
    }

    func getNearTrainStop() {
        
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
    
    func getLastTrainTime() {
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
    func getMatchStrings(targetString: String, pattern: String) -> [String] {
        
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
