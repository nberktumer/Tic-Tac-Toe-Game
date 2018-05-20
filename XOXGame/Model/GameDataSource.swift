//
//  GameDataSource.swift
//  XOXGame
//
//  Created by Berk on 12/11/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol GameDataSourceDelegate {
    func onSuccess()
    func onError(action: ErrorAction, error: String)
    func gameWillLoad(gameID: String, players: [String])
    func newTokenAdded(x: [Int], y: Int)
}

extension GameDataSourceDelegate {
    func onSuccess() {}
    func onError(action: ErrorAction, error: String) {}
    func gameWillLoad(gameID: String, players: [String]) {}
    func newTokenAdded(x: [Int], y: Int) {}
}

enum ErrorAction {
    case None
    case SetUserName
    case GoBack
}

class GameDataSource {
    static let ref = Database.database().reference()
    
    let defaults = UserDefaults.standard
    var delegate: GameDataSourceDelegate?
    
    let maxRetry = 3
    var currentRetry = 0
    
    var queueListener: UInt!
    var gameListener: UInt!
    var currentPlayers: [String] = []
    
    func updateUsername(username: String) {
        GameDataSource.ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()) {
                self.delegate?.onError(action: ErrorAction.None, error: "Username is already in use.")
            } else {
                let uid = self.defaults.string(forKey: "uid")
            
                if(uid == nil || (uid?.isEmpty)!) {
                    let newUID = GameDataSource.ref.child("users").childByAutoId().key
                    let newPlayer = Player.init(name: username, id: newUID)
                    GameDataSource.ref.child("users/\(newUID)").setValue(newPlayer.playerAsDictionary())
                    self.defaults.set(newUID, forKey: "uid")
                    self.defaults.set(username, forKey: "username")
                    self.delegate?.onSuccess()
                } else {
                    GameDataSource.ref.child("users/\(uid!)/username").observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? String
                        if(value == nil) {
                            let newUID = GameDataSource.ref.child("users").childByAutoId().key
                            let newPlayer = Player.init(name: username, id: newUID)
                            GameDataSource.ref.child("users/\(newUID)").setValue(newPlayer.playerAsDictionary())
                            self.defaults.set(newUID, forKey: "uid")
                        } else {
                            GameDataSource.ref.child("users/\(uid!)/username").setValue(username)
                        }
                        self.defaults.set(username, forKey: "username")
                        self.delegate?.onSuccess()
                    }) { (error) in
                        print(error.localizedDescription)
                        self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
                    }
                }
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
    
    
    
    func joinQueue() {
        if(currentRetry >= maxRetry) {
            self.delegate?.onError(action: ErrorAction.GoBack, error: "Couldn't join a game.")
            return
        }
        
        let uid = defaults.string(forKey: "uid")
        let username = defaults.string(forKey: "username")
        
        if(uid == nil || username == nil || (uid?.isEmpty)! || (username?.isEmpty)!) {
            self.delegate?.onError(action: ErrorAction.SetUserName, error: "Please enter a valid username.")
        } else {
            GameDataSource.ref.child("users/\(uid!)").observeSingleEvent(of: .value, with: { (playerSnapshot) in
                let player = Player().initWithDictionary(dictionary: (playerSnapshot.value as? [String: String])!)
                player.id = uid!
                
                /*
                * Check if username is valid or set before
                */
                
                if(player.username.isEmpty) {
                    self.delegate?.onError(action: ErrorAction.SetUserName, error: "Please enter a valid username.")
                } else {

                    /*
                    * Check if a previos game is exist
                    */
                    if(!player.activeGame.isEmpty) {
                        self.leaveQueue(player: player)
                        self.leaveGame(player: player, onComplete: {
                            self.joinQueue()
                        })
                    } else {
                        /*
                        * There is no previous game
                        */
                        GameDataSource.ref.child("queue").observeSingleEvent(of: .value, with: { (queueSnapshot) in
                            let queueLength = queueSnapshot.childrenCount
                            
                            if(queueLength == 0) {
                                let newRoomID = GameDataSource.ref.child("games").childByAutoId().key
                                GameDataSource.ref.child("queue/\(newRoomID)/players").setValue([uid])
                                GameDataSource.ref.child("users/\(uid!)/activeGame").setValue(newRoomID)
                                self.currentRetry = 0
                                
                                self.queueListener = GameDataSource.ref.child("queue/\(newRoomID)/players").observe(DataEventType.childAdded, with: { (queueListenerSnapshot) in
                                    self.currentPlayers.append(queueListenerSnapshot.value as! String)
                                    if(self.currentPlayers.count == 2) {
                                        self.gameWillLoad(gameID: newRoomID, players: self.currentPlayers)
                                        self.createGame(gameID: newRoomID, players: self.currentPlayers)
                                        GameDataSource.ref.removeObserver(withHandle: self.queueListener)
                                    }
                                })
                            } else {
                                let gameID = (queueSnapshot.children.nextObject() as? DataSnapshot)?.key
                                var players = queueSnapshot.childSnapshot(forPath: "\(gameID!)/players").value! as! [String]
                                let numPlayers = players.count
                                
                                if(players.first == uid) {
                                    self.delegate?.onError(action: ErrorAction.None, error: "An error occurred. Retrying (\(self.currentRetry+1))...")
                                    self.currentRetry += 1
                                    self.joinQueue()
                                } else if(numPlayers >= 2) {
                                    self.delegate?.onError(action: ErrorAction.None, error: "Game is full. Retrying (\(self.currentRetry+1))...")
                                    self.currentRetry += 1
                                    self.joinQueue()
                                }  else {
                                    players.append(uid!)
                                    GameDataSource.ref.child("queue/\(gameID!)/players").setValue(players)
                                    GameDataSource.ref.child("users/\(uid!)/activeGame").setValue(gameID)
                                    self.currentRetry = 0
                                    self.gameWillLoad(gameID: gameID!, players: players)
                                    self.createGame(gameID: gameID!, players: players)
                                }
                            }
                        }, withCancel: { (error) in
                            print(error.localizedDescription)
                            self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
                        })
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
                self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
            }
        }
    }
    
    func gameWillLoad(gameID: String, players: [String]) {
        GameDataSource.ref.child("users/\(players[0])").observeSingleEvent(of: .value, with: { (user1Snapshot) in
            let username1 = user1Snapshot.childSnapshot(forPath: "username").value as! String
            GameDataSource.ref.child("users/\(players[1])").observeSingleEvent(of: .value, with: { (user1Snapshot) in
                let username2 = user1Snapshot.childSnapshot(forPath: "username").value as! String
                self.delegate?.gameWillLoad(gameID: gameID, players: [username1, username2])
            }) { (error) in
                self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
            }
        }) { (error1) in
            self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
        }
    }
    
    func leaveGame() {
        let uid = defaults.string(forKey: "uid")!
        
        GameDataSource.ref.child("users/\(uid)").observeSingleEvent(of: .value, with: { (playerSnapshot) in
            let player = Player().initWithDictionary(dictionary: (playerSnapshot.value as? [String: String])!)
            player.id = uid
            self.leaveGame(player: player, onComplete: {})
        }) { (error) in
            print(error.localizedDescription)
            self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
        }
    }
    
    func leaveGame(player: Player, onComplete: @escaping () -> Void) {
        GameDataSource.ref.child("games/\(player.activeGame)/players").observeSingleEvent(of: .value, with: { (playerListSnapshot) in
            if(playerListSnapshot.value is NSNull || playerListSnapshot.childrenCount == 0) {
                GameDataSource.ref.child("games/\(player.activeGame)").removeValue(completionBlock: { (error, ref) in
                    if(error != nil) {
                        print(error?.localizedDescription ?? "An error occurred.")
                        self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
                    }
                })
                GameDataSource.ref.child("users/\(player.id)/activeGame").setValue("")
                onComplete()
                return
            }
            
            GameDataSource.ref.child("users/\(player.id)/activeGame").setValue("")
            
            let players: [Player] = (playerListSnapshot.value as? [Player])!
            
            if(players.count == 1 && players[0].id == player.id) {
                
                GameDataSource.ref.child("games/\(player.activeGame)").removeValue(completionBlock: { (error, ref) in
                    if(error != nil) {
                        print(error?.localizedDescription ?? "An error occurred.")
                        self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
                    }
                })
            } else {
                GameDataSource.ref.child("games/\(player.activeGame)/gameEnded").setValue(true)
            }
            onComplete()
        }, withCancel: { (error) in
            print(error.localizedDescription)
            self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
        })
    }
    
    func leaveQueue() {
        let uid = defaults.string(forKey: "uid")
            if(uid != nil) {
            GameDataSource.ref.child("users/\(uid!)").observeSingleEvent(of: .value, with: { (playerSnapshot) in
                if(playerSnapshot.value != nil) {
                    let player = Player().initWithDictionary(dictionary: (playerSnapshot.value as? [String: String])!)
                    player.id = uid!
                    self.leaveQueue(player: player)
                }
            }) { (error) in
                print(error.localizedDescription)
                self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
            }
        }
    }
    
    func leaveQueue(player: Player) {
        if(queueListener != nil) {
            GameDataSource.ref.removeObserver(withHandle: queueListener)
        }
        self.currentPlayers = []
        GameDataSource.ref.child("queue/\(player.activeGame)/players").observeSingleEvent(of: .value, with: { (playerListSnapshot) in
            if(playerListSnapshot.value is NSNull) {
                return
            }
            
            let players: [String] = (playerListSnapshot.value as? [String])!

            if(players.count > 0) {
                GameDataSource.ref.child("users/\(player.id)/activeGame").setValue("")
                if(players.count == 1) {
                    GameDataSource.ref.child("queue/\(player.activeGame)").removeValue(completionBlock: { (error, ref) in
                        if(error != nil) {
                            print(error?.localizedDescription ?? "An error occurred.")
                            self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
                        }
                    })
                } else {
                    let otherPlayer = players[0] == player.id ? players[1] : players[0]
                    GameDataSource.ref.child("queue/\(player.activeGame)/players").setValue([otherPlayer])
                }
            } else {
                GameDataSource.ref.child("users/\(player.id)/activeGame").setValue("")
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
            self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
        })
    }
    
    func createGame(gameID: String, players: [String]) {
        let table = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
        
        let post = ["table": table,
                    "players": players,
                    "gameEnded": false,
                    "currentTurn": players.first!] as [String : Any]
        
        let childUpdates = ["games/\(gameID)": post]
        GameDataSource.ref.updateChildValues(childUpdates)
        
        GameDataSource.ref.child("queue/\(gameID)").removeValue(completionBlock: { (error, ref) in
            if(error != nil) {
                print(error?.localizedDescription ?? "An error occurred.")
                self.delegate?.onError(action: ErrorAction.None, error: "Please check your internet connection.")
            }
        })
    }
    
    func startGame(gameID: String) {
        self.queueListener = GameDataSource.ref.child("games/\(gameID)/table").observe(DataEventType.childChanged, with: { (gameListenerSnapshot) in
            let x = gameListenerSnapshot.value as! [Int]
            let y = Int(gameListenerSnapshot.key)
            print(x)
            print(y!)
            self.delegate?.newTokenAdded(x: x, y: y!)
        })
    }
    
    func putToken(gameID: String, table: [[Int]], onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        GameDataSource.ref.child("games/\(gameID)/table").setValue(table, withCompletionBlock: { (error, ref) in
            if(error != nil) {
                onError()
            } else {
                onSuccess()
            }
        })
    }
}
