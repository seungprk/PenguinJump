//
//  Penguin.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/25/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Penguin: SKSpriteNode {
    
    let penguinCropNode = SKCropNode()
    let body = SKSpriteNode(imageNamed: "penguintemp")
    var shadow: SKShapeNode!
    
    let targetReticle = SKSpriteNode(imageNamed: "targetcircle")
    let targetDot1 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot2 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot3 = SKSpriteNode(imageNamed: "targetdot")

    var targeting = false
    var playerTouched = false
    
    var doubleJumped = false
    var inAir = false
    var onBerg = false
        
    init() {
        super.init(texture: nil, color: UIColor.clearColor(), size: body.size)
        
        // Create penguin
        name = "penguin"
        penguinCropNode.position = CGPointZero
        penguinCropNode.zPosition = 21000
        addChild(penguinCropNode)
        body.position = CGPointZero
        body.zPosition = 21000
//        addChild(body)
        penguinCropNode.addChild(body)
        penguinCropNode.maskNode = SKSpriteNode(imageNamed: "deathtemp")
        
        // Create penguin's shadow
        shadow = SKShapeNode(rectOfSize: CGSize(width: body.frame.width * 0.8, height: body.frame.width * 0.8), cornerRadius: body.frame.width / 2)
        shadow.fillColor = SKColor.blackColor()
        shadow.alpha = 0.2
        shadow.position =  CGPoint(x: 0, y: -body.frame.height / 2 + body.frame.height / 4)
        shadow.zPosition = 2000
        addChild(shadow)
        
        // Set Aim Sprites
        let xScale: CGFloat = 0.3
        let yScale: CGFloat = 0.3
        let zPosition: CGFloat = 1500
        
        targetReticle.xScale = xScale
        targetReticle.yScale = yScale
        targetReticle.zPosition = zPosition
        
        targetDot1.xScale = xScale
        targetDot1.yScale = yScale
        targetDot1.zPosition = zPosition
        
        targetDot2.xScale = xScale
        targetDot2.yScale = yScale
        targetDot2.zPosition = zPosition
        
        targetDot3.xScale = xScale
        targetDot3.yScale = yScale
        targetDot3.zPosition = zPosition
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        playerTouched = true
        targeting = true
        
        targetReticle.position = CGPointZero
        targetDot1.position = CGPointZero
        targetDot2.position = CGPointZero
        targetDot3.position = CGPointZero
        
        addChild(targetReticle)
        addChild(targetDot1)
        addChild(targetDot2)
        addChild(targetDot3)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let touchPosition = touch.locationInNode(self)
            
            if touchPosition.y < 0 {
                let targetX = -touchPosition.x
                let targetY = -touchPosition.y
                
                targetReticle.position = CGPoint(x: targetX, y: targetY * 2)
                targetDot1.position = CGPoint(x: targetX / 2, y: targetY * 2 / 2)
                targetDot2.position = CGPoint(x: targetX / 4, y: targetY * 2 / 4)
                targetDot3.position = CGPoint(x: targetX * 3/4, y: targetY * 2 * 3/4)
            } else {
                let targetX = -touchPosition.x
                
                targetReticle.position = CGPoint(x: targetX, y: 0)
                targetDot1.position = CGPoint(x: targetX / 2, y: 0)
                targetDot2.position = CGPoint(x: targetX / 4, y: 0)
                targetDot3.position = CGPoint(x: targetX * 3/4, y: 0)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let touchPosition = touch.locationInNode(self)
            
            if playerTouched {
                if touchPosition.y < 0 {
                    for touch: AnyObject in touches {
                        let touchEndPos = touch.locationInNode(self)
                        
                        let velocity = CGVector(dx: -touchEndPos.x, dy: -touchEndPos.y)
                        
                        if !inAir {
                            jump(velocity)
                        }
                    }
                } else {
                    for touch: AnyObject in touches {
                        let touchEndPos = touch.locationInNode(self)
                        
                        let velocity = CGVector(dx: -touchEndPos.x, dy: 0)
                        
                        if !inAir {
                            jump(velocity)
                        }                    }
                }
                playerTouched = false
                targeting = false
                
                targetReticle.removeFromParent()
                targetDot1.removeFromParent()
                targetDot2.removeFromParent()
                targetDot3.removeFromParent()
            }
        }
    }
    
    
    func jump(velocity: CGVector) {
        removeAllActions()
        inAir = true
        onBerg = false
        
        // Jump Duration based on travel distance
//        let jumpRate: CGFloat = 150
//        let distance = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
//        let jumpDuration = Double(distance / jumpRate)
        
        // Fixed jump duration
        let jumpDuration = 1.0
        let jumpHeight = frame.height * 2
        
        
        let jumpAction = SKAction.moveBy(CGVector(dx: 0.0, dy: jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let fallAction = SKAction.moveBy(CGVector(dx: 0.0, dy: -jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let enlargeAction = SKAction.scaleBy(2.0, duration: jumpDuration * 0.5)
        let reduceAction = SKAction.scaleBy(0.5, duration: jumpDuration * 0.5)
        let jumpCounter = SKAction.moveBy(CGVector(dx: 0.0, dy: -jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let fallCounter = SKAction.moveBy(CGVector(dx: 0.0, dy: jumpHeight), duration: NSTimeInterval(jumpDuration * 0.5))
        let shadowEnlarge = SKAction.scaleTo(2.0, duration: jumpDuration * 0.5)
        let shadowReduce = SKAction.scaleTo(1.0, duration: jumpDuration * 0.5)

        jumpAction.timingMode = SKActionTimingMode.EaseOut
        fallAction.timingMode = SKActionTimingMode.EaseIn
        enlargeAction.timingMode = SKActionTimingMode.EaseOut
        reduceAction.timingMode = SKActionTimingMode.EaseIn
        jumpCounter.timingMode = SKActionTimingMode.EaseOut
        fallCounter.timingMode = SKActionTimingMode.EaseIn
        shadowEnlarge.timingMode = .EaseOut
        shadowReduce.timingMode = .EaseIn

        let jumpSequence = SKAction.sequence([jumpAction, fallAction])
        let enlargeSequence = SKAction.sequence([enlargeAction, reduceAction])
        let shadowEnlargeSequence = SKAction.sequence([shadowEnlarge, shadowReduce])
        
        let move = SKAction.moveBy(CGVector(dx: velocity.dx, dy: velocity.dy * 2), duration: jumpDuration)
        
        shadow.runAction(shadowEnlargeSequence)
        
        penguinCropNode.runAction(enlargeSequence)
        runAction(move)
        penguinCropNode.runAction(jumpSequence, completion: { () -> Void in
            self.inAir = false
            self.doubleJumped = false
            self.removeAllActions()
        })
        
        (scene as! GameScene).jumpSound?.currentTime = 0
        (scene as! GameScene).jumpSound?.play()
    }
    
    func land(sinkDuration: NSTimeInterval) {
        onBerg = true
        let penguinSinking = SKAction.moveBy(CGVector(dx: 0, dy: -20), duration: sinkDuration)
        self.runAction(penguinSinking)
    }
}
