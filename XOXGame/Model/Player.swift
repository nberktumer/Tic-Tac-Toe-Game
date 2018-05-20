//
//  Player.swift
//  XOXGame
//
//  Created by Berk on 12/12/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import Foundation

class Player {
    var username: String = ""
    var id: String = ""
    var activeGame: String = ""
    
    
    init(name: String, id: String, activeGame: String) {
        self.username = name
        self.id = id
        self.activeGame = activeGame
    }
    
    init(name: String, id: String) {
        self.username = name
        self.id = id
    }
    
    init() {
        
    }
    
    func initWithDictionary(dictionary: [String: String]) -> Player {
        self.username = dictionary["username"]!
        self.activeGame = dictionary["activeGame"]!
        
        return self
    }
    
    func playerAsDictionary() -> [String: String] {
        return ["username": self.username, "activeGame": self.activeGame]
    }
    
    
}
