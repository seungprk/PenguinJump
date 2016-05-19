//
//  GameScene.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/13/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let inverseControl = false
    let enableScreenShake = false
    
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
    
    override func didMoveToView(view: SKView) {
        createSceneContent()
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !lockMovement {
            for touch in touches {
                let positionInScene = touch.locationInNode(self)
                let touchedNodes = self.nodesAtPoint(positionInScene)
                print(touchedNodes)
                for touchedNode in touchedNodes {
                    if let name = touchedNode.name
                    {
                        if name == "restartButton" {
                            view!.paused = false
                            restart()
                        }
                        if name == "penguin" {
                            lockMovement = false
                            playerTouched = true
                            targetReticle.position = positionInScene
                            targetDot1.position = positionInScene
                            targetDot2.position = positionInScene
                            targetDot3.position = positionInScene
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

                targetReticle.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x), y: penguin.position.x - (positionInScene.y - penguin.position.y) * 2)
                targetDot1.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x)/2, y: penguin.position.x - ( (positionInScene.y - penguin.position.y) * 2 )/2)
                targetDot2.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x)/4, y: penguin.position.x - ( (positionInScene.y - penguin.position.y) * 2 )/4)
                targetDot3.position = CGPoint(x: penguin.position.x - (positionInScene.x - penguin.position.x) * 3/4, y: penguin.position.x - ( (positionInScene.y - penguin.position.y) * 2 ) * 3/4)
                
//                let moveAction = SKAction.moveBy(CGVector(dx: destination.x - penguin.position.x, dy: (destination.y - penguin.position.y) * 2), duration: NSTimeInterval(jumpDuration * 0.5))
//
//                if inverseControl {
//                    let translation = CGPoint(x: -(positionInScene.x - previousPosition.x) * 2, y: -(positionInScene.y - previousPosition.y) * 2)
//                    
//                    trackScore(translation.y)
//                    
//                    for berg in stage!.children {
//                        berg.position = CGPoint(x: berg.position.x + translation.x, y: berg.position.y + translation.y)
//                    }
//                } else {
//                    let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
//                    
//                    trackScore(translation.y)
//                    
//                    for berg in stage!.children {
//                        berg.position = CGPoint(x: berg.position.x + translation.x, y: berg.position.y + translation.y)
//                    }
//                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if playerTouched == true {
            lockMovement = true
            for touch: AnyObject in touches {
                let touchEndPos = touch.locationInNode(self)
                jump(touchEndPos)
            }
            playerTouched = false
            lockMovement = false
            targetReticle.removeFromParent()
            targetDot1.removeFromParent()
            targetDot2.removeFromParent()
            targetDot3.removeFromParent()
        }
    }
    
    func createSceneContent() {
        backgroundColor = SKColor.whiteColor()
        
        scoreLabel = SKLabelNode(text: "Score: " + String(Int(score)) + "   Distance: " + String(Int(yPosition)))
        scoreLabel!.fontName = "Avenir"
        scoreLabel!.fontSize = 16
        scoreLabel!.fontColor = SKColor.blackColor()
        scoreLabel!.position = CGPoint(x: view!.frame.width * 0.5, y: view!.frame.height * 0.95)
        addChild(scoreLabel!)
        
        // Set constants based on scene size
        yIncrement = size.height / 5
        
        // Create penguin
        penguin.position = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        penguin.name = "penguin"
//        let playerBody = SKPhysicsBody(rectangleOfSize: penguin.frame.size)
//        playerBody.mass = 0
//        playerBody.dynamic = true
//        penguin.physicsBody = playerBody
        addChild(penguin)
        
        // Create penguin's shadow
        penguinShadow = SKShapeNode(rectOfSize: CGSize(width: penguin.frame.width, height: penguin.frame.width), cornerRadius: penguin.frame.width / 2)
        penguinShadow!.fillColor = SKColor.blackColor()
        penguinShadow!.alpha = 0.2
        penguinShadow!.position = CGPoint(x: 0, y: -penguinShadow!.frame.height/4)
//        let shadowBody = SKPhysicsBody(circleOfRadius: penguinShadow!.frame.size.height * 0.5)
//        shadowBody.dynamic = true
//        penguinShadow!.physicsBody = shadowBody
        penguin.addChild(penguinShadow!)
        
        // Set Aim Sprites
        targetReticle.xScale = 0.5
        targetReticle.yScale = 0.5
        targetDot1.xScale = 0.5
        targetDot1.yScale = 0.5
        targetDot2.xScale = 0.5
        targetDot2.yScale = 0.5
        targetDot3.xScale = 0.5
        targetDot3.yScale = 0.5
        
        // Create stage
        let stageNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: size.width, height: size.height))
        stage = stageNode
        stage!.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(stage!)
        
        generateBergs()
    }
    
    func generateBergs() {
        // Check to see if the topmost iceberg is below the view's frame.
        var topmostBerg: CGFloat = 0.0
        for berg in stage!.children {
            if berg.position.y > topmostBerg {
                let bergPositionInScene = self.convertPoint(berg.position, fromNode: stage!)
                topmostBerg = bergPositionInScene.y
            }
        }
        
        // While the topmost iceberg is below the view's frame, generate an iceberg.
        while (topmostBerg < view!.frame.height) {
            let berg = SKShapeNode(rectOfSize: CGSize(width: penguin.frame.height * 3, height: penguin.frame.height * 3))
            berg.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            
            let randomY = CGFloat(random()) % 150 + 110
            let randomX = CGFloat(random()) % view!.frame.width
            
            let previousBerg = stage!.children.last
            if previousBerg != nil {
                let previousBergPositionInScene = self.convertPoint(previousBerg!.position, fromNode: stage!)
                let bergPositionInSceneY = previousBergPositionInScene.y + randomY
                berg.position = self.convertPoint(CGPoint(x: randomX, y: bergPositionInSceneY), toNode: stage!)
                
                topmostBerg = bergPositionInSceneY
            } else {
                // If there are no previous icebergs, generate the initial iceberg under the penguin.
                berg.position = self.convertPoint(CGPoint(x: penguin.position.x, y: penguin.position.y), toNode: stage!)
            }

//            let bergBody = SKPhysicsBody(rectangleOfSize: berg.frame.size)
//            bergBody.dynamic = true
//            berg.physicsBody = bergBody
            berg.name = "berg"
            stage?.addChild(berg)
        }
    }
    
    func trackScore(translationY: CGFloat) {
        yPosition += -translationY
        if yPosition > score {
            score = yPosition
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        scoreLabel!.text = "Score: " + String(Int(score)) + "   Distance: " + String(Int(yPosition))
        
        generateBergs()
        
        checkGameOver()
    }
    
    func jump(destination: CGPoint) {
        let jumpHeight = yIncrement! * 0.5
        let jumpDuration = 1.0
        
        let jumpAction = SKAction.moveBy(CGVector(dx: 0.0, dy: jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let fallAction = SKAction.moveBy(CGVector(dx: 0.0, dy: -jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let moveAction = SKAction.moveBy(CGVector(dx: destination.x - penguin.position.x, dy: (destination.y - penguin.position.y) * 2), duration: NSTimeInterval(jumpDuration))

        let jumpSequence = SKAction.sequence([jumpAction, fallAction])
        let counterSequence = SKAction.sequence([fallAction, jumpAction])
        
        shakeScreen()
        penguin.runAction(jumpSequence, completion: { () -> Void in
            self.shakeScreen()
            
            if !self.onIceberg() {
                self.gameOver = true
            }
        })
        penguinShadow?.runAction(counterSequence)
        for berg in stage!.children{
            berg.runAction(moveAction)
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
            let randomIntensityOne = CGFloat(random() % 3 + 1)
            let randomIntensityTwo = CGFloat(random() % 3 + 1)
            shakeAnimation.values = [
                NSValue( CATransform3D:CATransform3DMakeTranslation(-randomIntensityOne, 0, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( randomIntensityOne, 0, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 0, -randomIntensityTwo, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 0, randomIntensityTwo, 0 ) ),
            ]
            shakeAnimation.autoreverses = true
            shakeAnimation.repeatCount = 2
            shakeAnimation.duration = 5/100
            
            view!.layer.addAnimation(shakeAnimation, forKey: nil)
        }
    }
}