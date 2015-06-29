//
//  test1.swift
//
//
//  Created by Ramsay on 6/18/15.
//
//

import Foundation
import Alamofire
import CryptoSwift
import SwiftyJSON
import UIKit



class Dopamine{
    //declare vars
    var credentials = [String:String]()
    var rewardFunctions = [String]()
    var feedbackFunctions = [String]()
//    var actionPairings = [[String: [String: [String]]]]()
    var actionPairings = [AnyObject]()
    var actionNames = [String]()
    var buildID:String = ""
    var ClientOSVersion = ""
    
    init()
    {
        println("in dopamine init")
        let os = NSProcessInfo().operatingSystemVersion
        self.ClientOSVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        self.setConfig("53baf51d0e4f8c4e24f3ab9a", apiKey:  "5fd2292ff9ecae71f0571ee998c772ea32a20ab6",  token: "446684351423755353baf51d0e4f8c4e24f3ab9a", versionID: "newVersion")
    }
    
    func setConfig(appID: String, apiKey: String, token: String, versionID: String)
    {
        self.credentials["appID"] = appID;
        self.credentials["apiKey"] = apiKey;
        self.credentials["token"] = token;
        self.credentials["versionID"] = versionID;
    }
    
    func pairReinforcements (actionName: String, rewardFunctions: [String], feedbackFunctions: [String])
    {
        
        //check actions, reward functions, feedback functions, pair.
        var haventSeenAction = true
        var uniqueRewards = [String]()
        var uniqueFeedbacks = [String]()
        
        //check to make sure we're not double-counting this action
        if(find(self.actionNames, actionName) == nil)
        {
            println("have not seen \(actionName) yet")
            self.actionNames.append(actionName)
        }
        else
        {
            println("I've already added \(actionName)")
            haventSeenAction = false
        }
        
        //check to make sure we're not double-counting this feedback function
        for thisFunction in rewardFunctions
        {
            if(find(self.rewardFunctions, thisFunction) == nil)
            {
                println("have not seen \(thisFunction) yet")
                self.rewardFunctions.append(thisFunction)
            }
            else
            {
                println("I've already added \(thisFunction)")
            }
            
            if(find(uniqueRewards, thisFunction) == nil)
            {
                uniqueRewards.append(thisFunction)
            }
        }
        
        //check to make sure we're not double-counting this reward function
        for thisFunction in feedbackFunctions
        {
            if(find(self.feedbackFunctions, thisFunction) == nil)
            {
                println("have not seen \(thisFunction) yet")
                self.feedbackFunctions.append(thisFunction)
            }
            else
            {
                println("I've already added \(thisFunction)")
            }
            
            if(find(uniqueFeedbacks, thisFunction) == nil)
            {
                uniqueFeedbacks.append(thisFunction)
            }
        }
        
        if(haventSeenAction)
        {

            var reinforcers = [[String:AnyObject]]()
            for thisFunction in uniqueRewards
            {
                var newReinforcer = ["functionName": thisFunction, "type":"Reward", "constraint":[], "objective":[]]
                reinforcers.append(newReinforcer)
            }
            
            for thisFunction in uniqueFeedbacks
            {
                var newReinforcer = ["functionName": thisFunction, "type":"Feedback", "constraint":[], "objective":[]]
                reinforcers.append(newReinforcer)
            }

            var newActionPairing = ["actionName":actionName, "reinforcers":reinforcers]
            self.actionPairings.append(newActionPairing)

        }
        else
        {
            println("This is NOT first time that pairReinforcements has been called for \(actionName)")
        }
        
    }
    
    func buildPayload(callType: String, eventName: String, identity: [[String:String]]) -> ()
    {
        //calculate build
        self.buildID = self.actionPairings.description.sha1()!
        println(self.buildID)
        var timeNow = NSDate().timeIntervalSince1970 * 1000
        var appID = self.credentials["appID"]!
        
        var parameters:[String: AnyObject] = [
            "token": self.credentials["token"]!,
            "versionID": self.credentials["versionID"]!,
            "key":self.credentials["apiKey"]!,
            "build": self.buildID,
            "UTC":  timeNow,
            "localTime": timeNow,
            "ClientOS":"Swift",
            "ClientOSVersion": self.ClientOSVersion,
            "ClientAPIVersion":"0.1.0",
            "identity": identity
        ]
        
        if(callType == "init")
        {
            parameters["rewardFunctions"] = self.rewardFunctions
            parameters["feedbackFunctions"] = self.feedbackFunctions
            parameters["actionPairings"] = self.actionPairings
        }
        else if(callType == "reinforce" || callType == "track")
        {
            parameters["eventName"] = eventName
        }
        
        println(parameters)
        
        //send API call
        var request = Alamofire.request(.POST, "https://staging.usedopamine.com/v2/app/\(appID)/\(callType)/", parameters: parameters, encoding: .JSON).responseJSON { (_, _, JSON, _) in
            if(callType == "reinforce")
            {
                self.handleReinforceResponse(JSON!)
            }
            else
            {
                println(JSON)
                
            }
        }
        
        parameters = [String: AnyObject]()
        
        return ()
    }
    
    func initialize()
    {
        buildPayload("init", eventName: "init", identity: [["user":"INIT"]])
    }
    
    func track(eventName: String, identity: [[String:String]])
    {
        buildPayload("track", eventName: eventName, identity: identity)
    }
    
    func reinforce(eventName: String, identity: [[String:String]])
    {
        buildPayload("reinforce", eventName: eventName, identity: identity)
    }
    
    func handleReinforceResponse(jsonResponse: AnyObject) -> ()
    {
        println("in handleResponse")
        println(jsonResponse)
    }
}