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
    
    var enableScreenShake = false
    
    var cam:SKCameraNode!
    
    var penguin = SKSpriteNode(imageNamed: "penguintemp")
    var penguinShadow: SKShapeNode!
    let targetReticle = SKSpriteNode(imageNamed: "targetcircle")
    let targetDot1 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot2 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot3 = SKSpriteNode(imageNamed: "targetdot")
    var stage: IcebergGenerator!
    var yIncrement: CGFloat!
    
    var gameStarted = false
    var gameOver = false
    var lockMovement = true
    var playerTouched = false
//    var penguinInAir = false
//    var doubleJumped = false
//    var waves: SKSpriteNode!
    
    var score: CGFloat = 0.0
    var intScore = 0
    var scoreLabel: SKLabelNode!
    
    let title = SKSpriteNode(texture: nil)
    let playButton = SKLabelNode(text: "Play")
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.2, green: 0.9, blue: 0.9, alpha: 0.4)

        newGame()
        
//        cam.xScale = 0.2
//        cam.yScale = 0.2
        
//        let camView = cam.view
        
        title.position = CGPointZero
        title.position.y += view.frame.height / 3
        title.zPosition = 10000
        cam.addChild(title)
        
        let titleLabel = SKLabelNode(text: "PENGUIN")
        titleLabel.fontName = "Helvetica Neue Condensed Black"
        titleLabel.fontSize = 80
        titleLabel.position = CGPointZero
        
        let subtitleLabel = SKLabelNode(text: "JUMP")
        subtitleLabel.fontName = "Helvetica Neue Condensed Black"
        subtitleLabel.fontSize = 120
        subtitleLabel.position = CGPointZero
        subtitleLabel.position.y -= subtitleLabel.frame.height
        
        title.addChild(titleLabel)
        title.addChild(subtitleLabel)
        
        playButton.name = "playButton"
        playButton.fontName = "Helvetica Neue Condensed Black"
        playButton.fontSize = 60
        playButton.fontColor = SKColor.blackColor()
        playButton.position = CGPointZero
        playButton.position.y -= view.frame.height / 3
//        playButton.position.x = CGRectGetMidX(cam.frame)
//        playButton.position.y = CGRectGetMidY(cam)
        playButton.zPosition = 10000
        cam.addChild(playButton)
        
        cam.position = penguin.position
        cam.position.y += view.frame.height * 0.06
        let zoomedIn = SKAction.scaleTo(0.4, duration: 0.0)
        cam.runAction(zoomedIn)
        
        
    }
    
    func trackScore() {
        if penguin.position.y > score {
            score = penguin.position.y / 10
        }
    }
    
    func bob(node: SKSpriteNode) {
        let bobDepth = 2.0
        let bobDuration = 2.0
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        let wait = SKAction.waitForDuration(bobDuration / 2)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        
        let bobSequence = SKAction.sequence([down, wait, up, wait])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        node.removeAllActions()
        node.runAction(bob)
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if !doubleJumped && penguinInAir {
//            if let touch = touches.first {
//                let positionInScene = touch.locationInNode(self)
//                if positionInScene.y < penguin.position.y {
//                    
////                    let delta = penguin.position - positionInScene
//                    doubleJump(positionInScene)
//                    
//                    
//                } else {
//                    
//                }
//                
//            }
//            
//        }
        
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
        } else {
            for touch in touches {
                let positionInScene = touch.locationInNode(self)
                let touchedNodes = self.nodesAtPoint(positionInScene)
                for touchedNode in touchedNodes {
                    if touchedNode.name == "playButton" {
                        print("play clicked")
                        beginGame()
                    }
                }
            }
        }
    }
    
    func beginGame() {
        let zoomOut = SKAction.scaleTo(1.0, duration: 2.0)
        
        let cameraFinalDestX = penguin.position.x
        let cameraFinalDestY = penguin.position.y + frame.height / 4
        
        let pan = SKAction.moveTo(CGPoint(x: cameraFinalDestX, y: cameraFinalDestY), duration: 2.0)
        pan.timingMode = .EaseInEaseOut
        zoomOut.timingMode = .EaseInEaseOut
        
        
        cam.runAction(zoomOut)
        cam.runAction(pan, completion: {
            self.cam.addChild(self.scoreLabel)
            
            self.gameStarted = true
            self.lockMovement = false
        })
        
        playButton.removeFromParent()
        title.removeFromParent()
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

    
    func jump(destination: CGPoint) {
//        if !lockMovement {
            penguin.removeAllActions()
            
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
            
//            penguinInAir = true
            lockMovement = true
            penguin.runAction(jumpSequence, completion: { () -> Void in
                self.shakeScreen()
                
                self.checkOnIceberg()
                
//                self.penguinInAir = false
                let penguinSinking = SKAction.moveBy(CGVector(dx: 0, dy: -20), duration: 7.0)
                self.penguin.runAction(penguinSinking)
                self.lockMovement = false
            })
            
            //        centerCamera()
//        }
        
    }
    
//    func doubleJump(direction: CGVector) {
//        if !doubleJumped {
//            let delta = penguin.position -
//            
//            let nudge = SKAction.moveBy(direction, duration: 0.5)
//            
//            doubleJumped = true
//            penguin.runAction(nudge, completion: {
//                self.doubleJumped = false
//            })
//        }
//    }
    
    
    
    

    override func update(currentTime: NSTimeInterval) {

        stage.update()
        
        if gameStarted {
//            scoreLabel.text = "Score: " + String(Int(score))
            scoreLabel.text = "Score: " + String(intScore)

            centerCamera()
            trackScore()
            checkGameOver()
        }
        
    }
    func checkGameOver() {
        if gameOver {
            view?.paused = true
            
            backgroundColor = SKColor.redColor()
            
            let restartButton = SKLabelNode(text: "Restart")
            restartButton.name = "restartButton"
            restartButton.userInteractionEnabled = false
            restartButton.fontName = "Helvetica Neue Condensed Black"
            restartButton.fontSize = 48
            restartButton.fontColor = SKColor.whiteColor()
            restartButton.position = CGPointZero // CGPoint(x: view!.frame.width * 0.5, y: view!.frame.height * 0.5)
            restartButton.zPosition = 30000
            cam.addChild(restartButton)
        }
    }
 
    
    func centerCamera() {
        let cameraFinalDestX = penguin.position.x
        let cameraFinalDestY = penguin.position.y + frame.height / 4
        
        let pan = SKAction.moveTo(CGPoint(x: cameraFinalDestX, y: cameraFinalDestY), duration: 0.25)
        pan.timingMode = .EaseInEaseOut
        
        cam.runAction(pan)
    }
    
    func newGame() {
        gameOver = false
        
        cam = SKCameraNode()
        cam.xScale = 1.0
        cam.yScale = 1.0
        
        camera = cam
        addChild(cam)
        
        cam.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        
        stage = IcebergGenerator(view: view!, camera: cam)
        stage.position = view!.center
        addChild(stage)

//        backgroundColor = SKColor(red: 0.2, green: 0.9, blue: 0.9, alpha: 0.4)

        backgroundColor = SKColor(red: 0/255, green: 151/255, blue: 255/255, alpha: 1.0)
        
        scoreLabel = SKLabelNode(text: "Score: " + String(Int(score)))
        scoreLabel.fontName = "Helvetica Neue Condensed Black"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: 0, y: view!.frame.height * 0.45)
        scoreLabel.zPosition = 30000

        
        
        
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
        penguin.removeAllChildren()
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
    
    
    
    
    func onIceberg() -> Bool {
        var onBerg = false
        for berg in stage!.children {
            if penguinShadow!.intersectsNode(berg) {
                let berg = berg as! Iceberg
                onBerg = true
                stage?.updateCurrentBerg(berg)
                berg.land()
                
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
                berg.land()
                
                intScore += 1
                berg.sink(7.0, completion: {
                    if !self.onIceberg() /* && !self.penguinInAir */{
                        
                        self.gameOver = true
                    }
                })
            } else {
                if !onIceberg() /*&& !penguinInAir*/ {
                    gameOver = true
                }
                
            }
        }
        
    
    }
    
    func restart() {
        removeAllChildren()
        removeAllActions()
        cam.removeAllChildren()

        newGame()
        intScore = 0
        cam.addChild(scoreLabel)
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
