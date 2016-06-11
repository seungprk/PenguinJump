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
    
    let penguinScrollNode = SKNode()
    
    var penguins = [Penguin]()
    var penguinOffset: CGFloat!
    
    override func didMoveToView(view: SKView) {
        
        // Fetch data
        let unlockedPenguins = fetchUnlockedPenguins()
        let gameData = fetchGameData()
        
        let unlockedNormal = Bool(unlockedPenguins.penguinNormal as NSNumber)
        let unlockedParasol = Bool(unlockedPenguins.penguinParasol as NSNumber)
        let totalCoins = Int(gameData.totalCoins)
//        print("unlocks:\nnormal: \(unlockedNormal)\nparasol: \(unlockedParasol)\n\ntotal coins:\(totalCoins)")
        
        // Set up scene UI
        scaleMode = SKSceneScaleMode.AspectFill
        
        backgroundColor = SKColor(red: 0, green: 93/255, blue: 134/255, alpha: 1)
        
        let closeButton = SKLabelNode(text: "X")
        closeButton.name = "closeButton"
        closeButton.fontName = "Helvetica Neue Condensed Black"
        closeButton.fontColor = SKColor.whiteColor()
        closeButton.fontSize = 24
        closeButton.position = CGPoint(x: view.frame.width * 0.95, y: view.frame.height * 0.95)
        
        let coinLabel = SKLabelNode(text: "\(totalCoins)coins")
        coinLabel.name = "coinLabel"
        coinLabel.fontName = "Helvetica Neue Condensed Black"
        coinLabel.fontColor = SKColor.whiteColor()
        coinLabel.fontSize = 18
        coinLabel.horizontalAlignmentMode = .Right
        coinLabel.position = CGPoint(x: view.frame.width * 0.9, y: view.frame.height * 0.95)

        addChild(closeButton)
        addChild(coinLabel)
        addChild(penguinScrollNode)

        // Add penguins to scroll node
        
        
        let penguinNormal = Penguin(type: .normal)
        let penguinParasol = Penguin(type: .parasol)
        let penguinThird = Penguin(type: .normal)
        
        penguins.append(penguinNormal)
        penguins.append(penguinParasol)
        penguins.append(penguinThird)

        penguinOffset = penguinNormal.size.width
        
        penguinScrollNode.position = view.center
        for penguin in 0..<penguins.count {
            penguins[penguin].position.x += CGFloat(penguin) * penguinOffset
            penguinScrollNode.addChild(penguins[penguin])
        }
        
//        penguinParasol.position.x += penguinOffset

        
//        let penguinScrollNode = SKNode()
        
//        penguinScrollNode.addChild(penguinNormal)
//        penguinScrollNode.addChild(penguinParasol)
        
        
        /*
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 100, width: view.frame.width * 2, height: view.frame.height / 2))
        scrollView.backgroundColor = UIColor.whiteColor()
        view.addSubview(scrollView)
        
        let penguinNormal = Penguin(type: .normal)
        let penguinParasol = Penguin(type: .parasol)

        
        let penguinOffset = penguinNormal.size.width
        penguinParasol.position.x += penguinOffset
        
        let penguinScrollNode = SKNode()
        penguinScrollNode.addChild(penguinNormal)
        penguinScrollNode.addChild(penguinParasol)
        
        
        let penguinScrollView = SKView(frame: CGRect(x: 10, y: 10, width: view.frame.width * 2, height: view.frame.height / 3))
        scrollView.addSubview(penguinScrollView)
        
//        penguinScrollView
        */
    }
    
    override func willMoveFromView(view: SKView) {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if touchedNode.name == "closeButton" {
                    let gameScene = GameScene(size: self.size)
                    let transition = SKTransition.pushWithDirection(.Up, duration: 0.5)
                    gameScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(gameScene, transition: transition)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let positionInScene = touch.locationInNode(self)
            let previousPosition = touch.previousLocationInNode(self)
            
            let translation = CGPoint(x: (positionInScene.x - previousPosition.x) * 2, y: (positionInScene.y - previousPosition.y) * 2)
            
            if let lastPenguin = self.penguins.last {
                let lastPenguinPositionInScene = convertPoint(lastPenguin.position, fromNode: penguinScrollNode)
                

                if !(lastPenguinPositionInScene.x < view!.center.x - 0.1) {
                
                    let pan = SKAction.moveBy(CGVector(dx: translation.x, dy: 0), duration: 0.5)
                    pan.timingMode = .EaseOut
                    penguinScrollNode.runAction(pan)
                }
            }
            
            if let firstPenguin = self.penguins.first {
                let firstPenguinPositionInScene = convertPoint(firstPenguin.position, fromNode: penguinScrollNode)
                
                if !(firstPenguinPositionInScene.x > view!.center.x + 0.1) {
                    
                    let pan = SKAction.moveBy(CGVector(dx: translation.x, dy: 0), duration: 0.5)
                    pan.timingMode = .EaseOut
                    penguinScrollNode.runAction(pan)
                }
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    override func update(currentTime: NSTimeInterval) {
        if let firstPenguin = self.penguins.first {
            let firstPenguinPositionInScene = convertPoint(firstPenguin.position, fromNode: penguinScrollNode)
            
            if firstPenguinPositionInScene.x > view!.center.x + 0.1 {
                let leftResist = SKAction.moveTo(CGPoint(x: view!.center.x, y: view!.center.y), duration: 0.2)
                leftResist.timingMode = .EaseOut
                
                penguinScrollNode.runAction(leftResist)
            }
        }
        if let lastPenguin = self.penguins.last {
            let lastPenguinPositionInScene = convertPoint(lastPenguin.position, fromNode: penguinScrollNode)
            
            if lastPenguinPositionInScene.x < view!.center.x - 0.1 {
                let rightResist = SKAction.moveTo(CGPoint(x: view!.center.x - penguinOffset * CGFloat(penguins.count - 1), y: view!.center.y), duration: 0.2)
                rightResist.timingMode = .EaseOut
                
                penguinScrollNode.runAction(rightResist)
            }
        }
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
