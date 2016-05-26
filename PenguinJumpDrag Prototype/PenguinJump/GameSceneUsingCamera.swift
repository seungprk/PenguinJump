//
//  GameSceneUsingCamera.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/25/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

// Overload minus operator to use on CGPoint
func -(first: CGPoint, second: CGPoint) -> CGPoint {
    let deltaX = first.x - second.x
    let deltaY = first.y - second.y
    return CGPoint(x: deltaX, y: deltaY)
}

class GameSceneUsingCamera: SKScene {
    
    var enableScreenShake = true
    
    var cam:SKCameraNode!
    
    var penguin = SKSpriteNode(imageNamed: "penguintemp")
    var penguinShadow: SKShapeNode!
    let targetReticle = SKSpriteNode(imageNamed: "targetcircle")
    let targetDot1 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot2 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot3 = SKSpriteNode(imageNamed: "targetdot")
    var stage: IcebergGenerator!
    var yIncrement: CGFloat!
    
    var gameOver = false
    var lockMovement = false
    var playerTouched = false
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.2, green: 0.9, blue: 0.9, alpha: 0.4)

        newGame()

    }
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let firstTouch = touches.first
//        let location = (firstTouch?.locationInNode(self))!
//        
////        penguin.position = location
//        jump(location)
////        centerCamera()
//    }
    
    
    
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
                            
//                            let destination = CGPoint(x: -touchEndPos.x, y: -touchEndPos.y)
                            
                            let delta = penguin.position - touchEndPos
                            
                            jump(delta)
                        }
                    } else {
                        for touch: AnyObject in touches {
                            let touchEndPos = touch.locationInNode(self)
                            
                            let delta = CGPoint(x: penguin.position.x - touchEndPos.x, y: 0)
                            
                            jump(delta)
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

    
    
    
    
    

    override func update(currentTime: NSTimeInterval) {
        stage.update()
        
        centerCamera()
        
        checkGameOver()
    }
    
    func checkGameOver() {
        if gameOver {
            backgroundColor = SKColor.redColor()
        }
    }
    
    func centerCamera() {
        let cameraFinalDestX = penguin.position.x
        let cameraFinalDestY = penguin.position.y + frame.height / 4
        
        let pan = SKAction.moveTo(CGPoint(x: cameraFinalDestX, y: cameraFinalDestY), duration: 0.4)
        pan.timingMode = .EaseOut
        
        cam.runAction(pan)
    }
    
    func newGame() {
        cam = SKCameraNode()
        cam.xScale = 1.0
        cam.yScale = 1.0
        
        camera = cam
        addChild(cam)
        
        cam.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        
        stage = IcebergGenerator(view: view!, camera: cam)
        stage.position = view!.center
        addChild(stage)

        backgroundColor = SKColor(red: 0/255, green: 151/255, blue: 255/255, alpha: 1.0)
        
        yIncrement = size.height / 5

        // Create penguin
        let penguinPositionInScene = CGPoint(x: size.width * 0.5, y: size.height * 0.3)
        
        penguin.position = penguinPositionInScene
        penguin.name = "penguin"
        penguin.zPosition = 2100
        addChild(penguin)
        
        // Create penguin's shadow
        penguinShadow = SKShapeNode(rectOfSize: CGSize(width: penguin.frame.width, height: penguin.frame.width), cornerRadius: penguin.frame.width / 2)
        penguinShadow.fillColor = SKColor.blackColor()
        penguinShadow.alpha = 0.2
        penguinShadow.position =  CGPoint(x: 0, y: -penguin.frame.height / 2 + penguinShadow.frame.height / 2)
        penguinShadow.zPosition = 2000
        penguin.addChild(penguinShadow)
        
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
        
        stage.newGame(convertPoint(penguinPositionInScene, toNode: stage))

    }
    
    func jump(destination: CGPoint) {
        let jumpHeight = yIncrement * 0.5
        let jumpDuration = 1.0
//        let xPlatformTravel = destination.x - penguin.position.x
//        let yPlatformTravel = (destination.y - penguin.position.y) * 2
        
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
        
        let jumpCounter = SKAction.moveBy(CGVector(dx: 0.0, dy: -jumpHeight / 2), duration: NSTimeInterval(jumpDuration * 0.5))
        let fallCounter = SKAction.moveBy(CGVector(dx: 0.0, dy: jumpHeight / 2), duration: NSTimeInterval(jumpDuration * 0.5))
        jumpCounter.timingMode = SKActionTimingMode.EaseOut
        fallCounter.timingMode = SKActionTimingMode.EaseIn
        
        let shadowEnlarge = SKAction.scaleTo(0.6, duration: jumpDuration * 0.5)
        let shadowReduce = SKAction.scaleTo(1.0, duration: jumpDuration * 0.5)
        shadowEnlarge.timingMode = .EaseOut
        shadowReduce.timingMode = .EaseIn
        let shadowEnlargeSequence = SKAction.sequence([shadowEnlarge, shadowReduce])
        
        let counterSequence = SKAction.sequence([jumpCounter, fallCounter])
        
        let move = SKAction.moveBy(CGVector(dx: destination.x, dy: destination.y * 2), duration: jumpDuration)
        
        penguin.runAction(enlargeSequence)
//        penguinShadow.runAction(enlargeSequence)
        penguinShadow.runAction(shadowEnlargeSequence)
        
        penguinShadow.runAction(counterSequence)
        penguin.runAction(move)
        
        penguin.runAction(jumpSequence, completion: { () -> Void in
            self.shakeScreen()
            
            self.checkOnIceberg()
        })
        
//        centerCamera()
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
    
//    func landOnIceberg() {
//        
//    }
    
    func checkOnIceberg() {
//        let check = onIceberg() ? "On an iceberg" : "Not on an iceberg"
        for berg in stage.children {
            if penguinShadow.intersectsNode(berg) {
                let berg = berg as! Iceberg
//                onBerg = true
                stage.updateCurrentBerg(berg)
                berg.bump()
                berg.sink(7.0, completion: {
                    if !self.onIceberg() {
                        self.gameOver = true
                    }
                })
            } else {
                if !self.onIceberg() {
                    gameOver = true
                }
                
            }
        }
        
    
    }
    
    func restart() {
        removeAllChildren()
        removeAllActions()

        newGame()
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
