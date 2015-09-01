//
//  DopamineTests.swift
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
import Quick
import Nimble
import Nocilla
import Dopamine

class DopamineSpec : QuickSpec {
    override func spec() {
        beforeSuite{
            LSNocilla.sharedInstance().start()
        }
        
        afterSuite{
            LSNocilla.sharedInstance().stop()
        }
        
        afterEach {
            LSNocilla.sharedInstance().clearStubs()
        }
        
        describe("Dopamine") {
            context("Initialization") {
                it("initializes for the first time") {
                    // TODO: Figure out a better testing Framework
                }
            }
            
            context("Reinforcement") {
                it("should handle callbacks correctly") {
                    let apiKey = "abcdefg1234567"
                    let json = "{\n\"status\": 200,\n\"reinforcementFunction\": \"rf1\"\n}"
                    stubRequest("POST", "https://api.usedopamine.com:443/v2/app/\(apiKey)/reinforce").andReturn(200)
                        .withBody(json)
                    let ap = ActionPairings()
                    ap.add("action1", rewards: ["rf1"], feedback: ["ff1"])
                    let d = Dopamine(appID: "129420913", apiKey: apiKey, token: "130941309481", versionID: "129301", userIdentity: [["id": "1293"]], pairings: ap)
                    var e = ""
                    d.reinforce("action1", callback: {(s,f) in
                        e = f
                    })
                    expect(e).toEventually(equal("rf1"), timeout: 3)
                }
            }
        }
    }
}