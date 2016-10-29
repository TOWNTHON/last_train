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
    
    @IBAction func myTrainStopSetButton(sender: AnyObject) {
        dispMyTrainStopLabel.text = "設定済み"
    }
    
}
