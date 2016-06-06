//
//  Coin.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Coin: SKSpriteNode {
    let value = 1
    
    var shadow: SKSpriteNode!
    var body: SKSpriteNode!
    var collected = false
    
    var particles = [SKSpriteNode]()
    
    init() {
        let coinTexture = SKTexture(imageNamed: "coin")
        super.init(texture: nil, color: SKColor.clearColor(), size: coinTexture.size())
        
        name = "coin"
        
        body = SKSpriteNode(texture: coinTexture)
        body.zPosition = 100
        body.name = "body"
        shadow = SKSpriteNode(imageNamed: "circle_shadow")
        shadow.alpha = 0.1
        shadow.position.y -= size.height / 3
        shadow.zPosition = -100
        
        addChild(body)
        addChild(shadow)
        
        bob()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bob() {
        let bobDepth = 4.0
        let bobDuration = 2.0
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration)
        down.timingMode = .EaseInEaseOut
        up.timingMode = .EaseInEaseOut
        
        let bobSequence = SKAction.sequence([down, up])
        let bob = SKAction.repeatActionForever(bobSequence)
        
        removeAllActions()
        body.runAction(bob)
    }
    

}
