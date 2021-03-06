//
//  HomeTableTableViewController.swift
//  Twitter
//
//  Created by Shi Tao Luo on 2/26/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeTableTableViewController: UITableViewController {

    
    var tweetArray = [NSDictionary]()
    var numberofTweets: Int!

    let myRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        //refresh when pull down the scrren
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        
    }
    
    
    //call api to load tweet
    @objc func loadTweets() {
        
        numberofTweets = 20
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParam = ["count": numberofTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParam, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            //append tweet to tweet array
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
            
        }, failure: { (Error) in
            print("Could not retreive tweets")
        })
    }
    


    func loadMoreTweets() {
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberofTweets = numberofTweets + 20
        let myParam = ["count": numberofTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParam, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            //append tweet to tweet array
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("Could not retreive tweets")
        })
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    

    @IBAction func onLogout(_ sender: Any) {
    
        //Call twitter api to log out
        TwitterAPICaller.client?.logout()
        
        //goes back to login screen
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as! String))
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data:imageData)
        }
        
        return cell
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

}
