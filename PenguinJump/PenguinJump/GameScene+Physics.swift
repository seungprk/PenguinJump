//
//  GameScene+Physics.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/17/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import Foundation
import SpriteKit

let Passthrough       : UInt32 = 0x0
let IcebergCategory   : UInt32 = 0x1 << 0
let PenguinCategory   : UInt32 = 0x1 << 1
let LightningCategory : UInt32 = 0x1 << 2
let SharkCategory     : UInt32 = 0x1 << 3
let CoinCategory      : UInt32 = 0x1 << 4

extension GameScene: SKPhysicsContactDelegate {
    
    /// Sets up the physics world.
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        let bodies = (first: firstBody.categoryBitMask, second: secondBody.categoryBitMask)
        
        switch bodies {
            
        case (IcebergCategory, PenguinCategory):
            print("Penguin begins contact with an iceberg")
            penguin.shadow.fillColor = SKColor.redColor()
            penguin.shadow.alpha = 0.8
            
            penguin.onBerg = true
            
        default:
            print("Detected a contact between \(bodies.first) and \(bodies.second).")
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        var bodies: (first: UInt32, second: UInt32)
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodies.first = contact.bodyA.categoryBitMask
            bodies.second = contact.bodyB.categoryBitMask
        } else {
            bodies.first = contact.bodyB.categoryBitMask
            bodies.second = contact.bodyA.categoryBitMask
        }
        
        switch bodies {
            
        case (IcebergCategory, PenguinCategory):
            print("Penguin ends contact with an iceberg")
            penguin.shadow.fillColor = SKColor.blackColor()
            penguin.shadow.alpha = 0.2
            
            penguin.onBerg = false
            
        default:
            print("Detected a contact between \(bodies.first) and \(bodies.second).")
        }

    }
    
}
