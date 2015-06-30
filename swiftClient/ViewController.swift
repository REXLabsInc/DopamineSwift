//
//  ViewController.swift
//  swiftClient
//
//  Created by Ramsay on 6/25/15.
//  Copyright (c) 2015 Dopamine. All rights reserved.
//

import UIKit


class ViewController: UIViewController{

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //  The Dopamine class is defined in dopamine.swift and instantiates as a Singleton.

        //  Use the setConfig(appID, apiKey, token, versionID) method to set your Dopamine API credentials.

        //      appID: you get this from your Developer Dashboard. It's unique to each app on your Developer Account. Make a new app on your dashboard at http://dev.useDopamine.com.

        //      apiKey: you get this from your Developer Dashboard. You have a "Development Key" and a "Production Key". Your Development Key should only be used when you're in development mode. It tells our system to look for changes in your versionID and how your app is pairing actions to reinforcers. Any time you change these (using the Dopamine.sharedInstance.pairReinforcements() method) and you do so with your Development Key, our system will register the change. Any API calls made in Development mode aren't billed, but they also don't receive optimal reinforcement.
        
        //      token: you get this from your Developer Dashboard. It's a secret that's linked to your billing account. Treat as such!

        //      versionID: you set this here. Must be a string. No special characters. This can be anything you want and helps our system experimentally distinguish between different versions of your app.

        
        
        Dopamine.sharedInstance.setConfig("53baf51d0e4f8c4e24f3ab9a", apiKey:  "5fd2292ff9ecae71f0571ee998c772ea32a20ab6",  token: "446684351423755353baf51d0e4f8c4e24f3ab9a", versionID: "productionVersion1")

        
        //  Use the pairReinforcements method to tell the Dopamine API what actions you want to reinforce and what possible "Reinforcement Functions" you want to call to give users Positive Reinforcement or Neutral Feedback.
        
        //  In this example we tell the API about two actions we want to reinforce with Dopamine: newAction1 and newAction2
        //  We pair newAction1 to a single Reward Function in our app that we'll call "newReinforcement". We also pair it to a single Neutral Feedback Function we call "feedback0". We do similar for an action we call newAction2. 
        
        //  You define these actual functions somewhere else in our app: they're what's going to run when you use the Dopamine .reinforce() method when a user completes an action you want to reinforce them for. the "newReinforcement" Reward Function will contain some code that updates your UX to pleasantly reinforce a user. The "feedback0" Feedback Function will contain some code that neutrally confirms to the user they've completed an action WITHOUT feeling particularly rewarding, per se. As you'll see below: the .reinforce() method parses the response from the Dopamine API and calls the appropriate Reward of Feedback Function.
        
        
        Dopamine.sharedInstance.pairReinforcements("newAction1", rewardFunctions: ["newReinforcement"], feedbackFunctions:["feedback0"])
        Dopamine.sharedInstance.pairReinforcements("newAction2", rewardFunctions: ["newReinforcement", "otherReinforcement"], feedbackFunctions:["feedback0"])
        

        //  The rewardFunctions and feedbackFunctions below are cartoon examples. Some of apps that use Dopamine have made Reward Functions that display encouraging messages to the user. Others have included in-app enhancements that get the user excited. Users respond well to rewards that appeal to their sense of community, their desire for personal gain and accomplishment, and their drive for self-fulfillment. For more information about what makes a great reward and great feedback, check out our blog at http://blog.usedopamine.com. We're also available for design assistance if you want a more personal touch with your implementation
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButton(sender: AnyObject)
    {
        
        //This code calls the .initialize() method of the Dopamine Singleton and sends an "init" call to the Dopamine API.

        //If you're using your Development Key, this "init" call will submit your versionID and current action->reinforcement pairings that you set using the .pairReinforcements() method. In Development Mode the API response will verbosely describe to you the pairing we received so you can confirm it. In Production Mode (when you configure your app with your Production Key) the "init" call does NOT track any new changes to how you're using .pairReinforcement()
        
        //Dont worry about changing these arguments. They're perfect as they are.
        
        Dopamine.sharedInstance.initialize("INIT", identity: [["user": "INIT"]]) { (responseObject:AnyObject?, error:NSError?) in
            var response: AnyObject = responseObject!
            println(response["status"])
        }
    }
    

    @IBAction func trackButton(sender: AnyObject)
    {
        //This code calls the .track() method of the Dopamine Singleton and sends a tracking call to the Dopamine API.
        
        //Use tracking calls to tell us about events or user actions that would help us better understand the consequences of reinforcement on user behavior. There might be actions in your app that would help us better know if users are really changing their behavior, but you're not interested in reinforcing those actions per-se. Use the .track() method for those actions and events.
        
        //Arguments:
        
        //  eventName: The name of the event you want to track. These don't need to be pre-defined, but they do need to be strings with no special characters.
        
        //  identity: This is how we know who's who. Each user should have a unique ID. These can be anything but must follow a key-value setup. In this example we're using the key "userID" and the value "1138". You could use userIDs, emails, hashes of either, FBIDs, you get the gist. Change the key-value content if you want but leave the structure [[]] as is.
        
        Dopamine.sharedInstance.track("testEvent", identity: [["userID": "1138"]]) { (responseObject:AnyObject?, error:NSError?) in
            var response: AnyObject = responseObject!
            println(response["status"])
        }
    }
    
    @IBOutlet weak var apiResponse: UITextField!
    
    @IBAction func reinforceButton(sender: AnyObject)
    {
        //This code calls the .reinforce() method of the Dopamine Singleton and sends a reinforcement call to the Dopamine API.
        

        //Dopamine helps your app determine the best ways and times to reinforce users. This hacks their brains' habit-forming circuitry and leads them to transform the actions you reinforce into long-term habits.
        //You decide how your app will potentially reward users and how it will potentially provide them with neutral feedback. We help you understand when to do each of these unique to each user.
        //When you call the API we determine whether or not a reward or neutral feedback would be the best way to reinforce this particular user. The API response will tell your app which Reinforcement Function to run. Sometimes it will return the name of a Reward Function, sometimes the name of a Feedback Function. Every time it will be optimized to exactly what that particular user needs.
        
        //Arguments:
        
        //  eventName: The name of the event you want to reinforce. It must be from the set of actions you've previously paired to Reward and Feedback Functions using .pairReinforcement(). It makes the API sad if you ask to reinforce an action it doesn't know about :(
        
        //  identity: This is how we know who's who. Each user should have a unique ID. These can be anything but must follow a key-value setup. In this example we're using the key "userID" and the value "1138". You could use userIDs, emails, hashes of either, FBIDs, you get the gist. Change the key-value content if you want but leave the structure [[]] as is.
        
        Dopamine.sharedInstance.reinforce("newAction1", identity: [["userID": "1138"]]) { (responseObject:AnyObject?, error:NSError?) in
            var response: AnyObject = responseObject!
            if(response["status"] === 200)
            {
                //For example's sake I'm just updating the UI directly to change this text in a textbox.
                self.apiResponse.text = response["reinforcementFunction"] as! String
                
                //Here's where you'll take the output from the API and pass it through a switch():
//                switch(response["reinforcementFunction"] as! String)
//                {
//                    case("nameOfARewardFunction"):
//                        executeThatRewardFunction();
//                    case("nameOfAnotherRewardFunction"):
//                        executeAnotherRewardFunction();
//                    case("nameOfAFeedbackFunction"):
//                        executeAFeedbackFunction();
//                }
                
                //you get the idea ;)
                //Each case( ) value should match a name of a Reinforcement Function (both Reward Functions and Feedback Functions) you specified in dopamine.pairReinforcement( ). The content of each case should call the Reinforcement Function you wrote that will deliver the user a delightful reward or neutral feedback!
            }
        }

    }
    
}

