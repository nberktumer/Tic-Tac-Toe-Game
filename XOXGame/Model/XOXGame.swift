//
//  XOXGame.swift
//  XOXGame
//
//  Created by Berk on 12/12/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import Foundation

protocol XOXGameDelegate {
    func willStartNextTurn(player: String, yourTurn: Bool)
    func didEnd(isDraw: Bool, positions: [Int], player: String)
    func onNewToken(success: Bool, imageName: String, index: Int)
    func makeBotMove()
    func gameStarted(yourTurn: Bool)
}

extension XOXGameDelegate {
    func makeBotMove() {}
}

class XOXGame: GameDataSourceDelegate {
    var tableMatrix: [[Int]] = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    var players: [String] = []
    var bot: Bot!
    var currentTurn: Int = 1
    var gameType: GameType!
    var gameID: String!
    var difficulty: Int!
    var yourTurn = false
    var botTurn = false
    var waitForOpponentsToken = true
    var receivedToken = false
    
    var delegate : XOXGameDelegate?
    let gameDataSource = GameDataSource()
    
    func getCurrentPlayer() -> String {
        return currentTurn == 1 ? players[0] : players[1]
    }
    
    func getNextPlayer() -> String {
        return currentTurn == 1 ? players[1] : players[0]
    }
    
    func startGame() {
        gameDataSource.delegate = self
        
        delegate?.willStartNextTurn(player: getCurrentPlayer(), yourTurn: self.yourTurn)
        
        if(gameType == GameType.MultiPlayer) {
            gameDataSource.startGame(gameID: gameID)
            
            let defaults = UserDefaults.standard
            let username = defaults.string(forKey: "username")
            if(players.first == username) {
                yourTurn = true
            }
            delegate?.gameStarted(yourTurn: self.yourTurn)
        } else if(gameType == GameType.LocalMultiPlayer){
            yourTurn = true
            delegate?.gameStarted(yourTurn: self.yourTurn)
        } else {
            yourTurn = false
            self.bot = Bot(isFirst: true, game: self, difficulty: self.difficulty)
            self.bot.playTurn()
            delegate?.gameStarted(yourTurn: self.yourTurn)
        }
    }
    
    func putToken(x: Int, y: Int) {
        if(gameType != GameType.MultiPlayer || (gameType == GameType.MultiPlayer && yourTurn)) {
            if(tableMatrix[y][x] == 0) {
                let token = currentTurn > 0 ? "X" : "O"
                tableMatrix[y][x] = currentTurn
                if(gameType == GameType.MultiPlayer) {
                    gameDataSource.putToken(gameID: gameID, table: tableMatrix, onSuccess: {
                        if(!self.hasWon()) {
                            if(!self.isDraw()) {
                                self.currentTurn *= -1
                                self.delegate?.willStartNextTurn(player: self.getCurrentPlayer(), yourTurn: self.yourTurn)
                            }
                        }
                        self.delegate?.onNewToken(success: true, imageName: token, index: self.calculateIndexByPosition(x: x, y: y))
                        self.waitForOpponentsToken = true
                        self.yourTurn = false
                    }, onError: {
                        self.delegate?.onNewToken(success: false, imageName: "", index: 0)
                    })
                } else {
                    currentTurn *= -1
                    
                    self.delegate?.onNewToken(success: true, imageName: token, index: self.calculateIndexByPosition(x: x, y: y))
                    if(gameType != GameType.LocalMultiPlayer) {
                        yourTurn = !self.yourTurn
                    }
                    
                    if(!self.hasWon()) {
                        if(!self.isDraw()) {
                            delegate?.willStartNextTurn(player: getCurrentPlayer(), yourTurn: self.yourTurn)
                            if(!self.yourTurn && gameType == GameType.SinglePlayer) {
                                self.bot.playTurn()
                            }
                        }
                    }
                    
                }
            }
            self.delegate?.onNewToken(success: false, imageName: "", index: 0)
        } else {
            if(receivedToken) {
                let token = currentTurn > 0 ? "X" : "O"
                tableMatrix[y][x] = currentTurn
                
                if(!self.hasWon()) {
                    if(!self.isDraw()) {
                        self.currentTurn *= -1
                        self.delegate?.willStartNextTurn(player: self.getCurrentPlayer(), yourTurn: !self.yourTurn)
                    }
                }
                self.delegate?.onNewToken(success: true, imageName: token, index: self.calculateIndexByPosition(x: x, y: y))
                self.waitForOpponentsToken = false
                self.yourTurn = true
                self.receivedToken = false
            }
        }
    }
    
    func putRandomToken() {
        var availableLocations: [[Int]] = []
        
        for var y in stride(from: 0, to: 3, by: 1) {
            for var x in stride(from: 0, to: 3, by: 1) {
                if(tableMatrix[y][x] == 0) {
                    availableLocations.append([x, y])
                }
            }
        }
        
        let randValue: [Int] = availableLocations[Int(arc4random_uniform(UInt32(availableLocations.count)))]
        self.putToken(x: randValue[0], y: randValue[1])

    }
    
    
    func newTokenAdded(x: [Int], y: Int) {
        if(waitForOpponentsToken) {
            for var xVal in stride(from: 0, to: 3, by: 1) {
                if(self.tableMatrix[y][xVal] != x[xVal]) {
                    self.receivedToken = true
                    self.putToken(x: xVal, y: y)
                    return
                }
            }
        }
    }
    
    func hasWon() -> Bool {
        let m = self.tableMatrix
        var hasWon = false
        var positions: [Int] = []
        
        if(m[0][0] != 0 && m[0][0] == m[0][1] && m[0][0] == m[0][2]) {
            positions = [0, 1, 2]
            hasWon = true
        } else if(m[1][0] != 0 && m[1][0] == m[1][1] && m[1][0] == m[1][2]) {
            positions = [3, 4, 5]
            hasWon = true
        } else if(m[2][0] != 0 && m[2][0] == m[2][1] && m[2][0] == m[2][2]) {
            positions = [6, 7, 8]
            hasWon = true
        } else if(m[0][0] != 0 && m[0][0] == m[1][0] && m[0][0] == m[2][0]) {
            positions = [0, 3, 6]
            hasWon = true
        } else if(m[0][1] != 0 && m[0][1] == m[1][1] && m[0][1] == m[2][1]) {
            positions = [1, 4, 7]
            hasWon = true
        } else if(m[0][2] != 0 && m[0][2] == m[1][2] && m[0][2] == m[2][2]) {
            positions = [2, 5, 8]
            hasWon = true
        } else if(m[0][0] != 0 && m[0][0] == m[1][1] && m[0][0] == m[2][2]) {
            positions = [0, 4, 8]
            hasWon = true
        } else if(m[0][2] != 0 && m[0][2] == m[1][1] && m[0][2] == m[2][0]) {
            positions = [2, 4, 6]
            hasWon = true
        }
        
        if(hasWon) {
            delegate?.didEnd(isDraw: false, positions: positions, player: gameType == GameType.MultiPlayer ? getCurrentPlayer() : getNextPlayer())
        }
        
        return hasWon
    }
    
    func isDraw() -> Bool {
        var didEnd = true
        for var y in stride(from: 0, to: 3, by: 1) {
            for var x in stride(from: 0, to: 3, by: 1) {
                if(tableMatrix[y][x] == 0) {
                    didEnd = false
                }
            }
        }
        
        if(didEnd) {
            delegate?.didEnd(isDraw: true, positions: [], player: "")
        }
        return didEnd
    }
    
    func concede() {
        delegate?.didEnd(isDraw: false, positions: [], player: getNextPlayer())
    }
    
    func calculateIndexByPosition(x: Int, y: Int) -> Int {
        return x + y * 3
    }
}
