//
//  ItemSelectionScene.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/11/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData

class ItemSelectionScene: SKScene, UIScrollViewDelegate {

    // CoreData Objects
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let gameDataFetchRequest = NSFetchRequest(entityName: "GameData")
    let unlockedPenguinsFetchRequest = NSFetchRequest(entityName: "UnlockedPenguins")
    
    override func didMoveToView(view: SKView) {
        let unlockedPenguins = fetchUnlockedPenguins()
        let gameData = fetchGameData()
        
        let normalUnlocked = Bool(unlockedPenguins.penguinNormal as NSNumber)
        let parasolUnlocked = Bool(unlockedPenguins.penguinParasol as NSNumber)
        let totalCoins = Int(gameData.totalCoins)
        print("unlocks:\nnormal: \(normalUnlocked)\nparasol: \(parasolUnlocked)\n\ntotal coins:\(totalCoins)")
        
        scaleMode = SKSceneScaleMode.AspectFill
        
        backgroundColor = SKColor(red: 0, green: 93/255, blue: 134/255, alpha: 1)
        
        let closeButton = SKLabelNode(text: "X")
        closeButton.fontName = "Helvetica Neue Condensed Black"
        closeButton.fontColor = SKColor.whiteColor()
        closeButton.fontSize = 24
        closeButton.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
//        let scrollView = UIScrollView(frame: <#T##CGRect#>)
    }
    
    override func willMoveFromView(view: SKView) {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    func fetchGameData() -> GameData {
        var fetchedData = [GameData]()
        do {
            fetchedData = try managedObjectContext.executeFetchRequest(gameDataFetchRequest) as! [GameData]
            
            if fetchedData.isEmpty {
                let newGameData = NSEntityDescription.insertNewObjectForEntityForName("GameData", inManagedObjectContext: managedObjectContext) as! GameData
                newGameData.highScore = 0
                newGameData.totalCoins = 0
                newGameData.selectedPenguin = "normal"
                
                do {
                    try managedObjectContext.save()
                } catch { print(error) }
                
                do {
                    fetchedData = try managedObjectContext.executeFetchRequest(gameDataFetchRequest) as! [GameData]
                } catch { print(error) }
            }
        } catch {
            print(error)
        }
        return fetchedData.first!
    }
    
    func fetchUnlockedPenguins() -> UnlockedPenguins {
        var fetchedData = [UnlockedPenguins]()
        do {
            fetchedData = try managedObjectContext.executeFetchRequest(unlockedPenguinsFetchRequest) as! [UnlockedPenguins]
            
            if fetchedData.isEmpty {
                // Create initial game data
                let newPenguinData = NSEntityDescription.insertNewObjectForEntityForName("UnlockedPenguins", inManagedObjectContext: managedObjectContext) as! UnlockedPenguins
                newPenguinData.penguinNormal = NSNumber(bool: true)
                newPenguinData.penguinParasol = NSNumber(bool: false)
                
                do {
                    try managedObjectContext.save()
                } catch { print(error) }
                
                do {
                    fetchedData = try managedObjectContext.executeFetchRequest(unlockedPenguinsFetchRequest) as! [UnlockedPenguins]
                } catch { print(error) }
            }
        } catch {
            print(error)
        }
        
        return fetchedData.first!
    }
}
