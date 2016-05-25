//
//  GameScene.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/13/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

// Overload minus operator to use on CGPoint
func -(first: CGPoint, second: CGPoint) -> CGPoint {
    let deltaX = first.x - second.x
    let deltaY = first.y - second.y
    return CGPoint(x: deltaX, y: deltaY)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Control options
    let inverseControl = false
    let enableScreenShake = true
    
    var stage: IcebergGenerator?
    let penguin = SKSpriteNode(imageNamed: "penguintemp")
    let targetReticle = SKSpriteNode(imageNamed: "targetcircle")
    let targetDot1 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot2 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot3 = SKSpriteNode(imageNamed: "targetdot")
    var penguinShadow: SKShapeNode?
//    var stage : SKSpriteNode?
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
    
    // Gameplay variables
//    var difficulty = 1.0
    
    override func didMoveToView(view: SKView) {
        createSceneContent()
        
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
        let penguinPositionInScene = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        penguin.position = penguinPositionInScene
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
//        let stageNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: size.width, height: size.height))
        stage = IcebergGenerator(view: view!)
        stage!.position = view!.center //CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(stage!)
        
        stage?.newGame(convertPoint(penguinPositionInScene, toNode: stage!))
        
//        generateBerg()
    }
    
    
    
    func trackScore(translationY: CGFloat) {
        yPosition += -translationY
        if yPosition > score {
            score = yPosition / 10
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        scoreLabel!.text = "Score: " + String(Int(score))
        
        stage?.update()
//        generateBerg()
        
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
//                self.checkPathing()
            }
        })
        
        let velocity = CGVector(dx: xPlatformTravel, dy: yPlatformTravel)
        stage?.scrollTo(velocity, duration: jumpDuration)
        
        trackScore((destination.y - penguin.position.y) * 2)
    }
    
    func onIceberg() -> Bool {
        var onBerg = false
        for berg in stage!.children {
            if penguinShadow!.intersectsNode(berg) {
                let berg = berg as! Iceberg
                onBerg = true
                stage?.updateCurrentBerg(berg)
                berg.bump()
                
            }
        }
        return onBerg
    }
    
    func checkOnIceberg() {
        let check = onIceberg() ? "On an iceberg" : "Not on an iceberg"
        if !onIceberg() {
            gameOver = true
        }
    }
    
//    func checkPathing() {
//        if forking {
//            for berg in stage!.children {
//                if penguinShadow!.intersectsNode(berg) {
//                    pathing = berg.name == "left" ? "left" : "right"
//                }
//            }
//        }
//    }
    
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
}