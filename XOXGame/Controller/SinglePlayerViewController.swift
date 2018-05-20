//
//  SinglePlayerViewController.swift
//  XOXGame
//
//  Created by Berk on 12/11/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import UIKit

class SinglePlayerViewController: UIViewController {

    @IBOutlet weak var difficultySlider: UISlider!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    let defaults = UserDefaults.standard
    var difficulty: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Single-Player"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let difficulty = defaults.integer(forKey: "difficulty")
        difficultySlider.value = Float(difficulty)
        setDifficultyLabel(difficulty: difficulty)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDifficultySliderChanged(_ sender: Any) {
        let value = difficultySlider.value
        var floorValue = Float(Int(value))
        let difference = value - floorValue
        
        if(difference > 0.5) {
            floorValue += 1
        }
        
        difficultySlider.value = floorValue
        
        setDifficultyLabel(difficulty: Int(floorValue))
        defaults.set(Int(floorValue), forKey: "difficulty")
    }
    
    func setDifficultyLabel(difficulty: Int) {
        switch difficulty {
        case 1:
            difficultyLabel.text = "Very Easy"
            self.difficulty = 0
            break
        case 2:
            difficultyLabel.text = "Easy"
            self.difficulty = 1
            break
        case 4:
            difficultyLabel.text = "Hard"
            self.difficulty = 3
            break
        case 5:
            difficultyLabel.text = "Impossible"
            self.difficulty = 4
            break
        default:
            difficultyLabel.text = "Normal"
            self.difficulty = 2
            break
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let gameViewController = segue.destination as? GameViewController {
            gameViewController.difficulty = difficulty
            gameViewController.gameType = GameType.SinglePlayer
            gameViewController.players = ["Bot", "Player 1"]
        }
        
    }
    

}
