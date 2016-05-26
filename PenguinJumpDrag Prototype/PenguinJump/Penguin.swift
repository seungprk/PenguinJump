//
//  Penguin.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/25/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Penguin: SKSpriteNode {
    
    let penguin = SKSpriteNode(imageNamed: "penguintemp")
    var penguinShadow: SKShapeNode!
    
    let targetReticle = SKSpriteNode(imageNamed: "targetcircle")
    let targetDot1 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot2 = SKSpriteNode(imageNamed: "targetdot")
    let targetDot3 = SKSpriteNode(imageNamed: "targetdot")

    var targeting = false
    var playerTouched = false

}
