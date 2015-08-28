//
//  ActionPairings.swift
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
import Dopamine
import XCTest

class ActionPairingsTests : XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func shouldProduceCorrectBuildID() {
        /*
            We will give the test three action pairings to build an ID from:
            
            1:
                name - "Publish Article"
                rewards - ["Other Articles", "Authors Like You"]
                feedback - ["Return To Blog"]
            2:
                name - "Comment on Article"
                rewards - ["Other Articles", "Popular Authors"]
                feedback - ["Thank You For Commenting"]
            3:
                name - "Follow Author"
                rewards - ["Other Authors", "Post Sampling"]
                feedback - ["Thank You For Following"]
        
            This should build the string:
            "Publish ArticleOther ArticlesAuthors Like YouReturn To BlogComment on ArticleOther ArticlesPopular AuthorsThank You For CommentingFollow AuthorOther AuthorsPost SamplingThank You For Following"
        */
        let expectedBID = "Publish ArticleOther ArticlesAuthors Like YouReturn To BlogComment on ArticleOther ArticlesPopular AuthorsThank You For CommentingFollow AuthorOther AuthorsPost SamplingThank You For Following"
        var ap = Dopamine.ActionPairings()
        ap.add(ActionPairing(name: "Publish Article", rewards: ["Other Articles", "Authors Like You"], feedback: ["Return To Blog"]))
        ap.add(ActionPairing(name: "Comment on Article", rewards: ["Other Articles", "Popular Authors"], feedback: ["Thank You For Commenting"]))
        ap.add(ActionPairing(name:"Follow Author", rewards: ["Other Authors", "Post Sampling"], feedback: ["Thank You For Following"]))
        XCTAssertEqual(ap.buildID, expectedBID)
    }
}
