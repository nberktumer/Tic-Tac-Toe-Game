//
//  GameViewController.swift
//  XOXGame
//
//  Created by Berk on 12/11/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import UIKit
import AVFoundation

enum GameType {
    case SinglePlayer
    case MultiPlayer
    case LocalMultiPlayer
}

class GameViewController: UIViewController, XOXGameDelegate {

    @IBOutlet weak var OneOneButton: UIButton!
    @IBOutlet weak var TwoOneButton: UIButton!
    @IBOutlet weak var ThreeOneButton: UIButton!
    @IBOutlet weak var OneTwoButton: UIButton!
    @IBOutlet weak var TwoTwoButton: UIButton!
    @IBOutlet weak var ThreeTwoButton: UIButton!
    @IBOutlet weak var OneThreeButton: UIButton!
    @IBOutlet weak var TwoThreeButton: UIButton!
    @IBOutlet weak var ThreeThreeButton: UIButton!
    
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var endGameView: UIView!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var winnerTitleLabel: UILabel!
    @IBOutlet weak var endGameEmojiLabel: UILabel!
    
    var tokenButtons: [UIButton] = []
    
    let Game = XOXGame()
    let defaults = UserDefaults.standard
    let turnTime = 15
    
    var gameID: String!
    var players: [String]!
    var gameType: GameType!
    var timeLeft = 0
    var timer: Timer = Timer()
    var difficulty: Int!
    var yourTurn: Bool!
    
    var player: AVAudioPlayer?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Game.delegate = self
        
        tokenButtons.append(OneOneButton)
        tokenButtons.append(TwoOneButton)
        tokenButtons.append(ThreeOneButton)
        tokenButtons.append(OneTwoButton)
        tokenButtons.append(TwoTwoButton)
        tokenButtons.append(ThreeTwoButton)
        tokenButtons.append(OneThreeButton)
        tokenButtons.append(TwoThreeButton)
        tokenButtons.append(ThreeThreeButton)
        
        Game.players = players
        Game.gameType = gameType
        Game.gameID = gameID
        Game.difficulty = difficulty
        
        player1Label.text = players[0]
        player2Label.text = players[1]
        
        Game.startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func on11ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 0, y: 0)
        }
    }
    @IBAction func on21ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 1, y: 0)
        }
    }
    @IBAction func on31ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 2, y: 0)
        }
    }
    @IBAction func on12ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 0, y: 1)
        }
    }
    @IBAction func on22ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 1, y: 1)
        }
    }
    @IBAction func on32ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 2, y: 1)
        }
    }
    @IBAction func on13ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 0, y: 2)
        }
    }
    @IBAction func on23ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 1, y: 2)
        }
    }
    @IBAction func on33ButtonClick(_ sender: Any) {
        if(yourTurn) {
            Game.putToken(x: 2, y: 2)
        }
    }
    
    func onNewToken(success: Bool, imageName: String, index: Int) {
        if(success) {
            playSound()
            let button = self.tokenButtons[index]
            button.alpha = 0
            button.setImage( UIImage(named: imageName)!, for: .normal)
            button.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 1) {
                button.alpha = 1
            }
        }
    }
    
    func willStartNextTurn(player: String, yourTurn: Bool) {
        timer.invalidate()
        self.yourTurn = yourTurn
        self.timeLeft = turnTime
        self.timeLabel.text = String(self.timeLeft)
        
        if(player == players[0]) {
            player1Label.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            player2Label.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        } else {
            player2Label.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            player1Label.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
            
            if(self.timeLeft <= 0) {
                self.Game.concede()
            } else {
                self.timeLeft -= 1
                self.timeLabel.text = String(self.timeLeft)
            }
        })
    }
    
    func gameStarted(yourTurn: Bool) {
        self.yourTurn = yourTurn
    }
    
    func didEnd(isDraw: Bool, positions: [Int], player: String) {
        self.timer.invalidate()
        yourTurn = false
        
        for pos in positions {
            self.tokenButtons[pos].tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        
        endGameView.isHidden = false
        endGameView.alpha = 0
        if(isDraw) {
            winnerLabel.text = ""
            winnerTitleLabel.text = "Tie!"
            endGameEmojiLabel.text = "😐"
            if(gameType == GameType.MultiPlayer) {
                let num = defaults.integer(forKey: "mpDraw") + 1
                defaults.set(num, forKey: "mpDraw")
            } else if(gameType == GameType.SinglePlayer) {
                switch(difficulty) {
                case 0:
                    let num = defaults.integer(forKey: "veDraw") + 1
                    defaults.set(num, forKey: "veDraw")
                    break
                case 1:
                    let num = defaults.integer(forKey: "eDraw") + 1
                    defaults.set(num, forKey: "eDraw")
                    break
                case 2:
                    let num = defaults.integer(forKey: "nDraw") + 1
                    defaults.set(num, forKey: "nDraw")
                    break
                case 3:
                    let num = defaults.integer(forKey: "hDraw") + 1
                    defaults.set(num, forKey: "hDraw")
                    break
                default:
                    let num = defaults.integer(forKey: "iDraw") + 1
                    defaults.set(num, forKey: "iDraw")
                    break
                }
            }
        } else {
            let username = defaults.string(forKey: "username")
            
            if((gameType == GameType.MultiPlayer && player == username) || (gameType == GameType.SinglePlayer && player == "Player 1")) {
                winnerLabel.text = "You won."
                winnerTitleLabel.text = "Congratulations!"
                endGameEmojiLabel.text = "🏆"
            } else if (gameType == GameType.LocalMultiPlayer) {
                winnerLabel.text = "\(player) won."
                winnerTitleLabel.text = "Congratulations!"
                endGameEmojiLabel.text = "🏆"
            } else {
                winnerLabel.text = "You lost."
                winnerTitleLabel.text = "Sorry Mate!"
                endGameEmojiLabel.text = "😕"
            }
            
            if(gameType == GameType.MultiPlayer) {
                if(player == username) {
                    let num = defaults.integer(forKey: "mpWin") + 1
                    defaults.set(num, forKey: "mpWin")
                } else {
                    let num = defaults.integer(forKey: "mpLose") + 1
                    defaults.set(num, forKey: "mpLose")
                }
            } else if(gameType == GameType.SinglePlayer) {
                switch(difficulty) {
                case 0:
                    if(player != "Bot") {
                        let num = defaults.integer(forKey: "veWin") + 1
                        defaults.set(num, forKey: "veWin")
                    } else {
                        let num = defaults.integer(forKey: "veLose") + 1
                        defaults.set(num, forKey: "veLose")
                    }
                    break
                case 1:
                    if(player != "Bot") {
                        let num = defaults.integer(forKey: "eWin") + 1
                        defaults.set(num, forKey: "eWin")
                    } else {
                        let num = defaults.integer(forKey: "eLose") + 1
                        defaults.set(num, forKey: "eLose")
                    }
                    break
                case 2:
                    if(player != "Bot") {
                        let num = defaults.integer(forKey: "nWin") + 1
                        defaults.set(num, forKey: "nWin")
                    } else {
                        let num = defaults.integer(forKey: "nLose") + 1
                        defaults.set(num, forKey: "nLose")
                    }
                    break
                case 3:
                    if(player != "Bot") {
                        let num = defaults.integer(forKey: "hWin") + 1
                        defaults.set(num, forKey: "hWin")
                    } else {
                        let num = defaults.integer(forKey: "hLose") + 1
                        defaults.set(num, forKey: "hLose")
                    }
                    break
                default:
                    if(player != "Bot") {
                        let num = defaults.integer(forKey: "iWin") + 1
                        defaults.set(num, forKey: "iWin")
                    } else {
                        let num = defaults.integer(forKey: "iLose") + 1
                        defaults.set(num, forKey: "iLose")
                    }
                    break
                }
            }
        }
        
        modalView.layer.cornerRadius = 10
        modalView.alpha = 0
        modalView.transform = self.modalView.transform.translatedBy(x: 0, y: endGameView.frame.height)
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseIn, animations: {
            self.endGameView.alpha = 1
        }) { (true) in
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: [], animations: {
                self.modalView.transform = self.modalView.transform.translatedBy(x: 0, y: -self.endGameView.frame.height)
                self.modalView.alpha = 1
            }, completion: { (true) in
                
            })
        }
    }
    
    @IBAction func onGoMenuClick(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func playSound() {
        let defaults = UserDefaults.standard
        let sound = defaults.bool(forKey: "sound")
        if(sound) {
            let path = Bundle.main.path(forResource: "woosh", ofType:"wav")!
            let url = URL(fileURLWithPath: path)
            
            do {
                let sound = try AVAudioPlayer(contentsOf: url)
                self.player = sound
                sound.prepareToPlay()
                sound.play()
            } catch {
                print("Couldn't load the file.")
            }
        }
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
