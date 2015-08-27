//
//  dopamine.swift
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

typealias ServiceResponse = (AnyObject?, NSError?) -> Void


class Dopamine: NSObject
{
    //declare properties for singleton Dopamine object
    
    var credentials = [String:String]()
    var rewardFunctions = [String]()
    var feedbackFunctions = [String]()
    var actionPairings = [AnyObject]()
    var actionNames = [String]()
    var buildID:String = ""
    var ClientOSVersion = ""
    
    //instantiate Singleton
    class var sharedInstance:Dopamine {
        struct Singleton {
            static let instance = Dopamine()
        }
        return Singleton.instance
    }
    
    //setConfig: pass in the credentials for your app
    func setConfig(appID: String, apiKey: String, token: String, versionID: String)
    {
        let os = NSProcessInfo().operatingSystemVersion
        self.ClientOSVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        self.credentials["appID"] = appID;
        self.credentials["apiKey"] = apiKey;
        self.credentials["token"] = token;
        self.credentials["versionID"] = versionID;
    }
    
    //pairReinforcements: tell the Dopamine API which actions in your app are being reinforced and how you're going to reinforce them. Run this ONCE for each unique action you want reinforced
    func pairReinforcements (actionName: String, rewardFunctions: [String], feedbackFunctions: [String])
    {
        
        //check actions, reward functions, feedback functions, pair.
        var haventSeenAction = true
        var uniqueRewards = [String]()
        var uniqueFeedbacks = [String]()
        
        //check to make sure we're not double-counting this action
        if(find(self.actionNames, actionName) == nil)
        {
            self.actionNames.append(actionName)
        }
        else
        {
            haventSeenAction = false
        }
        
        //check to make sure we're not double-counting this feedback function
        for thisFunction in rewardFunctions
        {
            if(find(self.rewardFunctions, thisFunction) == nil)
            {
                self.rewardFunctions.append(thisFunction)
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
                self.feedbackFunctions.append(thisFunction)
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
        
    }
    
    func buildPayload(callType: String, eventName: String, identity: [[String:String]]) -> [String: AnyObject]
    {
        //calculate build
        self.buildID = self.actionPairings.description.sha1()!
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
        
        return parameters
    }

    
    func initialize(eventName: String, identity: [[String:String]], onCompletion: ServiceResponse) -> Void
    {
        var parameters = buildPayload("init", eventName: eventName, identity: identity)
        var appID = self.credentials["appID"]!
        Alamofire.request(.POST, "https://api.usedopamine.com/v2/app/\(appID)/init/", parameters: parameters, encoding: .JSON).responseJSON { (_, _, JSON, _) in
            onCompletion(JSON, nil)
        }
    }
    
    func track(eventName: String, identity: [[String:String]], onCompletion: ServiceResponse) -> Void
    {
        var parameters = buildPayload("track", eventName: eventName, identity: identity)
        var appID = self.credentials["appID"]!
        Alamofire.request(.POST, "https://api.usedopamine.com/v2/app/\(appID)/track/", parameters: parameters, encoding: .JSON).responseJSON { (_, _, JSON, _) in
            onCompletion(JSON, nil)
        }
    }
    
    func reinforce(eventName: String, identity: [[String:String]], onCompletion: ServiceResponse) -> Void
    {
        var parameters = buildPayload("reinforce", eventName: eventName, identity: identity)
        var appID = self.credentials["appID"]!
        Alamofire.request(.POST, "https://api.usedopamine.com/v2/app/\(appID)/reinforce/", parameters: parameters, encoding: .JSON).responseJSON { (_, _, JSON, _) in
            onCompletion(JSON, nil)
        }
    }

}
