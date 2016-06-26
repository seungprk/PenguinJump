//
//  Penguin.swift: The base penguin object that is player controlled. Implements its own touch event methods.
//
//  Created by Matthew Tso on 5/25/16.
//  Edited by Seung Park.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

/// The Penguin type determines which item the Penguin is holding.
enum PenguinType {
    case normal //The default Penguin type where there is no item.
    case parasol // The Parasol Penguin has a two second jump duration.
    case shark // The Shark Suit Penguin type has a shorter jump duration of 0.75 seconds and a 25% wind resistance.
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
    
    let penguinAtlas = SKTextureAtlas(named: "penguin")
    let penguinCropNode = SKCropNode()
    var body : SKSpriteNode!
    var shadow: SKSpriteNode!
    var item: SKNode?
    var doubleJumpWoosh : SKShapeNode!
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
    var doubleJumpStartPos = CGPoint()
    var doubleJumpStartTime = TimeInterval()
    
    init(type: PenguinType) {
        
        // Create penguin
        super.init(texture: nil, color: UIColor.clear(), size: CGSize(width: 80, height: 80))
        name = "penguin"
        penguinCropNode.position = CGPoint.zero
        penguinCropNode.zPosition = 21000
        addChild(penguinCropNode)
        
        body = SKSpriteNode(texture: penguinAtlas.textureNamed("penguin-front"))
        body.size = CGSize(width: 62, height: 76)
        body.position = CGPoint.zero
        body.zPosition = 21000
        penguinCropNode.addChild(body)
        penguinCropNode.maskNode = SKSpriteNode(texture: SKTexture(image: UIImage(named: "deathtemp")!), size: CGSize(width: 62, height: 76))
        
        // Assign shadowOffset after body's size is set.
        shadowOffsetY = body.frame.height * 0.45

        // Create penguin's shadow
        shadow = SKSpriteNode(texture: SKTexture(image: UIImage(named: "penguinshadow")!))
        shadow.size = CGSize(width: 48, height: 24)
        shadow.alpha = 0.5
        shadow.position = CGPoint(x: 0, y: -shadowOffsetY)
        shadow.zPosition = 2000
        addChild(shadow)
        
        /// Create physics body based on shadow circle
        let shadowBody = SKPhysicsBody(texture: SKTexture(image: UIImage(named: "penguinshadow")!), size: shadow.size)
        shadowBody.allowsRotation = false
        shadowBody.friction = 0
        shadowBody.affectedByGravity = false
        shadowBody.isDynamic = true
        shadowBody.categoryBitMask = PenguinCategory
        shadowBody.usesPreciseCollisionDetection = true
        
        shadow.physicsBody = shadowBody
        shadow.physicsBody?.collisionBitMask = Passthrough
        shadow.physicsBody?.contactTestBitMask = All

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
        
        // Customization depending on penguin selection
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
            item?.setScale(2)
            addChild(item!)
        case .shark:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_clothing")!))
            item?.zPosition = 22000
            item?.setScale(2)
            addChild(item!)
        case .penguinAngel:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "halo")!))
            item?.position.y += body.size.height / 2
            item?.setScale(2)
            item?.zPosition = 22000
            addChild(item!)
        case .penguinCrown:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "crown")!))
            item?.position.y += body.size.height / 1.75
            item?.zPosition = 22000
            item?.setScale(2)
            addChild(item!)
        case .penguinDuckyTube:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "ducky_tube")!))
            item?.position.x += 2
            item?.position.y -= body.size.height / 4
            item?.zPosition = 22000
            item?.setScale(2)
            addChild(item!)
        case .penguinMarathon:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "marathon_sign")!))
            item?.position.y -= body.size.height / 4
            item?.zPosition = 22000
            item?.setScale(1.5)
            addChild(item!)
        case .penguinMohawk:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "mohawk")!))
            item?.position.y += body.size.height / 2
            item?.zPosition = 22000
            item?.setScale(2)
            addChild(item!)
        case .penguinPolarBear:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "polar_bear_hat")!))
            item?.position.y += body.size.height / 4
            item?.zPosition = 22000
            item?.setScale(2)
            addChild(item!)
        case .penguinPropellerHat:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "propeller_hat")!))
            item?.position.y += body.size.height / 2.5
            item?.zPosition = 22000
            item?.setScale(2)
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
            item?.setScale(1.5)
            addChild(item!)
        case .penguinViking:
            item = SKSpriteNode(texture: SKTexture(image: UIImage(named: "viking_helmet")!))
            item?.position.y += body.size.height / 2
            item?.zPosition = 22000
            item?.setScale(2)
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
        
        body.texture = penguinAtlas.textureNamed("penguin-ready")
        
        for touch: AnyObject in touches {
            let touchPosition = touch.location(self)
            
            if touchPosition.y < -shadowOffsetY {
                let targetX = -touchPosition.x
                let targetY = -touchPosition.y - shadowOffsetY
                
                targetReticle.position = CGPoint(x: targetX, y: targetY * 2 - shadowOffsetY)
                targetDot1.position = CGPoint(x: targetX / 2, y: targetY * 2 / 2 - shadowOffsetY)
                targetDot2.position = CGPoint(x: targetX / 4, y: targetY * 2 / 4 - shadowOffsetY)
                targetDot3.position = CGPoint(x: targetX * 3/4, y: targetY * 2 * 3/4 - shadowOffsetY)
            } else {
                let targetX = -touchPosition.x
                
                targetReticle.position = CGPoint(x: targetX, y: -shadowOffsetY)
                targetDot1.position = CGPoint(x: targetX / 2, y: -shadowOffsetY)
                targetDot2.position = CGPoint(x: targetX / 4, y: -shadowOffsetY)
                targetDot3.position = CGPoint(x: targetX * 3/4, y: -shadowOffsetY)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let touchPosition = touch.location(self)
            
            if playerTouched {
                if touchPosition.y < -shadowOffsetY {
                    for touch: AnyObject in touches {
                        let touchEndPos = touch.location(self)
                        
                        let velocity = CGVector(dx: -touchEndPos.x, dy: -touchEndPos.y - shadowOffsetY * 1.5)
                        
                        if !inAir {
                            jump(velocity)
                        }
                    }
                } else {
                    for touch: AnyObject in touches {
                        let touchEndPos = touch.location(self)
                        
                        let velocity = CGVector(dx: -touchEndPos.x, dy: -shadowOffsetY / 2)
                        
                        if !inAir {
                            jump(velocity)
                        }
                    }
                }
                playerTouched = false
                targeting = false
                
                targetReticle.removeFromParent()
                targetDot1.removeFromParent()
                targetDot2.removeFromParent()
                targetDot3.removeFromParent()
            } else {
                body.texture = penguinAtlas.textureNamed("penguin-back")
            }
        }
    }
    
    func jump(velocity: CGVector) {
        
        // Default, or normal mode variables
        let jumpHeight = body.frame.height * 2
        var jumpDuration = 1.0
        var upModifier = 0.5
        var downModifier = 0.5
        
        hitByLightning = false
        removeAllActions()
        inAir = true
        
        // Customized Setup depending on Type
        switch (type!) {
        case .shark:
            jumpDuration = 0.7
        case .parasol:
            jumpDuration = 2.0
            upModifier = 0.25
            downModifier = 0.75
        default:
            break
        }
        
        // Jump Setup
        let jumpAction = SKAction.move(by: CGVector(dx: 0.0, dy: jumpHeight), duration: TimeInterval(jumpDuration * upModifier))
        let fallAction = SKAction.move(by: CGVector(dx: 0.0, dy: -jumpHeight), duration: TimeInterval(jumpDuration * downModifier))
        let enlargeAction = SKAction.scale(by: 2.0, duration: jumpDuration * upModifier)
        let reduceAction = SKAction.scale(by: 0.5, duration: jumpDuration * downModifier)
        let jumpCounter = SKAction.move(by: CGVector(dx: 0.0, dy: -jumpHeight), duration: TimeInterval(jumpDuration * upModifier))
        let fallCounter = SKAction.move(by: CGVector(dx: 0.0, dy: jumpHeight), duration: TimeInterval(jumpDuration * downModifier))
        let shadowEnlarge = SKAction.scale(to: 2.0, duration: jumpDuration * upModifier)
        let shadowReduce = SKAction.scale(to: 1.0, duration: jumpDuration * downModifier)
        let jumpTextureChange = SKAction.run({ self.body.texture = self.penguinAtlas.textureNamed("penguin-air1") })
        let fallTextureChange = SKAction.run({ self.body.texture = self.penguinAtlas.textureNamed("penguin-air2") })
        let landDelay = SKAction.wait(forDuration: 0.1)
        let endTextureChange = SKAction.run({ self.body.texture = self.penguinAtlas.textureNamed("penguin-back") })
        
        jumpAction.timingMode = SKActionTimingMode.easeOut
        fallAction.timingMode = SKActionTimingMode.easeIn
        enlargeAction.timingMode = SKActionTimingMode.easeOut
        reduceAction.timingMode = SKActionTimingMode.easeIn
        jumpCounter.timingMode = SKActionTimingMode.easeOut
        fallCounter.timingMode = SKActionTimingMode.easeIn
        shadowEnlarge.timingMode = .easeOut
        shadowReduce.timingMode = .easeIn
        
        let jumpSequence = SKAction.sequence([jumpTextureChange, jumpAction, fallTextureChange, fallAction])
        let enlargeSequence = SKAction.sequence([enlargeAction, reduceAction])
        let shadowEnlargeSequence = SKAction.sequence([shadowEnlarge, shadowReduce])
        let move = SKAction.move(by: CGVector(dx: velocity.dx, dy: velocity.dy * 2 + shadowOffsetY), duration: jumpDuration)
        
        // RunActions
        run(move)
        shadow.run(shadowEnlargeSequence)
        penguinCropNode.run(enlargeSequence)
        penguinCropNode.run(jumpSequence, completion: { () -> Void in
            self.inAir = false
            self.doubleJumped = false
            self.removeAllActions()
            self.penguinCropNode.run(SKAction.sequence([landDelay, endTextureChange]))
        })
        
        // Additional Actions Depending on Type
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
            item?.run(jumpAction, completion: {
                let delay = SKAction.wait(forDuration: 0.1)
                self.item?.run(delay, completion: {
                    self.item?.run(fallAction)
                })
            })
            item?.run(enlargeSequence)
        case .penguinMarathon:
            fallthrough
        case .penguinDuckyTube:
            fallthrough
        case .penguinSuperman:
            fallthrough
        case .shark:
            item?.run(jumpSequence)
            item?.run(enlargeSequence)
        case .parasol:
            let itemDelay = SKAction.wait(forDuration: 0.005)
            if let item = self.item{
                item.run(itemDelay, completion: {
                    item.run(jumpAction, completion: {
                        (item as! Item_Parasol).open()
                        item.zPosition = 22000
                        item.run(fallAction, completion: {
                            (item as! Item_Parasol).close()
                            item.zPosition = 20500
                        })
                    })
                })
                item.run(enlargeSequence)
            }
        default:
            break
        }
        
        // Play Jump Sound
        if (scene as! GameScene).gameData.soundEffectsOn == true {
            (scene as! GameScene).jumpSound?.currentTime = 0
            (scene as! GameScene).jumpSound?.play()
        }
    }
    
    func savePosForDoubleJump(positionInScene: CGPoint, time: TimeInterval) {
        doubleJumpStartPos = positionInScene
        doubleJumpStartTime = time
    }
    
    func doubleJump(positionInScene: CGPoint, time: TimeInterval) {
        // Check if time and distance long enough to execute movement
        let posDelta = doubleJumpStartPos - positionInScene
        let moveDistance = sqrt(posDelta.x * posDelta.x + posDelta.y * posDelta.y)
        let timeDelta = time - doubleJumpStartTime
        
        if moveDistance > 10 && timeDelta < 1.0 {
            
            // Movement
            let velocity = CGVector(dx: -posDelta.x, dy: -posDelta.y)
            let move = SKAction.move(by: velocity, duration: 1.0)
            run(move)
            
            // Graphic
            doubleJumpWoosh = SKShapeNode(circleOfRadius: 20.0)
            doubleJumpWoosh.fillColor = SKColor.clear()
            doubleJumpWoosh.strokeColor = SKColor.white()
            doubleJumpWoosh.xScale = 1.0
            doubleJumpWoosh.yScale = 1.0
            doubleJumpWoosh.position = body.position
            addChild(doubleJumpWoosh)
            
            let counterVelocity = CGVector(dx: posDelta.x, dy: posDelta.y)
            let counterMove = SKAction.move(by: counterVelocity, duration: 1.0)
            let airExpand = SKAction.scale(by: 2.0, duration: 0.4)
            let airFade = SKAction.fadeAlpha(to: 0.0, duration: 0.4)
            airExpand.timingMode = .easeOut
            airFade.timingMode = .easeIn
            
            doubleJumpWoosh.run(counterMove)
            doubleJumpWoosh.run(airExpand)
            doubleJumpWoosh.run(airFade, completion: {
                self.doubleJumpWoosh.removeFromParent()
                self.doubleJumpWoosh.alpha = 1.0
            })
            
            // Sound
            if (scene as! GameScene).gameData.soundEffectsOn == true {
                (scene as! GameScene).jumpSound?.currentTime = 0
                (scene as! GameScene).jumpSound?.play()
            }
        }
    }
    
    func land(sinkDuration: TimeInterval) {
        doubleJumped = false
        hitByLightning = false
        
        // Sink height should be the same as the iceberg's shadow height.
        let penguinSinking = SKAction.move(by: CGVector(dx: 0, dy: -20.0), duration: sinkDuration)
        self.run(penguinSinking)
    }
    
    func beginGame() {
        body.texture = penguinAtlas.textureNamed("penguin-back")
    }
}
