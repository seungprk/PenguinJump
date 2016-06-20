//
//  Coin.swift
//
//  Created by Matthew Tso on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

/**
 A collectable coin in the stage.
 
 - parameter value: An integer value of the coin towards the persistent coin total. The default is 1.
 */
class Coin: SKSpriteNode {
    
    let value = 1
    
    var shadow: SKSpriteNode!
    var body: SKSpriteNode!
    var particles = [SKSpriteNode]()
    var collected = false
    
    init() {
        
        /// Array of the coin's textures. The last texture is the coin image without the shine.
        var coinTextures = [SKTexture]()
        for i in 1...7 {
            coinTextures.append(SKTexture(image: UIImage(named: "coin\(i)")!))
        }
        
        // Designated initializer for SKSpriteNode.
        super.init(texture: nil, color: SKColor.clearColor(), size: coinTextures.last!.size())
        name = "coin"
        
        let coinShine = SKAction.animateWithTextures(coinTextures, timePerFrame: 1/30)
        let wait = SKAction.waitForDuration(2.5)
        let coinAnimation = SKAction.sequence([coinShine, wait])

        body = SKSpriteNode(texture: coinTextures.last)
        body.runAction(SKAction.repeatActionForever(coinAnimation))
        body.zPosition = 200
        body.name = "body"
        
        shadow = SKSpriteNode(texture: SKTexture(image: UIImage(named: "coin_shadow")!))
        shadow.alpha = 0.1
        shadow.position.y -= size.height // 3
        shadow.zPosition = -100
        shadow.physicsBody = shadowPhysicsBody(shadow.texture!, category: CoinCategory)
        
        addChild(body)
        addChild(shadow)
        
        bob()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bob() {
        
        let bobDepth = 6.0
        let bobDuration = 1.5
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        down.timingMode = .EaseInEaseOut
        up.timingMode = .EaseInEaseOut
        let bobSequence = SKAction.sequence([down, up])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        removeAllActions()
        body.runAction(bob)
    }
    
    /**
     Creates coin particles used to increment the charge bar.
     - parameter camera: The target `SKCameraNode`. The particles are added as children of the camera because the particles need to move to the charge bar, which is a child of the camera.
     */
    func generateCoinParticles(camera: SKCameraNode) {
        
        let numberOfParticles = random() % 2 + 3
        
        for _ in 1...numberOfParticles {
            let particle = SKSpriteNode(color: SKColor.yellowColor(), size: CGSize(width: size.width / 5, height: size.width / 5))
            //                let randomX = random() % Int(size.width) - Int(size.width / 2)
            let randomX = Int( arc4random_uniform( UInt32(size.width) ) ) - Int(size.width / 2)
            let randomY = Int( arc4random_uniform( UInt32(size.height) ) ) - Int(size.height / 2)
            
            let bodyPositionInScene = convertPoint(body.position, toNode: scene!)
            let bodyPositionInCam = camera.convertPoint(bodyPositionInScene, fromNode: scene!)
            
            
            particle.position = CGPoint(x: bodyPositionInCam.x + CGFloat(randomX), y: bodyPositionInCam.y + CGFloat(randomY))
            particle.zPosition = 200000
            
            particles.append(particle)
        }
        for particle in particles {
            camera.addChild(particle)
        }
        
    }

}
