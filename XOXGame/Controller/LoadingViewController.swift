//
//  LoadingViewController.swift
//  XOXGame
//
//  Created by Berk on 12/11/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, GameDataSourceDelegate, UsernameDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let gameDataSource = GameDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameDataSource.delegate = self
        gameDataSource.joinQueue()
        
        activityIndicator.transform = self.activityIndicator.transform.scaledBy(x: 3, y: 3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        gameDataSource.leaveQueue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onError(action: ErrorAction, error: String) {
        if(action == .SetUserName) {
            let usernameViewController = (
                storyboard?.instantiateViewController(
                    withIdentifier: "SetUsername")
                ) as! UsernameViewController
            
            let params: [String: Any?] = ["type": "Loading"]
            prepare(for: UIStoryboardSegue.init(identifier: "SetUsername", source: usernameViewController, destination: usernameViewController), sender: params)
            
            present(usernameViewController, animated: true, completion: nil)
        }
        print(error)
    }
    
    func gameWillLoad(gameID: String, players: [String]) {
        let gameViewController = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        let params: [String: Any?] = ["gameID": gameID, "players": players]
        prepare(for: UIStoryboardSegue.init(identifier: "GameViewController", source: gameViewController, destination: gameViewController), sender: params)
        self.navigationController?.pushViewController(gameViewController, animated: true)
    }
    
    func onUsernameSet() {
        gameDataSource.joinQueue()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let gameViewController = segue.destination as? GameViewController {
            let params = sender as! [String: Any?]
            gameViewController.gameID = params["gameID"] as! String
            gameViewController.players = params["players"] as! [String]
            gameViewController.gameType = GameType.MultiPlayer
        } else if let usernameViewController = segue.destination as? UsernameViewController {
            usernameViewController.type = "Loading"
            usernameViewController.delegate = self
        }
    }
 

}
