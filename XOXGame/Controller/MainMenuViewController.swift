//
//  MainMenuViewController.swift
//  XOXGame
//
//  Created by Berk on 12/11/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    var titleHeight: CGFloat = 0
    var titleWidth: CGFloat = 0
    var titleX: CGFloat = 0
    var titleY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initDefaults()
        titleWidth = titleLabel.frame.width
        titleHeight = titleLabel.frame.height
        titleX = titleLabel.frame.origin.x
        titleY = titleLabel.frame.origin.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat], animations: {
            self.titleLabel.transform = self.titleLabel.transform.scaledBy(x: 1.2, y: 1.2)
        }) { (true) in
            self.titleLabel.transform = CGAffineTransform.identity
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDefaults() {
        let defaults = UserDefaults.standard
        let hasInitiated = defaults.bool(forKey: "hasInitiated")
        
        if(!hasInitiated) {
            defaults.set(true, forKey: "hasInitiated")
            defaults.set(true, forKey: "sound")
            defaults.set("Player", forKey: "username")
            defaults.set(0, forKey: "veWin")
            defaults.set(0, forKey: "veLose")
            defaults.set(0, forKey: "veDraw")
            defaults.set(0, forKey: "eWin")
            defaults.set(0, forKey: "eLose")
            defaults.set(0, forKey: "eDraw")
            defaults.set(0, forKey: "nWin")
            defaults.set(0, forKey: "nLose")
            defaults.set(0, forKey: "nDraw")
            defaults.set(0, forKey: "hWin")
            defaults.set(0, forKey: "hLose")
            defaults.set(0, forKey: "hDraw")
            defaults.set(0, forKey: "iWin")
            defaults.set(0, forKey: "iLose")
            defaults.set(0, forKey: "iDraw")
            defaults.set(0, forKey: "mpWin")
            defaults.set(0, forKey: "mpLose")
            defaults.set(0, forKey: "mpDraw")
            defaults.set(3, forKey: "difficulty")
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
