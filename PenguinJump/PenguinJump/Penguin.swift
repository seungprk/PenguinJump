//
//  Penguin.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/25/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

/// The Penguin type determines which item the Penguin is holding.
enum PenguinType {
    /// The default Penguin type where there is no item.
    case normal
    /// The Parasol Penguin has a two second jump duration.
    case parasol
    /// The Shark Suit Penguin type has a shorter jump duration of 0.75 seconds and a 25% wind resistance.
    case shark
    
    case tinfoil
    case penguinViking
    case penguinAngel
    case penguinSuperman
    case penguinPolarBear
    case penguinTophat
    case penguinPropellerHat
    case penguinMohawk
    case penguinCrown
    case penguinMarathon
    case penguinDuckyTube
}

/**
    The base Penguin class describes the node object that can be controlled by the player.
 
    - parameter targeting: Boolean that is true during the touch and drag control event.
*/
class Penguin: SKSpriteNode {
    
    let penguinCropNode = SKCropNode()
    let body = SKSpriteNode(texture: SKTexture(image: UIImage(named: "penguin")!))
    var shadow: SKShapeNode!
    var item: SKNode?

    let targetReticle = SKSpriteNode(texture: SKTexture(image: UIImage(named: "targetcircle")!))
    let targetDot1 = SKSpriteNode(texture: SKTexture(image: UIImage(named: "targetdot")!))
    let targetDot2 = SKSpriteNode(texture: SKTexture(image: UIImage(named: "targetdot")!))
    let targetDot3 = SKSpriteNode(texture: SKTexture(image: UIImage(named: "targetdot")!))
    
    /// Boolean that is true during the touch and drag control event.
    var targeting = false
    var playerTouched = false
    
    /// The PenguinType of this penguin.
    var type: PenguinType!
    /// The offset distance of the shadow from the penguin's body. Used to adjust the move action in the jump method to align the shadow with the center of the targeting reticle.
    var shadowOffsetY: CGFloat!
    
    // Game session logic
    var doubleJumped = false
    var inAir = false
    var onBerg = false
    var contactingLightning = false
    var hitByLightning = false
    
    
    init(type: PenguinType) {
        super.init(texture: nil, color: UIColor.clearColor(), size: body.size)
        
        // Create penguin
        name = "penguin"
        size.height = 70
        size.width = 60
        penguinCropNode.position = CGPointZero
        penguinCropNode.zPosition = 21000
        addChild(penguinCropNode)
        body.size = CGSize(width: 25, height: 44)
        body.position = CGPointZero
        body.zPosition = 21000
//        addChild(body)
        penguinCropNode.addChild(body)
        penguinCropNode.maskNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "deathtemp")!))
        
        // Assign shadowOffset after body's size is set.
        shadowOffsetY = body.frame.height * 0.35

        // Create penguin's shadow
        shadow = SKShapeNode(rectOfSize: CGSize(width: body.frame.width * 0.8, height: body.frame.width * 0.8), cornerRadius: body.frame.width / 2)
        shadow.fillColor = SKColor.blackColor()
        shadow.alpha = 0.2
        shadow.position = CGPoint(x: 0, y: -shadowOffsetY)
        shadow.zPosition = 2000
        addChild(shadow)
        
        // Create physics body based on shadow circle
        let shadowBody = SKPhysicsBody(circleOfRadius: shadow.frame.width / 2)
        shadowBody.allowsRotation = false
        shadowBody.friction = 0
        shadowBody.affectedByGravity = false
        shadowBody.dynamic = true
        shadowBody.categoryBitMask = PenguinCategory
        shadowBody.usesPreciseCollisionDetection = true
        
        shadow.physicsBody = shadowBody
        shadow.physicsBody?.collisionBitMask = Passthrough
        shadow.physicsBody?.contactTestBitMask = 0xFFFFFFFF

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
        
        self.type = type
        
        switch (type) {
        case .normal:
            break
        case .parasol:
            item = Item_Parasol()
            item?.position.x += (item as! Item_Parasol).parasol_closed.size.width * 1.5
            item?.position.y -= (item as! Item_Parasol).parasol_closed.size.width
            item?.zPosition = 20500
            addChild(item!)
        case .tinfoil:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "tinfoil_hat")!))
            item?.zPosition = 22000
            item?.position.y += body.size.height / 3
            addChild(item!)
        case .shark:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_clothing")!))
            item?.zPosition = 22000
            addChild(item!)
        case .penguinAngel:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "halo")!))
            item?.position.y += body.size.height / 2
            item?.zPosition = 22000
            addChild(item!)
        case .penguinCrown:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "crown")!))
            item?.position.y += body.size.height / 1.75
            item?.zPosition = 22000
            addChild(item!)
        case .penguinDuckyTube:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "ducky_tube")!))
            item?.position.y -= body.size.height / 4
            item?.zPosition = 22000
            addChild(item!)
        case .penguinMarathon:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "marathon_sign")!))
            item?.position.y -= body.size.height / 4
            item?.zPosition = 22000
            addChild(item!)
        case .penguinMohawk:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "mohawk")!))
            item?.position.y += body.size.height / 2
            item?.zPosition = 22000
            addChild(item!)
        case .penguinPolarBear:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "polar_bear_hat")!))
            item?.position.y += body.size.height / 4
            item?.zPosition = 22000
            addChild(item!)
        case .penguinPropellerHat:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "propeller_hat")!))
            item?.position.y += body.size.height / 2
            item?.zPosition = 22000
            addChild(item!)
        case .penguinSuperman:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "cape")!))
            item?.position.y -= body.size.height / 3.5
            item?.zPosition = 22000
            addChild(item!)
        case .penguinTophat:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "tophat")!))
            item?.position.y += body.size.height / 2
            item?.position.x -= body.size.width / 8
            item?.zPosition = 22000
            addChild(item!)
        case .penguinViking:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "viking_helmet")!))
            item?.position.y += body.size.height / 2
            item?.zPosition = 22000
            addChild(item!)
        }
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
        switch (type!) {
        case .penguinAngel:
            fallthrough
        case .penguinCrown:
            fallthrough
        case .penguinDuckyTube:
            fallthrough
        case .penguinMarathon:
            fallthrough
        case .penguinMohawk:
            fallthrough
        case .penguinPolarBear:
            fallthrough
        case .penguinPropellerHat:
            fallthrough
        case .penguinSuperman:
            fallthrough
        case .penguinTophat:
            fallthrough
        case .penguinViking:
            fallthrough
        case .shark:
            fallthrough
        case .tinfoil:
            fallthrough
        case .normal:
            hitByLightning = false
            removeAllActions()
            inAir = true
            
            // Jump Duration based on travel distance
            //        let jumpRate: CGFloat = 150
            //        let distance = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
            //        let jumpDuration = Double(distance / jumpRate)
            
            // Fixed jump duration
            let jumpDuration = type == .shark ? 0.7 : 1.0
            let jumpHeight = body.frame.height * 2
            
            
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
            
            let move = SKAction.moveBy(CGVector(dx: velocity.dx, dy: velocity.dy * 2 + shadowOffsetY), duration: jumpDuration)
            
            runAction(move)
            
            shadow.runAction(shadowEnlargeSequence)
            penguinCropNode.runAction(enlargeSequence)
            penguinCropNode.runAction(jumpSequence, completion: { () -> Void in
                self.inAir = false
                self.doubleJumped = false
                self.removeAllActions()
            })
            
            switch (type!) {
            case .penguinAngel:
                fallthrough
            case .penguinCrown:
                fallthrough
            case .penguinMohawk:
                fallthrough
            case .penguinPolarBear:
                fallthrough
            case .penguinPropellerHat:
                fallthrough
            case .penguinTophat:
                fallthrough
            case .penguinViking:
                fallthrough
            case .tinfoil:
                item?.runAction(jumpAction, completion: {
                    let delay = SKAction.waitForDuration(0.1)
                    
                    self.item?.runAction(delay, completion: {
                        self.item?.runAction(fallAction)
                    })
                })
                item?.runAction(enlargeSequence)

            case .penguinMarathon:
                fallthrough
            case .penguinDuckyTube:
                fallthrough
            case .penguinSuperman:
                fallthrough
            case .shark:
                item?.runAction(jumpSequence)
                item?.runAction(enlargeSequence)
                
            default:
                break
            }
            
            if (scene as! GameScene).gameData.soundEffectsOn == true {
                (scene as! GameScene).jumpSound?.currentTime = 0
                (scene as! GameScene).jumpSound?.play()
            }
            
        // Parasol jump action
        case .parasol:
            hitByLightning = false
            removeAllActions()
            inAir = true
            
            // Fixed jump duration
            let jumpDuration = 2.0
            let jumpHeight = body.frame.height * 2
            
            // Jump actions
            let jumpAction = SKAction.moveBy(CGVector(dx: 0.0, dy: jumpHeight), duration: NSTimeInterval(jumpDuration * 0.25))
            let fallAction = SKAction.moveBy(CGVector(dx: 0.0, dy: -jumpHeight), duration: NSTimeInterval(jumpDuration * 0.75))
            let enlargeAction = SKAction.scaleBy(2.0, duration: jumpDuration * 0.25)
            let reduceAction = SKAction.scaleBy(0.5, duration: jumpDuration * 0.75)
            let jumpCounter = SKAction.moveBy(CGVector(dx: 0.0, dy: -jumpHeight), duration: NSTimeInterval(jumpDuration * 0.25))
            let fallCounter = SKAction.moveBy(CGVector(dx: 0.0, dy: jumpHeight), duration: NSTimeInterval(jumpDuration * 0.75))
            let shadowEnlarge = SKAction.scaleTo(2.0, duration: jumpDuration * 0.25)
            let shadowReduce = SKAction.scaleTo(1.0, duration: jumpDuration * 0.75)
            
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
            
            let move = SKAction.moveBy(CGVector(dx: velocity.dx, dy: velocity.dy * 2 + shadowOffsetY), duration: jumpDuration)
//            let counterMove = SKAction.moveBy(CGVector(dx: -velocity.dx, dy: -velocity.dy * 2), duration: jumpDuration)
            
            let itemDelay = SKAction.waitForDuration(0.005)
            
            shadow.runAction(shadowEnlargeSequence)
            
            
            runAction(move)

            if let item = self.item{
                item.runAction(itemDelay, completion: {
                    item.runAction(jumpAction, completion: {
                        (item as! Item_Parasol).open()
                        item.zPosition = 22000
                        
                        item.runAction(fallAction, completion: {
                            (item as! Item_Parasol).close()
                            item.zPosition = 20500
                        })
                    })
                })
                item.runAction(enlargeSequence)
            }
            
            penguinCropNode.runAction(enlargeSequence)
            penguinCropNode.runAction(jumpSequence, completion: { () -> Void in
                self.inAir = false
                self.doubleJumped = false
                self.removeAllActions()
            })
            
            if (scene as! GameScene).gameData.soundEffectsOn == true {
                (scene as! GameScene).jumpSound?.currentTime = 0
                (scene as! GameScene).jumpSound?.play()
            }
        }
        
    }
    
    func land(sinkDuration: NSTimeInterval) {
        doubleJumped = false
        hitByLightning = false

        let penguinSinking = SKAction.moveBy(CGVector(dx: 0, dy: -20.0), duration: sinkDuration)
        self.runAction(penguinSinking)
    }
}
