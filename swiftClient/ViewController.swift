//
//  ViewController.swift
//  swiftClient
//
//  Created by Ramsay on 6/25/15.
//  Copyright (c) 2015 Dopamine. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    let dopamineObj = Dopamine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func initButton(sender: AnyObject)
    {
        dopamineObj.pairReinforcements("newAction1", rewardFunctions: ["newReinforcement", "otherReinforcement", "newReinforcement"], feedbackFunctions:["feedback0"])
        dopamineObj.pairReinforcements("newAction2", rewardFunctions: ["newReinforcement", "otherReinforcement", "newReinforcement"], feedbackFunctions:["feedback0"])
        
        dopamineObj.initialize()
    }
    

    @IBAction func trackButton(sender: AnyObject) {
        dopamineObj.track("testEvent", identity: [["userID": "1138"]])
    }
    
    
    @IBAction func reinforceButton(sender: AnyObject) {
        dopamineObj.reinforce("newAction1", identity: [["userID": "1138"]])
    }

}

