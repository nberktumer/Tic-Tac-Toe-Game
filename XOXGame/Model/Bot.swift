//
//  Bot.swift
//  XOXGame
//
//  Created by Berk on 12/12/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import Foundation

class Bot {
    let isFirst: Bool
    let difficulty: Int
    let game: XOXGame
    
    var moveCount = 0
    var randProb = 0
    var firstMovePosition = [-1, -1]
    var hasSibling = false
    
    init(isFirst: Bool, game: XOXGame, difficulty: Int) {
        self.isFirst = isFirst
        self.game = game
        self.difficulty = difficulty
        
        switch difficulty {
        case 0:
            randProb = 80
            break
        case 1:
            randProb = 40
            break
        case 2:
            randProb = 20
            break
        case 3:
            randProb = 0
            break
        default:
            randProb = 0
            break
        }
    }
    
    func playTurn() {
        if(randProb >= Int(arc4random_uniform(100) + 1)) {
            game.putRandomToken()
            print("random")
        } else {
            print("not random")
            var table = game.tableMatrix
            
            for var y in stride(from: 0, to: 3, by: 1) {
                for var x in stride(from: 0, to: 3, by: 1) {
                    if(table[y][x] == 0) {
                        let temp = table[y][x]
                        table[y][x] = (isFirst ? 1 : -1)
                        if(willWin(m: table)) {
                            game.putToken(x: x, y: y)
                            return
                        } else {
                            table[y][x] = temp
                        }
                    }
                }
            }
            
            for var y in stride(from: 0, to: 3, by: 1) {
                for var x in stride(from: 0, to: 3, by: 1) {
                    if(table[y][x] == 0) {
                        let temp = table[y][x]
                        table[y][x] = (isFirst ? -1 : 1)
                        if(willWin(m: table)) {
                            game.putToken(x: x, y: y)
                            return
                        } else {
                            table[y][x] = temp
                        }
                    }
                }
            }
            if(difficulty == 4) {
                smartMove()
            } else {
                game.putRandomToken()
            }
        }
        moveCount += 1
    }
    
    func smartMove() {       
        if(isFirst) {
            firstStartedBot()
        } else {
            secondStartedBot()
        }
    }
    
    func willWin(m: [[Int]]) -> Bool {
        var willWin = false
        
        if(m[0][0] != 0 && m[0][0] == m[0][1] && m[0][0] == m[0][2]) {
            willWin = true
        } else if(m[1][0] != 0 && m[1][0] == m[1][1] && m[1][0] == m[1][2]) {
            willWin = true
        } else if(m[2][0] != 0 && m[2][0] == m[2][1] && m[2][0] == m[2][2]) {
            willWin = true
        } else if(m[0][0] != 0 && m[0][0] == m[1][0] && m[0][0] == m[2][0]) {
            willWin = true
        } else if(m[0][1] != 0 && m[0][1] == m[1][1] && m[0][1] == m[2][1]) {
            willWin = true
        } else if(m[0][2] != 0 && m[0][2] == m[1][2] && m[0][2] == m[2][2]) {
            willWin = true
        } else if(m[0][0] != 0 && m[0][0] == m[1][1] && m[0][0] == m[2][2]) {
            willWin = true
        } else if(m[0][2] != 0 && m[0][2] == m[1][1] && m[0][2] == m[2][0]) {
            willWin = true
        }
        
        return willWin
    }
    
    func calculateCornerPosition(index: Int) -> (x: Int, y: Int) {
        switch index {
        case 0:
            return (x: 0, y: 0)
        case 1:
            return (x: 2, y: 0)
        case 2:
            return (x: 0, y: 2)
        default:
            return (x: 2, y: 2)
        }
    }
    
    func calculateOppositeCorner(x: Int, y: Int) -> (x: Int, y: Int) {
        var resultX = 2
        var resultY = 2
        
        if(x == 2) {
            resultX = 0
        }
        if(y == 2) {
            resultY = 0
        }
        
        return (x: resultX, y: resultY)
    }
    
    func isEdge(x: Int, y: Int) -> Bool {
        return ((x == 1 && y == 0) || (x == 1 && y == 2) || (x == 0 && y == 1) || (x == 2 && y == 1))
    }
    
    func isSibling(x1: Int, y1: Int, x2: Int, y2: Int) -> Bool {
        if(y1 == y2) {
            if(x1 + 1 == x2 || x1 - 1 == x2) {
                return true
            }
        } else if(x1 == x2) {
            if(y1 + 1 == y2 || y1 - 1 == y2) {
                return true
            }
        }
        return false
    }
    
    func getOtherSibling() -> (x: Int, y: Int) {
        let table = game.tableMatrix
        let x = firstMovePosition[0]
        let y = firstMovePosition[1]
        
        let negatePosition = [1 - x, 1 - y]
        
        if(table[y][x + negatePosition[0]] == 0) {
            return (x: x + negatePosition[0], y: y)
        } else {
            return (x: x, y: y + negatePosition[1])
        }
    }
    
    func firstStartedBot() {
        let table = game.tableMatrix
        
        if(moveCount == 0) {
            var cornerX = Int(arc4random_uniform(2))
            var cornerY = Int(arc4random_uniform(2))
            
            if(cornerX == 1) {
                cornerX = 2
            }
            if(cornerY == 1) {
                cornerY = 2
            }
            
            firstMovePosition = [cornerX, cornerY]
            
            game.putToken(x: cornerX, y: cornerY)
        } else if(moveCount == 1) {
            var opponentX = 0
            var opponentY = 0
            
            for var y in stride(from: 0, to: 3, by: 1) {
                for var x in stride(from: 0, to: 3, by: 1) {
                    if(table[y][x] == (isFirst ? -1 : 1)) {
                        opponentX = x
                        opponentY = y
                        break
                    }
                }
            }
            
            let oppositeCorner = calculateOppositeCorner(x: firstMovePosition[0], y: firstMovePosition[1])
            var freeCorner = [-1, -1]
            
            if(isEdge(x: opponentX, y: opponentY)) {
                if(isSibling(x1: firstMovePosition[0], y1: firstMovePosition[1], x2: opponentX, y2: opponentY)) {
                    hasSibling = true
                }
                game.putToken(x: 1, y: 1)
            } else {
                if(oppositeCorner.x == opponentX && oppositeCorner.y == opponentY) {
                    if(firstMovePosition[0] == firstMovePosition[1]) {
                        if(arc4random_uniform(2) % 2 == 0) {
                            freeCorner = [0, 2]
                        } else {
                            freeCorner = [2, 0]
                        }
                    } else {
                        if(arc4random_uniform(2) % 2 == 0) {
                            freeCorner = [0, 0]
                        } else {
                            freeCorner = [2, 2]
                        }
                    }
                    game.putToken(x: freeCorner[0], y: freeCorner[1])
                } else {
                    game.putToken(x: oppositeCorner.x, y: oppositeCorner.y)
                }
            }
        } else if(moveCount == 2) {
            if(hasSibling) {
                let otherSibling = getOtherSibling()
                game.putToken(x: otherSibling.x, y: otherSibling.y)
            } else {
                var lastFreeCorner = [-1, -1]
                
                if(table[0][0] == 0) {
                    lastFreeCorner = [0, 0]
                } else if(table[0][2] == 0) {
                    lastFreeCorner = [2, 0]
                } else if(table[2][0] == 0) {
                    lastFreeCorner = [0, 2]
                } else {
                    lastFreeCorner = [2, 2]
                }
                
                game.putToken(x: lastFreeCorner[0], y: lastFreeCorner[1])
            }
        }
    }
    
    func secondStartedBot() {
        game.putRandomToken()
    }
    
}
