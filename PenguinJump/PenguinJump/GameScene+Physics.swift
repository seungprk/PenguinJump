//
//  GameScene+Physics.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/17/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

/// Collision Bitmask set to 0x0 to pass through all objects.
let Passthrough       : UInt32 = 0x0

/// Bitmask that sets all bits on.
let All               : UInt32 = 0xFFFFFFFF

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
            penguin.onBerg = true
        
        case (PenguinCategory, LightningCategory):
            penguin.contactingLightning = true
        
        case (PenguinCategory, SharkCategory):
            let shark = secondBody.node?.parent as! Shark
            
            if !shark.didBeginKill {
                shark.didBeginKill = true

                let deathMove = SKAction.moveTo(convertPoint(CGPoint(x: shark.position.x, y: shark.position.y + penguin.size.height), fromNode: sharkLayer!), duration: 0.1)
        
                penguin.removeAllActions()
                penguin.runAction(deathMove)
                
                shark.kill(blockAfterFaceUp: {
                    self.gameOver = true
                })
            }
            
        case (PenguinCategory, CoinCategory):
            let coin = secondBody.node?.parent as! Coin

            if !coin.collected {
                incrementTotalCoins()
                
                intScore += stormMode ? 4 : 2
                
                coin.collected = true
                
                let scoreBumpUp = SKAction.scaleTo(1.2, duration: 0.1)
                let scoreBumpDown = SKAction.scaleTo(1.0, duration: 0.1)
                scoreLabel.runAction(SKAction.sequence([scoreBumpUp, scoreBumpDown]))
                
                coinSound?.currentTime = 0
                if gameData.soundEffectsOn == true { coinSound?.play() }
                
                let rise = SKAction.moveBy(CGVector(dx: 0, dy: coin.body.size.height), duration: 0.5)
                rise.timingMode = .EaseOut
                
                coin.body.runAction(rise, completion: {
                    coin.generateCoinParticles(self.cam)
                    
                    let path = NSBundle.mainBundle().pathForResource("CoinBurst", ofType: "sks")
                    if let coinBurst = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode? {
                        coinBurst.zPosition = 240000
                        coinBurst.numParticlesToEmit = 25
                        coinBurst.targetNode = self.scene
                        
                        let coinBurstEffectNode = SKEffectNode()
                        coinBurstEffectNode.addChild(coinBurst)
                        coinBurstEffectNode.zPosition = 240000
                        
                        coinBurstEffectNode.position = self.convertPoint(coin.body.position, fromNode: coin)
                        coinBurstEffectNode.blendMode = .Replace
                        
                        self.addChild(coinBurstEffectNode)
                    }
                    
                    if self.gameData.soundEffectsOn as Bool {
                        self.burstSound?.play()
                    }
                    
                    coin.body.removeFromParent()
                    coin.shadow.removeFromParent()
                    self.incrementBarWithCoinParticles(coin)
                })
            }
            
            
        default:
            break
            
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
            penguin.onBerg = false
            
        case (PenguinCategory, LightningCategory):
            penguin.contactingLightning = false
            
        default:
            break
            
        }
    }
    
}
