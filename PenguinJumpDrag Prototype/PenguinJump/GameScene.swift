//
//  GameScene.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/13/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // Control options
    let inverseControl = false
    let enableScreenShake = true
    
    let penguin = SKSpriteNode(imageNamed: "penguintemp")
    let targetReticle = SKSpriteNode(imageNamed: "targetcircle")
    let targetDot1 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot2 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot3 = SKSpriteNode(imageNamed: "targetdot")
    var penguinShadow: SKShapeNode?
    var stage : SKSpriteNode?
    var yIncrement : CGFloat?
    var gameOver = false
    var highestIceberg = 0
    var lockMovement = false
    var score: CGFloat = 0.0
    var yPosition: CGFloat = 0.0
    var scoreLabel: SKLabelNode?
    var playerTouched = false
    // Transfer Vars
    var touchBegPos : CGPoint?
    
    // Path forking variables
    var forking = false
    var topmostOfLeft: Iceberg?
    var topmostOfRight: Iceberg?
    var pathing = ""
    
    // Path logic variables
    var forkingCount = 0
    
    
    // Iceberg generation
    var bergSize: CGFloat = 150.0
    var gapDistance: CGFloat = 250.0
    
    // Gameplay variables
    var difficulty = 1.0
    
    override func didMoveToView(view: SKView) {
        let forkButton = SKLabelNode(text: "Fork")
        forkButton.name = "forkButton"
        forkButton.fontName = "Helvetica Neue Condensed Black"
        forkButton.fontSize = 24
        forkButton.fontColor = SKColor.blackColor()
        forkButton.position = CGPoint(x: 30, y: view.frame.height - 90)
        addChild(forkButton)
        
        createSceneContent()
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !lockMovement {
            for touch in touches {
                let positionInScene = touch.locationInNode(self)
                let touchedNodes = self.nodesAtPoint(positionInScene)
                for touchedNode in touchedNodes {
                    if let name = touchedNode.name
                    {
                        if name == "restartButton" {
                            view!.paused = false
                            restart()
                        } else if name == "forkButton" {
                            forking = true
                        }
                        if name == "penguin" {
                            playerTouched = true
                            targetReticle.position = penguin.position
                            targetDot1.position = penguin.position
                            targetDot2.position = penguin.position
                            targetDot3.position = penguin.position
                            addChild(targetReticle)
                            addChild(targetDot1)
                            addChild(targetDot2)
                            addChild(targetDot3)
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !lockMovement {
            for touch: AnyObject in touches {
                let positionInScene = touch.locationInNode(self)
                if positionInScene.y < penguin.position.y {
                    targetReticle.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x), y: penguin.position.y - (positionInScene.y - penguin.position.y) * 2)
                    targetDot1.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x)/2, y: penguin.position.y - ( (positionInScene.y - penguin.position.y) * 2 )/2)
                    targetDot2.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x)/4, y: penguin.position.y - ( (positionInScene.y - penguin.position.y) * 2 )/4)
                    targetDot3.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x) * 3/4, y: penguin.position.y - ( (positionInScene.y - penguin.position.y) * 2 ) * 3/4)
                } else {
                    targetReticle.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x), y: penguin.position.y)
                    targetDot1.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x)/2, y: penguin.position.y)
                    targetDot2.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x)/4, y: penguin.position.y)
                    targetDot3.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x) * 3/4, y: penguin.position.y)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !lockMovement {
            for touch: AnyObject in touches {
                let positionInScene = touch.locationInNode(self)
                if playerTouched == true {
                    lockMovement = true
                    if positionInScene.y < penguin.position.y {
                        for touch: AnyObject in touches {
                            let touchEndPos = touch.locationInNode(self)
                            jump(touchEndPos)
                        }
                    } else {
                        for touch: AnyObject in touches {
                            let touchEndPos = touch.locationInNode(self)
                            jump(CGPoint(x: touchEndPos.x, y: penguin.position.y))
                        }
                    }
                    playerTouched = false
                    lockMovement = false
                    targetReticle.removeFromParent()
                    targetDot1.removeFromParent()
                    targetDot2.removeFromParent()
                    targetDot3.removeFromParent()
                }
            }
        }
    }
    
    func createSceneContent() {
        backgroundColor = SKColor(red: 0/255, green: 151/255, blue: 255/255, alpha: 1.0)
        
        scoreLabel = SKLabelNode(text: "Score: " + String(Int(score)))
        scoreLabel!.fontName = "Avenir"
        scoreLabel!.fontSize = 16
        scoreLabel!.fontColor = SKColor.blackColor()
        scoreLabel!.position = CGPoint(x: view!.frame.width * 0.5, y: view!.frame.height * 0.95)
        scoreLabel!.zPosition = 3000
        addChild(scoreLabel!)
        
        // Set constants based on scene size
        yIncrement = size.height / 5
        
        // Create penguin
        penguin.position = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        penguin.name = "penguin"
        penguin.zPosition = 2100
        addChild(penguin)
        
        // Create penguin's shadow
        penguinShadow = SKShapeNode(rectOfSize: CGSize(width: penguin.frame.width, height: penguin.frame.width), cornerRadius: penguin.frame.width / 2)
        penguinShadow!.fillColor = SKColor.blackColor()
        penguinShadow!.alpha = 0.2
        penguinShadow!.position = CGPoint(x: penguin.position.x, y: penguin.position.y - 10)
        penguinShadow!.zPosition = 2000
        addChild(penguinShadow!)
        
        // Set Aim Sprites
        targetReticle.xScale = 0.3
        targetReticle.yScale = 0.3
        targetReticle.zPosition = 1500
        targetDot1.xScale = 0.3
        targetDot1.yScale = 0.3
        targetDot1.zPosition = 1500
        targetDot2.xScale = 0.3
        targetDot2.yScale = 0.3
        targetDot2.zPosition = 1500
        targetDot3.xScale = 0.3
        targetDot3.yScale = 0.3
        targetDot3.zPosition = 1500
        
        // Create stage
        let stageNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: size.width, height: size.height))
        stage = stageNode
        stage!.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(stage!)
        
        generateBerg()
    }
    
    
    
    func trackScore(translationY: CGFloat) {
        yPosition += -translationY
        if yPosition > score {
            score = yPosition
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        scoreLabel!.text = "Score: " + String(Int(score))
        
        generateBerg()
        
        checkGameOver()
    }
    
    func jump(destination: CGPoint) {
        let jumpHeight = yIncrement! * 0.5
        let jumpDuration = 1.0
        let xPlatformTravel = destination.x - penguin.position.x
        let yPlatformTravel = (destination.y - penguin.position.y) * 2
        
        let jumpAction = SKAction.moveBy(CGVector(dx: 0.0, dy: jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let fallAction = SKAction.moveBy(CGVector(dx: 0.0, dy: -jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let enlargeAction = SKAction.scaleBy(2.0, duration: jumpDuration * 0.5)
        let reduceAction = SKAction.scaleBy(0.5, duration: jumpDuration * 0.5)
        let movePlatformAction = SKAction.moveBy(CGVector(dx: xPlatformTravel, dy: yPlatformTravel), duration: NSTimeInterval(jumpDuration))
        jumpAction.timingMode = SKActionTimingMode.EaseOut
        fallAction.timingMode = SKActionTimingMode.EaseIn
        enlargeAction.timingMode = SKActionTimingMode.EaseOut
        reduceAction.timingMode = SKActionTimingMode.EaseIn
        let jumpSequence = SKAction.sequence([jumpAction, fallAction])
        let enlargeSequence = SKAction.sequence([enlargeAction, reduceAction])
        
        penguin.runAction(enlargeSequence)
        penguinShadow!.runAction(enlargeSequence)
        
        penguin.runAction(jumpSequence, completion: { () -> Void in
            self.shakeScreen()
            
            if !self.onIceberg() {
                self.gameOver = true
            } else {
                self.sinkIceberg()
                self.checkPathing()
            }
        })
        
        for berg in stage!.children{
            berg.runAction(movePlatformAction)
        }
        
        trackScore((destination.y - penguin.position.y) * 2)
    }
    
    func onIceberg() -> Bool {
        var onBerg = false
        for berg in stage!.children {
            if penguinShadow!.intersectsNode(berg) {
                onBerg = true
            }
        }
        return onBerg
    }
    
    func checkOnIceberg() {
        let check = onIceberg() ? "On an iceberg" : "Not on an iceberg"
        print(check)
    }
    
    func checkPathing() {
        if forking {
            for berg in stage!.children {
                if penguinShadow!.intersectsNode(berg) {
                    pathing = berg.name == "left" ? "left" : "right"
                }
            }
        }
    }
    
    func sinkIceberg() {
        for berg in stage!.children {
            if penguinShadow!.intersectsNode(berg) {
                let currentBerg = berg as! Iceberg
                currentBerg.sink(7.0, completion: {
                    currentBerg.removeFromParent()
                    self.checkOnIceberg()
                })
            }
        }
    }
    
    func checkGameOver() {
        if gameOver {
            view?.paused = true
            
            self.backgroundColor = SKColor.redColor()
            
            let restartButton = SKLabelNode(text: "Restart")
            restartButton.name = "restartButton"
            restartButton.userInteractionEnabled = false
            restartButton.fontName = "Avenir"
            restartButton.fontSize = 24
            restartButton.fontColor = SKColor.whiteColor()
            restartButton.position = CGPoint(x: view!.frame.width * 0.5, y: view!.frame.height * 0.5)
            restartButton.zPosition = 3000
            addChild(restartButton)
        }
    }
    
    func restart() {
        penguin.removeAllChildren()
        removeAllChildren()
        removeAllActions()
        
        gameOver = false
        highestIceberg = 0
        lockMovement = false
        score = 0.0
        yPosition = 0.0
        createSceneContent()
    }
    
    func shakeScreen() {
        if enableScreenShake {
            let shakeAnimation = CAKeyframeAnimation(keyPath: "transform")
            let randomIntensityOne = CGFloat(random() % 4 + 1)
            let randomIntensityTwo = CGFloat(random() % 4 + 1)
            shakeAnimation.values = [
                NSValue( CATransform3D:CATransform3DMakeTranslation(-randomIntensityOne, 0, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( randomIntensityOne, 0, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 0, -randomIntensityTwo, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 0, randomIntensityTwo, 0 ) ),
            ]
            shakeAnimation.repeatCount = 1
            shakeAnimation.duration = 10/100
            
            view!.layer.addAnimation(shakeAnimation, forKey: nil)
        }
    }
    
//    func generateBergs() {
//        // Check to see if the topmost iceberg is below the view's frame.
//        var topmostBerg: CGFloat = 0.0
//        for berg in stage!.children {
//            if berg.position.y > topmostBerg {
//                let bergPositionInScene = self.convertPoint(berg.position, fromNode: stage!)
//                topmostBerg = bergPositionInScene.y
//            }
//        }
//        
//        // While the topmost iceberg is below the view's frame, generate an iceberg.
//        while (topmostBerg < view!.frame.height) {
//            
//            let berg = SKShapeNode(rectOfSize: CGSize(width: 150, height: 150), cornerRadius: 5.0)
//            berg.fillColor = SKColor(red: 211/255, green: 237/255, blue: 255/255, alpha: 1.0)
//            berg.lineWidth = 0.0
//            
//            let randomY = CGFloat(random()) % 150 + 110
//            let randomX = CGFloat(random()) % view!.frame.width
//            
//            let previousBerg = stage!.children.last
//            if previousBerg != nil {
//                let previousBergPositionInScene = self.convertPoint(previousBerg!.position, fromNode: stage!)
//                let bergPositionInSceneY = previousBergPositionInScene.y + randomY
//                berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
//                
//                topmostBerg = bergPositionInSceneY
//            } else {
//                // If there are no previous icebergs, generate the initial iceberg under the penguin.
//                berg.position = self.convertPoint(CGPoint(x: penguin.position.x, y: penguin.position.y), toNode: stage!)
//            }
//            
//            let bergShadow = SKShapeNode(rectOfSize: CGSize(width: 150, height: 150), cornerRadius: 5.0)
//            bergShadow.fillColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1)
//            bergShadow.position = CGPoint(x: berg.position.x, y: berg.position.y-10)
//            bergShadow.lineWidth = 0.0
//            stage!.addChild(bergShadow)
//            stage!.addChild(berg)
//        }
//    }
//    func generateBerg() {
//        // Check to see if the topmost iceberg is below the view's frame.
//        var topmostBergY: CGFloat = 0.0
//        for berg in stage!.children {
//            if berg.position.y > topmostBergY{
//                let bergPositionInScene = self.convertPoint(berg.position, fromNode: stage!)
//                topmostBergY = bergPositionInScene.y
//            }
//        }
//        
//        // While the topmost iceberg is below the view's frame, generate an iceberg.
//        while (topmostBergY < view!.frame.height) {
//            if forking {
//                switch (pathing) {
//                case "":
//                    let bergLeft = Iceberg(size: CGSize(width: bergSize, height: bergSize))
//                    let bergRight = Iceberg(size: CGSize(width: bergSize, height: bergSize))
//                    
//                    bergLeft.name = "left"
//                    bergRight.name = "right"
//                    
//                    if let previousBerg = stage?.children.first {
//                        // Get position of previous berg in scene
//                        let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
//                        
//                        //                            var leftX: CGFloat
//                        //                            repeat {
//                        //                                leftX = CGFloat(random()) % (view!.frame.width * 0.4)// + (view!.frame.width * 0.1)
//                        //                            } while (previousBergPositionInScene.x - leftX > view!.frame.width * 0.4)
//                        //
//                        //                            var rightX:CGFloat
//                        //                            repeat {
//                        //                                rightX = CGFloat(random()) % (view!.frame.width * 0.4) + (view!.frame.width * 0.6)
//                        //                            } while (previousBergPositionInScene.x - rightX > view!.frame.width * 0.4)
//                        
//                        // Calculate the x position relative to view frame width.
//                        let leftX = CGFloat(random()) % (view!.frame.width * 0.4)
//                        let rightX = CGFloat(random()) % (view!.frame.width * 0.4) + (view!.frame.width * 0.6)
//                        
//                        // Calculate the y position relative to the previous berg location
//                        let bergPositionInSceneY = previousBergPositionInScene.y + gapDistance // + randomY
//                        
//                        // Set the topmostBergY Position to new yPosition
//                        topmostBergY = bergPositionInSceneY
//                        
//                        // Set Values
//                        bergLeft.position = self.convertPoint(CGPoint(x: leftX, y: bergPositionInSceneY), toNode: stage!)
//                        bergRight.position = self.convertPoint(CGPoint(x: rightX, y: bergPositionInSceneY), toNode: stage!)
//                    }
//                    stage!.insertChild(bergLeft, atIndex: 0)
//                    stage!.insertChild(bergRight, atIndex: 0)
//                    
//                    topmostOfLeft = bergLeft
//                    topmostOfRight = bergRight
//                    
//                    pathing = "undecided"
//                    
//                case "undecided":
//                    let bergLeft = Iceberg(size: CGSize(width: bergSize, height: bergSize))
//                    let bergRight = Iceberg(size: CGSize(width: bergSize, height: bergSize))
//                    
//                    bergLeft.name = "left"
//                    bergRight.name = "right"
//                    
//                    if let previousLeft = topmostOfLeft {
//                        //                            var leftXDifference: CGFloat
//                        //                            repeat {
//                        //                                leftXDifference = CGFloat(random()) % (view!.frame.width * 0.3)// + (view!.frame.width * 0.1)
//                        //                            } while (leftXDifference > view!.frame.width * 0.4)
//                        let previousBergLeftPositionInScene = self.convertPoint(previousLeft.position, fromNode: stage!)
//                        
//                        let leftXDifference = CGFloat(random()) % (view!.frame.width * 0.3)
//                        let leftY = previousBergLeftPositionInScene.y + gapDistance
//                        
//                        bergLeft.position = self.convertPoint(CGPoint(x: previousBergLeftPositionInScene.x - leftXDifference, y: leftY), toNode: stage!)
//                        
//                        if leftY > topmostBergY {
//                            topmostBergY = leftY
//                        }
//                    }
//                    
//                    if let previousRight = topmostOfRight {
//                        //                            var rightX:CGFloat
//                        //                            repeat {
//                        //                                rightX = CGFloat(random()) % (view!.frame.width * 0.4) + (view!.frame.width * 0.6)
//                        //                            } while (previousRight.position.x - rightX > view!.frame.width * 0.4)
//                        let previousBergRightPositionInScene = self.convertPoint(previousRight.position, fromNode: stage!)
//                        
//                        
//                        let rightXDifference = CGFloat(random()) % (view!.frame.width * 0.3)
//                        let rightY = previousBergRightPositionInScene.y + gapDistance
//                        
//                        bergRight.position = self.convertPoint(CGPoint(x: previousBergRightPositionInScene.x + rightXDifference, y: rightY), toNode: stage!)
//                        
//                        if rightY > topmostBergY {
//                            topmostBergY = rightY
//                        }
//                    }
//                    
//                    stage!.insertChild(bergLeft, atIndex: 0)
//                    stage!.insertChild(bergRight, atIndex: 0)
//                    
//                    topmostOfLeft = bergLeft
//                    topmostOfRight = bergRight
//                    
//                case "left":
//                    print("making left berg")
//                    let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
//                    
//                    if let previousBerg = topmostOfLeft {
//                        let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
//                        
//                        var randomX: CGFloat
//                        repeat {
//                            randomX = CGFloat(random()) % (view!.frame.width * 0.8) + (view!.frame.width * 0.1)
//                        } while (previousBergPositionInScene.x - randomX > view!.frame.width * 0.4)
//                        
//                        let bergPositionInSceneY = previousBergPositionInScene.y + gapDistance // + randomY
//                        berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
//                        
//                        topmostBergY = berg.position.y
//                    }
//                    
//                    stage!.insertChild(berg, atIndex: 0)
//                    
//                    topmostOfLeft = berg
//                    
//                    forking = false
//                    pathing = ""
//                    
//                case "right":
//                    let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
//                    
//                    if let previousBerg = topmostOfRight {
//                        let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
//                        
//                        var randomX: CGFloat
//                        repeat {
//                            randomX = CGFloat(random()) % (view!.frame.width * 0.8) + (view!.frame.width * 0.1)
//                        } while (previousBergPositionInScene.x - randomX > view!.frame.width * 0.4)
//                        
//                        let bergPositionInSceneY = previousBergPositionInScene.y + gapDistance // + randomY
//                        berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
//                        
//                        topmostBergY = berg.position.y
//                        
//                    }
//                    
//                    stage!.insertChild(berg, atIndex: 0)
//                    
//                    topmostOfRight = berg
//                    
//                    forking = false
//                    pathing = ""
//                    
//                default:
//                    forking = false
//                    pathing = ""
//                }
//                
//                
//                
//            } else {
//                print("creating berg")
//                topmostOfLeft = nil
//                topmostOfRight = nil
//                
//                let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
//                
//                if let previousBerg = stage!.children.first {
//                    let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
//                    
//                    let randomX = CGFloat(random()) % (view!.frame.width * 0.4) - (view!.frame.width * 0.2)
//                    
//                    let bergPositionInSceneY = previousBergPositionInScene.y + gapDistance // + randomY
//                    
//                    berg.position = self.convertPoint(CGPoint(x: previousBergPositionInScene.x + randomX, y: bergPositionInSceneY), toNode: stage!)
//                    
//                    topmostBergY = berg.position.y
//                    
////                    topmostBergY = bergPositionInSceneY
//                    
//                } else {
//                    // If there are no previous icebergs, generate the initial iceberg under the penguin.
//                    berg.position = self.convertPoint(CGPoint(x: penguin.position.x, y: penguin.position.y), toNode: stage!)
//                }
//                berg.bob()
//                stage!.insertChild(berg, atIndex: 0)
//            }
//
//        }
//    }
    
    func generateBerg() {
        var topmostBergY: CGFloat = 0.0
        for berg in stage!.children {
            if berg.position.y > topmostBergY{
                let bergPositionInScene = self.convertPoint(berg.position, fromNode: stage!)
                topmostBergY = bergPositionInScene.y
            }
        }
        while (topmostBergY < view!.frame.height) {
            
            let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
            
            if let previousBerg = stage!.children.first {
                let previousBergPositionInScene = self.convertPoint(previousBerg.position, fromNode: stage!)
                
                let randomX = CGFloat(random()) % (view!.frame.width * 0.4) - (view!.frame.width * 0.2)
                
                let bergPositionInSceneY = previousBergPositionInScene.y + gapDistance // + randomY
                
                berg.position = self.convertPoint(CGPoint(x: previousBergPositionInScene.x + randomX, y: bergPositionInSceneY), toNode: stage!)
                
                topmostBergY = berg.position.y
                
                print(previousBergPositionInScene.y)
                print(bergPositionInSceneY)
                
                //                    topmostBergY = bergPositionInSceneY
                
            } else {
                // If there are no previous icebergs, generate the initial iceberg under the penguin.
                berg.position = self.convertPoint(CGPoint(x: penguin.position.x, y: penguin.position.y), toNode: stage!)
            }
            berg.bob()
            stage!.insertChild(berg, atIndex: 0)
        }
    }
}