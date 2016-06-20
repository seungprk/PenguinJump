//
//  SKNode+.swift: an SKNode extension that adds custom node functions.
//  PenguinJump
//
//  Created by Matthew Tso on 6/18/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    /**
        Creates a physics body from an SKTexture. Suitable for the coin, lightning, or shark objects.

        Defaults set:
        - allowsRotation = false
        - friction = 0
        - affectedByGravity = false
        - dynamic = false
    */
    func shadowPhysicsBody(shadowTexture: SKTexture, category: UInt32) -> SKPhysicsBody {

        let body = SKPhysicsBody(texture: shadowTexture, size: shadowTexture.size())
        body.allowsRotation = false
        body.friction = 0
        body.affectedByGravity = false
        body.dynamic = false
        body.categoryBitMask = category
        
        return body
    }
}
