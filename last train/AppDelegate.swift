//
//  AppDelegate.swift
//  last train
//
//

import UIKit
import Foundation
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var lm: CLLocationManager!
    // 取得した緯度を保持するインスタンス
    var latitude: CLLocationDegrees!
    // 取得した経度を保持するインスタンス
    var longitude: CLLocationDegrees!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // フィールドの初期化
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        lm.requestAlwaysAuthorization()
    
        // CLLocationManagerをDelegateに指定
        lm.delegate = self
        // 位置情報の精度を指定．任意，
        // lm.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する．任意．
        // lm.distanceFilter = 1000

        
        
        // background fetch
        application.setMinimumBackgroundFetchInterval(Double(10)) //TODO 一旦10秒(本当は60 * 30 )
        
        
        lm.stopUpdatingLocation()
        
        
        
        lm.stopUpdatingLocation()
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        
        // 20時以降に起動
        if (hour >= 2) { //TODO 試験起動よう
            
            // GPSの使用を開始する
            lm.startUpdatingLocation()
         
            completionHandler(UIBackgroundFetchResult.newData);
        } else {
            completionHandler(UIBackgroundFetchResult.noData);
        }
        
        
        
        
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        //lm.stopUpdatingLocation()
        // TODO どっかに止める処理を入れる
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    /* 位置情報取得成功時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        // 取得した緯度がnewLocation.coordinate.longitudeに格納されている
        let latitude = newLocation!.coordinate.latitude
        // 取得した経度がnewLocation.coordinate.longitudeに格納されている
        let longitude = newLocation!.coordinate.longitude
        // TODO
        // 取得した緯度・経度をLogに表示
        NSLog("latiitude: \(latitude) , longitude: \(longitude)")
        
        LastTrain.getNearTrainStop(latitude: latitude, longitude: longitude)
        LastTrain.getLastTrainTime()
        
        UIApplication.shared.cancelAllLocalNotifications()
        
        //通知登録前のおまじない
        //これがないとpermissionエラーが発生する
        let settings = UIUserNotificationSettings(types: [.alert, .badge , .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        //通知の設定
        let notification:UILocalNotification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSinceNow: 10) //TODO 取得した終電時間に基づく値を設定
        notification.timeZone = TimeZone.autoupdatingCurrent
        notification.alertBody = "そろそろ魔法が解けそうです"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        //通知登録
        UIApplication.shared.scheduleLocalNotification(notification)
        
        lm.stopUpdatingLocation()
        
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // この例ではLogにErrorと表示するだけ．
        NSLog("Error")
    }
    
}

