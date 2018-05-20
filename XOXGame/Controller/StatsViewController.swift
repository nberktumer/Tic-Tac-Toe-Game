//
//  StatsViewController.swift
//  XOXGame
//
//  Created by Berk on 12/11/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDataSource {

    var stats: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Stats"
        
        let defaults = UserDefaults.standard
        stats.append(defaults.integer(forKey: "veWin"))
        stats.append(defaults.integer(forKey: "veLose"))
        stats.append(defaults.integer(forKey: "veDraw"))
        stats.append(defaults.integer(forKey: "eWin"))
        stats.append(defaults.integer(forKey: "eLose"))
        stats.append(defaults.integer(forKey: "eDraw"))
        stats.append(defaults.integer(forKey: "nWin"))
        stats.append(defaults.integer(forKey: "nLose"))
        stats.append(defaults.integer(forKey: "nDraw"))
        stats.append(defaults.integer(forKey: "hWin"))
        stats.append(defaults.integer(forKey: "hLose"))
        stats.append(defaults.integer(forKey: "hDraw"))
        stats.append(defaults.integer(forKey: "iWin"))
        stats.append(defaults.integer(forKey: "iLose"))
        stats.append(defaults.integer(forKey: "iDraw"))
        stats.append(defaults.integer(forKey: "mpWin"))
        stats.append(defaults.integer(forKey: "mpLose"))
        stats.append(defaults.integer(forKey: "mpDraw"))
        
        print(stats)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return "Singleplayer (Very Easy)"
        } else if(section == 1) {
            return "Singleplayer (Easy)"
        } else if(section == 2) {
            return "Singleplayer (Normal)"
        } else if(section == 3) {
            return "Singleplayer (Hard)"
        } else if(section == 4) {
            return "Singleplayer (Impossible)"
        } else {
            return "Multiplayer"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as! StatsTableViewCell
        
        let stat = self.stats[indexPath.section * 3 + indexPath.row]
        var title = ""
        
        if(indexPath.row % 3 == 0) {
            title = "Win:"
        } else if (indexPath.row % 3 == 1) {
            title = "Lose:"
        } else {
            title = "Tie:"
        }
        
        reusableCell.titleLabel.text = "\(title)"
        reusableCell.numberLabel.text = "\(stat)"
        
        return reusableCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
