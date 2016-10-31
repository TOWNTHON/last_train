//
//  WebViewController.swift
//  last train
//
//  Created by 古川　愛 on 2016/10/30.
//  Copyright © 2016年 tiger. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = URL(string: "http://roote.ekispert.net/sp/result?dep=%E9%8A%80%E5%BA%A7&dep_code=22641&arr=%E8%A5%BF%E5%A4%A7%E5%B3%B6&arr_code=22866&via1=&via1_code=&via2=&via2_code=&yyyymm=201610&day=30&hour=23&minute10=4&minute1=5&type=arr&sort=time&transfer=2&ticket_type=0&surcharge=3&shinkansen=true&local=true&highway=true&plane=true&connect=true&liner=true&ship=true&submit_btn=")
        let app:UIApplication = UIApplication.shared
        app.open(url!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
