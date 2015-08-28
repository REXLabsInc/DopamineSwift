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

public typealias Settings = (appID: String, apiKey: String, token: String, versionID: String, pairings: ActionPairings)

/**
    :param: name The name of the action the user takes that should be rewarded
    :param: rewards The possible rewards a user could be presented with
    :param: feedback Neutral feedback to present when the user isn't being rewarded
*/
public typealias ActionPairing = (name: String, rewards: Set<String>, feedback: Set<String>)

typealias PairingDictionary = [String:ActionPairing]

/// A non-canonical dictionary of ActionPairing objects
public class ActionPairings {
    var store = PairingDictionary()
    public var buildID : String {
        get {
            var bid = ""
            for (name, pairing) in store {
                bid += pairing.name
                bid += reduce(pairing.rewards,"",+)
                bid += reduce(pairing.feedback,"",+)
            }
            return bid
        }
    }
    
    public init() {}
    
    /**
        Adds an action pairing to be used with this build of Dopamine
    
        :param: pairing The pairing of actions to be added
    */
    public func add(pairing : ActionPairing) {
        self.store[pairing.name] = pairing
    }
}

class Dopamine {
    let s : Settings
    
    init(settings : Settings) {
        self.s = settings
    }
}