//
//  Lightning.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/26/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Lightning: SKSpriteNode {
    
    var cloud: SKSpriteNode!
    var shadow: SKSpriteNode!
    
    let lightningTexture = SKTexture(imageNamed: "lightning")
    
    init(view: SKView) {
        super.init(texture: <#T##SKTexture?#>, color: <#T##UIColor#>, size: <#T##CGSize#>)
        let lightningAtlas = SKTextureAtlas(named: "lightning")
        var lightningFrames = [SKTexture]()
        for number in 1...3 {
            let texture = SKTexture(imageNamed: "lightning\(number)")
            lightningFrames.append(texture)
        }
        
        let lightning = SKSpriteNode(texture: lightningFrames.first)
//        lightning.position = view.center
        lightning.zPosition = 3000
        let lightningAnim = SKAction.animateWithTextures(lightningFrames, timePerFrame: 0.2)
        lightning.runAction(lightningAnim)
        //
        addChild(lightning)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
