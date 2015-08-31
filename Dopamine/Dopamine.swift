//
//  Dopamine.swift
//
//  Copyright (c) 2015 Dopamine Labs
//
//  Released under The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import Alamofire
import CryptoSwift
import SwiftyJSON

/// Generic settings for connecting to Dopamine
typealias Settings = (appID: String, apiKey: String, token: String, versionID: String, pairings: ActionPairings)
/// Reinforcers are rewards or feedback for the end user which are primarily identified by name
typealias Reinforcer = (name: String, type: FunctionType, constraint: [String], objective: [String] )
/// Actions have a 1:n pairing with possible rewards and feedback (Reinforcer)
typealias ActionPairing = (name: String, reinforcers: [Reinforcer])
/// A map of names to action pairings
typealias PairingDictionary = [String:ActionPairing]
/// Convenience type for the request payload
typealias APIPayload = [String:AnyObject]
/// Closure of the form {(statusCode, functionName) -> Void} that is provided a callback on reinforcements
public typealias ReinforcementCallback = ((Int, String) -> Void)

/**
    The API is namespaced by suffixes. This enum defines the appropriate sufixes to be added to the
    end of a URL
*/
enum APIEndpoint : String {
    case Init = "init"
    case Reinforce = "reinforce"
    case Track = "track"
}

/**
    The API can handle reward and feedback functions for each action pairing
*/
enum FunctionType : String {
    case Reward = "Reward"
    case Feedback = "Feedback"
}

/**
    Maintains pairings of action names to the relevant reward and feedback identifies
*/
public class ActionPairings {
    var store = PairingDictionary()
    
    /// All the feedback functions that have been registered so far
    var feedbackFunctions : Set<String> {
        get {
            var r  = Set<String>()
            for (name, pairing) in store {
                let f = pairing.reinforcers.filter({$0.type == FunctionType.Feedback}).map({$0.name})
                r = r.union(f)
            }
            return r
        }
    }
    
    /// All the reward functions that have been registered so far
    var rewardFunctions : Set<String> {
        get {
            var r  = Set<String>()
            for (name, pairing) in store {
                let f = pairing.reinforcers.filter({$0.type == FunctionType.Reward}).map({$0.name})
                r = r.union(f)
            }
            return r
        }
    }
    
    /// All the action pairings registered
    var pairings : Array<[String:AnyObject]> {
        get {
            var r = store.values.array.map({$0})
        }
    }
    
    /// A unique ID for this set of action pairings
    var buildID : String {
        get {
            var bid = ""
            for (name, pairing) in store {
                bid += pairing.name
                bid += reduce(pairing.reinforcers,"",{$0 + $1.name})
            }
            if let s = bid.sha1() {
                return s
            }
            return ""
        }
    }
    
    public init() {}
    
    /**
        Adds an action pairing to be used with this build of Dopamine
    
        :param: name The name of the action (e.g., "User Liked Post")
        :param: rewards A Set of strings identifying the possible rewards that can be given based on this action
        :feedback: feedback A Set of strings identifying the possible feedback that can be given based on this action
    */
    public func add(name : String, rewards: Set<String>, feedback: Set<String>) {
        var reinforcers = [Reinforcer]()
        reinforcers += map(rewards, {Reinforcer($0, type: .Reward, constraint: [], objective: [])})
        reinforcers += map(feedback, {Reinforcer($0, type: .Feedback, constraint: [], objective: [])})
        self.store[name] = ActionPairing(name, reinforcers)
    }
}

/**
    An instance of Dopamine handles most day-to-day usage.
*/
public class Dopamine {
    // Assigned during construction
    let s : Settings
    let identity : [[String:String]]
    let basePayload : APIPayload
    
    // Pre-defined
    let apiBaseURL = "https://api.usedopamine.com:443/v2/app"
    // Version of the current bundle
    let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as! String
    // Pragma marks to define operating system based on http://stackoverflow.com/a/24065534
    #if os(iOS)
        let os = "Swift - iOS"
    #elseif os(OSX)
        let os = "Swift - OSX"
    #else
        let os = "Swift - Unknown"
    #endif
    // A version string for the OS of the form "8.4.2"
    let osVersion : String = { () -> String in
        let nsOS = NSProcessInfo().operatingSystemVersion
        return "\(nsOS.majorVersion).\(nsOS.minorVersion).\(nsOS.patchVersion)"
    }()
    
    /**
    
    */
    init(appID: String, apiKey : String, token : String, versionID : String, userIdentity: [[String:String]], pairings : ActionPairings) {
        s = Settings(appID, apiKey, token, versionID, pairings)
        identity = userIdentity
        basePayload = [
            "key": s.apiKey,
            "token": s.token,
            "versionID" : s.versionID,
            "build" : s.pairings.buildID,
            "ClientOS" : os,
            "ClientVersion": osVersion,
            "ClientAPIVersion": bundleVersion,
            "identity": userIdentity
        ]
    }
    
    /**
        Initializes the system with Dopamine and informs Dopamine about the desired (action -> [reward,feedback]) pairings
    */
    public func initialize() {
        let payload : APIPayload = [
            "feedbackFunctions": s.pairings.feedbackFunctions,
            "rewardFunctions": s.pairings.rewardFunctions,
            "actionPairings": s.pairings.pairings.map({apiPairingFormat($0)})
        ]
        request(.Init, payload: payload)
    }
    
    /**
    */
    public func reinforce(action : String, callback : ReinforcementCallback) {
        let payload : APIPayload = [
            "eventName": action
        ]
        request(.Reinforce, payload: payload, callback: callback)
    }
    
    /**
    */
    public func track(action: String) {
        let payload : APIPayload = [
            "eventName": action
        ]
        request(.Track, payload: payload)
    }
    
    /**
        Handles actually making a request to Dopamine
    */
    func request(endpoint : APIEndpoint, payload : APIPayload, callback : ReinforcementCallback? = nil) {
        let utc = NSDate().timeIntervalSince1970 * 1000.0
        let offset = Double(NSTimeZone.localTimeZone().secondsFromGMT * 1000)
        let local = utc + offset
        let t : APIPayload = [
            "UTC": utc.description,
            "local": local.description
        ]
        let standardizedPayload = basePayload.merge(t)
        let requestPayload = standardizedPayload.merge(payload)
        let url = buildEndpointURL(endpoint)
        Alamofire.request(.POST, url, parameters: requestPayload, encoding: .JSON)
                 .responseJSON { _, netResponse, JSON, _ in
                    if endpoint == .Reinforce {
                        if let r = netResponse, j: AnyObject = JSON, functionName = j["reinforcementFunction"] as? String, c = callback {
                            c(r.statusCode, functionName)
                        }
                    }
                 }
    }
    
    /**
        Builds the appropriate endpoint URL
        
        :param: endpoint The appropriate APIEndpoint to build a URL for
    */
    func buildEndpointURL(endpoint : APIEndpoint) -> String {
        return join("/", [apiBaseURL, s.apiKey, endpoint.rawValue])
    }
    
}

func apiPairingFormat (a : ActionPairing) -> [String:AnyObject] {
    return [
        "actionName": a.name,
        "reinforcers": a.reinforcers.map({apiReinforcerFormat($0)})
    ]
}

func apiReinforcerFormat (r : Reinforcer) -> [String:AnyObject] {
    return [
        "functionName" : r.name,
        "type" : r.type.rawValue,
        "constraint": r.constraint,
        "objective": r.objective
    ]
}

extension Dictionary {
    /**
        A destructive merging function that gives preference to values in the foreign dictionary for identival keys
        
        :param: foreign The foreign dictionary to be merged in
        :returns: A new dictionary representing the merger of the foreign dictionary with self
    */
    func merge(foreign : Dictionary) -> Dictionary {
        var r = Dictionary()
        for d in [self, foreign] {
            for (k, v) in d {
                r[k] = v
            }
        }
        return r
    }
}