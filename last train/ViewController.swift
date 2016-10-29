//
//  ViewController.swift
//  last train
//
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var dispMyTrainStopLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var MyTrainStopName: UITextField!
    
    @IBOutlet weak var walkingTime: UITextField!
    
    @IBAction func myTrainStopSetButton(sender: AnyObject) {
        let ud = UserDefaults.standard
        ud.set(MyTrainStopName.text, forKey: "myTrainStopName")
        ud.set(walkingTime.text, forKey: "walkingTime")
        ud.synchronize()
         //TODO 駅名がみつからなかったときのアラート
        performSegue(withIdentifier: "screenTransition", sender: self)
    }
    
}
