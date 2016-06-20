//
//  ItemSelectionScene.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/11/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit
import CoreData

class ItemSelectionScene: SKScene {
    
    // CoreData Objects
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let gameDataFetchRequest = NSFetchRequest(entityName: "GameData")
    let unlockedPenguinsFetchRequest = NSFetchRequest(entityName: "UnlockedPenguins")
    
    // Scrolling selection objects
    var scrollNodes = [SKNode]()
    var selectedNode: SKNode?
    
    var penguinOffset: CGFloat!
    let penguinScrollNode = SKNode()
    var penguinTitle: SKLabelNode!
    var penguinButton: SKLabelNode!
    var penguinObjectsData = [(type: PenguinType, name: String, cost: Int, unlocked: Bool)]()
    
    var coinLabel = SKLabelNode(text: "0 coins")
    var totalCoins: Int?
    
    var previousNode: SKNode?
    var soundEffectsOn: Bool!
    
    var penguinAtlas = SKTextureAtlas(named: "penguin")
    
    override func didMoveToView(view: SKView) {
        scaleMode = SKSceneScaleMode.AspectFill
        backgroundColor = SKColor(red: 0, green: 93/255, blue: 134/255, alpha: 1)
        
        // Fetch data
        let unlockedPenguins = fetchUnlockedPenguins()
        let gameData = fetchGameData()
        
        totalCoins = Int(gameData.totalCoins)
        soundEffectsOn = gameData.soundEffectsOn as Bool
        
        // Set up scene UI
        let closeButton = SKLabelNode(text: "X")
        closeButton.name = "closeButton"
        closeButton.fontName = "Helvetica Neue Condensed Black"
        closeButton.fontColor = SKColor.whiteColor()
        closeButton.fontSize = 24
        closeButton.position = CGPoint(x: view.frame.width * 0.95, y: view.frame.height * 0.95)
        
        coinLabel.text = "\(totalCoins!) coins"
        coinLabel.name = "coinLabel"
        coinLabel.fontName = "Helvetica Neue Condensed Black"
        coinLabel.fontColor = SKColor.whiteColor()
        coinLabel.fontSize = 18
        coinLabel.horizontalAlignmentMode = .Right
        coinLabel.position = CGPoint(x: view.frame.width * 0.9, y: view.frame.height * 0.95)
        
        penguinTitle = SKLabelNode(text: "a")
        penguinTitle.name = "penguinTitle"
        penguinTitle.fontName = "Helvetica Neue Condensed Black"
        penguinTitle.fontColor = SKColor.whiteColor()
        penguinTitle.fontSize = 24
        penguinTitle.horizontalAlignmentMode = .Center
        penguinTitle.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.8)
        
        penguinButton = SKLabelNode(text: "a")
        penguinButton.name = "penguinButton"
        penguinButton.fontName = "Helvetica Neue Condensed Black"
        penguinButton.fontColor = SKColor.whiteColor()
        penguinButton.fontSize = 36
        penguinButton.horizontalAlignmentMode = .Center
        penguinButton.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.25)
        
        addChild(closeButton)
        addChild(coinLabel)
        addChild(penguinScrollNode)
        addChild(penguinTitle)
        addChild(penguinButton)
        
        
        // Create array of scroll node objects
        penguinObjectsData = [
            (type: PenguinType.normal, name: "Penguin", cost: 0, unlocked: true),
            (type: PenguinType.tinfoil, name: "Paranoid Penguin", cost: 10, unlocked: Bool(unlockedPenguins.penguinTinfoil as NSNumber)),
            (type: PenguinType.parasol, name: "Parasol Penguin", cost: 20, unlocked: Bool(unlockedPenguins.penguinParasol as NSNumber)),
            (type: PenguinType.shark, name: "A Penguin in Shark's Clothing", cost: 50, unlocked: Bool(unlockedPenguins.penguinShark as NSNumber)),
            
            (type: PenguinType.penguinViking, name: "Ahhhh Penguin", cost: 300, unlocked: Bool(unlockedPenguins.penguinViking as NSNumber)),
            (type: PenguinType.penguinAngel, name: "Falling Angel", cost: 300, unlocked: Bool(unlockedPenguins.penguinAngel as NSNumber)),
            (type: PenguinType.penguinMarathon, name: "Ironpenguin", cost: 300, unlocked: Bool(unlockedPenguins.penguinMarathon as NSNumber)),
            (type: PenguinType.penguinMohawk, name: "Mohawk Penguin", cost: 300, unlocked: Bool(unlockedPenguins.penguinMohawk as NSNumber)),
            (type: PenguinType.penguinPropellerHat, name: "Propeller Penguin", cost: 300, unlocked: Bool(unlockedPenguins.penguinPropellerHat as NSNumber)),
            (type: PenguinType.penguinSuperman, name: "Super Penguin", cost: 300, unlocked: Bool(unlockedPenguins.penguinSuperman as NSNumber)),
            (type: PenguinType.penguinDuckyTube, name: "Kid Penguin", cost: 1000, unlocked: Bool(unlockedPenguins.penguinDuckyTube as NSNumber)),
            (type: PenguinType.penguinPolarBear, name: "Wannabe Penguin", cost: 1000, unlocked: Bool(unlockedPenguins.penguinPolarBear as NSNumber)),
            (type: PenguinType.penguinTophat, name: "Tux", cost: 1000, unlocked: Bool(unlockedPenguins.penguinTophat as NSNumber)),
            (type: PenguinType.penguinCrown, name: "Royal Penguin", cost: 10000, unlocked: Bool(unlockedPenguins.penguinCrown as NSNumber)),
        ]
        
        // Create array of scroll nodes
        for index in 0..<penguinObjectsData.count {
            let scrollNode = SKNode()
            scrollNode.name = "\(index)"
            
            if penguinObjectsData[index].unlocked {
                let penguin = Penguin(type: penguinObjectsData[index].type)
                penguin.name = "penguin"
                
                scrollNode.addChild(penguin)
            } else {
                let penguin = SKSpriteNode(texture: SKTexture(image: UIImage(named: "locked_penguin")!))
                penguin.size = CGSize(width: 25, height: 44)
                penguin.name = "penguin"
                
                scrollNode.addChild(penguin)
            }

            scrollNodes.append(scrollNode)
        }
        
        // Add scroll nodes to main scrolling node
        penguinOffset = penguinAtlas.textureNamed("penguin-front").size().width * 0.15
        
        penguinScrollNode.position = view.center
        for node in 0..<scrollNodes.count {
            scrollNodes[node].position.x += CGFloat(node) * penguinOffset
            penguinScrollNode.addChild(scrollNodes[node])
        }
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
                if touchedNode.name == "penguinButton" {
                    let label = touchedNode as! SKLabelNode
                    if label.text == "Play" {
                        saveSelectedPenguin()
                        
                        let gameScene = GameScene(size: self.size)
                        let transition = SKTransition.pushWithDirection(.Up, duration: 0.5)
                        gameScene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view?.presentScene(gameScene, transition: transition)
                    } else {
                        tryUnlockingPenguin()
                    }
                    
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let positionInScene = touch.locationInNode(self)
            let previousPosition = touch.previousLocationInNode(self)
            
            let translation = CGPoint(x: (positionInScene.x - previousPosition.x) * 2, y: (positionInScene.y - previousPosition.y) * 2)
            
            
            if let lastNode = scrollNodes.last {
                let lastNodePositionInScene = convertPoint(lastNode.position, fromNode: penguinScrollNode)
                
                if let firstNode = scrollNodes.first {
                    let firstNodePositionInScene = convertPoint(firstNode.position, fromNode: penguinScrollNode)
                    
                    if !(firstNodePositionInScene.x > view!.center.x + 0.1) && !(lastNodePositionInScene.x < view!.center.x - 0.1)  {
                        
                        let pan = SKAction.moveBy(CGVector(dx: translation.x / 2, dy: 0), duration: 0.2)
                        pan.timingMode = .EaseOut
                        penguinScrollNode.runAction(pan)
                    }
                }
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        if let firstNode = scrollNodes.first {
            let firstNodePositionInScene = convertPoint(firstNode.position, fromNode: penguinScrollNode)
            
            if firstNodePositionInScene.x > view!.center.x + 0.1 {
                let leftResist = SKAction.moveTo(CGPoint(x: view!.center.x, y: view!.center.y), duration: 0.1)
                leftResist.timingMode = .EaseOut
                
                penguinScrollNode.runAction(leftResist)
            }
        }
        
        if let lastNode = scrollNodes.last {
            let lastNodePositionInScene = convertPoint(lastNode.position, fromNode: penguinScrollNode)
            
            if lastNodePositionInScene.x < view!.center.x - 0.1 {
                let rightResist = SKAction.moveTo(CGPoint(x: view!.center.x - penguinOffset * CGFloat(scrollNodes.count - 1), y: view!.center.y), duration: 0.1)
                rightResist.timingMode = .EaseOut
                
                penguinScrollNode.runAction(rightResist)
            }
        }
        
        // Calculate which penguin is closest to the middle
        var middleNode: SKNode!
        var closestX = penguinOffset * 10

        for node in scrollNodes {
            let nodePositionInScene = convertPoint(node.position, fromNode: penguinScrollNode)
            let nodeDistanceFromCenter = nodePositionInScene.x - view!.center.x
            if nodeDistanceFromCenter < abs(closestX) {
                closestX = nodeDistanceFromCenter

                middleNode = node
            }
        }
        
        if previousNode != middleNode {
            previousNode = middleNode
            
            if soundEffectsOn! {
                runAction(SKAction.playSoundFileNamed("dial.wav", waitForCompletion: false))
            }
        }
        selectedNode = middleNode
        
        // Scale unselected penguins smaller
        for node in scrollNodes {
            if node != middleNode && node.childNodeWithName("penguin")?.xScale > 2 {
                let normalScale = SKAction.scaleTo(1, duration: 0.2)
                normalScale.timingMode = .EaseOut
                
                let penguin = node.childNodeWithName("penguin")
                penguin?.runAction(normalScale)
                penguin?.position = CGPointZero
                
                node.zPosition = 0
            }
            
            if node != middleNode {
                let penguin = node.childNodeWithName("penguin") as! SKSpriteNode
                penguin.position = CGPointZero
            }
        }
        
        // Scale selected penguin larger
        if middleNode.childNodeWithName("penguin")?.xScale < 1.001 {
            let selectedScale = SKAction.scaleTo(2.5, duration: 0.2)
            selectedScale.timingMode = .EaseOut
            
            let middlePenguin = middleNode.childNodeWithName("penguin")
            middlePenguin?.runAction(selectedScale)
            
            middleNode.zPosition = 30000
        }
        
        middleNode.childNodeWithName("penguin")?.position = convertPoint(view!.center, toNode: middleNode)
        
        if let index = Int(middleNode.name!) {
            if penguinObjectsData[index].unlocked {
                penguinTitle.text = penguinObjectsData[index].name
                penguinButton.text = "Play"
                penguinButton.alpha = 1
            } else {
                penguinTitle.text = "???"
                penguinButton.text = "Unlock with \(penguinObjectsData[index].cost) coins"
                
                if totalCoins >= penguinObjectsData[index].cost {
                    penguinButton.alpha = 1
                } else {
                    penguinButton.alpha = 0.35
                }
            }
        }
        
    }
    
    // MARK: - CoreData methods
    
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
                newPenguinData.penguinTinfoil = NSNumber(bool: false)
                newPenguinData.penguinShark = NSNumber(bool: false)
                
                newPenguinData.penguinViking = NSNumber(bool: false)
                newPenguinData.penguinAngel = NSNumber(bool: false)
                newPenguinData.penguinSuperman = NSNumber(bool: false)
                newPenguinData.penguinPolarBear = NSNumber(bool: false)
                newPenguinData.penguinTophat = NSNumber(bool: false)
                newPenguinData.penguinPropellerHat = NSNumber(bool: false)
                newPenguinData.penguinMohawk = NSNumber(bool: false)
                newPenguinData.penguinCrown = NSNumber(bool: false)
                newPenguinData.penguinMarathon = NSNumber(bool: false)
                newPenguinData.penguinDuckyTube = NSNumber(bool: false)

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
    
    func saveSelectedPenguin() {
        if let index = Int(selectedNode!.name!) {
            var selectedPenguinString = ""

            let type = penguinObjectsData[index].type
            
            switch (type) {
            case .normal:
                selectedPenguinString = "normal"
            case .parasol:
                selectedPenguinString = "parasol"
            case .tinfoil:
                selectedPenguinString = "tinfoil"
            case .shark:
                selectedPenguinString = "shark"
            case .penguinAngel:
                selectedPenguinString = "penguinAngel"
            case .penguinCrown:
                selectedPenguinString = "penguinCrown"
            case .penguinDuckyTube:
                selectedPenguinString = "penguinDuckyTube"
            case .penguinMarathon:
                selectedPenguinString = "penguinMarathon"
            case .penguinMohawk:
                selectedPenguinString = "penguinMohawk"
            case .penguinPolarBear:
                selectedPenguinString = "penguinPolarBear"
            case .penguinPropellerHat:
                selectedPenguinString = "penguinPropellerHat"
            case .penguinSuperman:
                selectedPenguinString = "penguinSuperman"
            case .penguinTophat:
                selectedPenguinString = "penguinTophat"
            case .penguinViking:
                selectedPenguinString = "penguinViking"
            }
            
            let gameData = fetchGameData()
            gameData.selectedPenguin = selectedPenguinString
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func tryUnlockingPenguin() {
        if let index = Int(selectedNode!.name!) {
            let gameData = fetchGameData()
            let cost = penguinObjectsData[index].cost
            
            if cost <= gameData.totalCoins as Int {
                // Save the total coins after the unlock in game data
                let totalCoinsAfterUnlock = (gameData.totalCoins as Int) - cost
                gameData.totalCoins = totalCoinsAfterUnlock
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
                
                // Save the penguin unlock
                let unlockedPenguins = fetchUnlockedPenguins()
                
                // Switch chooses which penguin type to unlock
                let type = penguinObjectsData[index].type
                switch (type) {
                case .normal:
                    unlockedPenguins.penguinNormal = NSNumber(bool: true)
                case .parasol:
                    unlockedPenguins.penguinParasol = NSNumber(bool: true)
                case .tinfoil:
                    unlockedPenguins.penguinTinfoil = NSNumber(bool: true)
                case .shark:
                    unlockedPenguins.penguinShark = NSNumber(bool: true)
                case .penguinAngel:
                    unlockedPenguins.penguinAngel = NSNumber(bool: true)
                case .penguinCrown:
                    unlockedPenguins.penguinCrown = NSNumber(bool: true)
                case .penguinDuckyTube:
                    unlockedPenguins.penguinDuckyTube = NSNumber(bool: true)
                case .penguinMarathon:
                    unlockedPenguins.penguinMarathon = NSNumber(bool: true)
                case .penguinMohawk:
                    unlockedPenguins.penguinMohawk = NSNumber(bool: true)
                case .penguinPolarBear:
                    unlockedPenguins.penguinPolarBear = NSNumber(bool: true)
                case .penguinPropellerHat:
                    unlockedPenguins.penguinPropellerHat = NSNumber(bool: true)
                case .penguinSuperman:
                    unlockedPenguins.penguinSuperman = NSNumber(bool: true)
                case .penguinTophat:
                    unlockedPenguins.penguinTophat = NSNumber(bool: true)
                case .penguinViking:
                    unlockedPenguins.penguinViking = NSNumber(bool: true)
                }
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
                
                // Update scene data
                penguinObjectsData[index].unlocked = true
                totalCoins = totalCoinsAfterUnlock
                
                // Update scene UI .. perhaps have a particle burst behind the character?
                coinLabel.text = "\(totalCoinsAfterUnlock) coins"
                
                scrollNodes[index].childNodeWithName("penguin")?.removeFromParent()
                
                let penguin = Penguin(type: penguinObjectsData[index].type)
                penguin.name = "penguin"
                scrollNodes[index].addChild(penguin)
            } else {
                // Not enough coins to unlock
            }
            
        }
    }
}
