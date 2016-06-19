//
//  Lightning.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/26/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Lightning: SKNode {
    
    let strikeDuration = 1.0
    
    var cloud: SKSpriteNode!
    var cloudOverlay: SKSpriteNode!
    var shadow: SKSpriteNode!
    var shadowOverlay: SKSpriteNode!
    
    var lightning: SKEmitterNode!
    var lightningCropNode: SKCropNode!
    
    var activated = false
    var didBeginStriking = false
    
    init(view: SKView) {
        super.init()
        
        name = "lightning"
        let cloudHeight = view.frame.height / 4
        
        cloud = SKSpriteNode(texture: SKTexture(image: UIImage(named: "black_cloud")!))
        cloudOverlay = SKSpriteNode(texture: SKTexture(image: UIImage(named: "blue_cloud")!))
        shadow = SKSpriteNode(texture: SKTexture(image: UIImage(named: "black_ellipse_5040")!))
        shadowOverlay = SKSpriteNode(texture: SKTexture(image: UIImage(named: "blue_ellipse_5040")!))
        
        shadow.alpha = 0.1
        shadow.physicsBody = shadowPhysicsBody(shadow.texture!, category: LightningCategory)
        
        if let lightning = SKEmitterNode(fileNamed: "Lightning.sks") {
            self.lightning = lightning
            
            let trashNode = SKSpriteNode(color: SKColor.clearColor(), size: CGSize(width: 500, height: 3000))
            trashNode.addChild(self.lightning)
            
            lightningCropNode = SKCropNode()
            let lightningMask = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: cloud.size.width, height: cloudHeight - cloud.size.height / 2 + 3))
            lightningMask.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            lightning.particleAction = SKAction.moveTo(CGPointZero, duration: 0.1)
            
            lightningCropNode.maskNode = lightningMask
            lightningMask.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            lightningCropNode.addChild(trashNode)
        }
        
        cloud.position.y += cloudHeight
        cloudOverlay.position.y += cloudHeight
        
        cloudOverlay.alpha = 0.0
        shadowOverlay.alpha = 0.0
        
        shadowOverlay.zPosition = 10
        
        addChild(cloudOverlay)
        addChild(shadowOverlay)

        addChild(shadow)
        addChild(cloud)
        
        self.addChild(self.lightningCropNode)
        lightningCropNode.alpha = 0.0

        cloud.zPosition = 30000
        cloudOverlay.zPosition = 30001
        lightningCropNode.zPosition = 500
        lightning.zPosition = 500
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginStrike() {
        if (scene as! GameScene).gameData.soundEffectsOn as Bool {
            (scene as! GameScene).powerUpSound?.play()
        }
        
        let wait = SKAction.waitForDuration(strikeDuration * 2)
        
        let fadeGrow = SKAction.fadeAlphaTo(0.5, duration: 1.0)

        shadowOverlay.runAction(fadeGrow, completion: {
            self.strike()
            
            self.runAction(wait, completion: {
                self.strike()
                
                self.runAction(wait, completion: {
                    self.strike()
                    
                    self.runAction(wait, completion: {
                        self.strike()
                        
                        self.runAction(wait, completion: {
                            self.strike()
                            
                            self.runAction(wait, completion: {
                                self.disappear()
                            })
                        })
                    })
                })
            })
        })
        
    }
    
    func strike() {
        if (scene as! GameScene).gameData.soundEffectsOn as Bool {
            (scene as! GameScene).zapSound?.play()
        }
        
        shadowOverlay.alpha = 1.0
        cloudOverlay.alpha = 1.0
        self.activated = true
        self.lightningCropNode.alpha = 1.0
        self.lightning.numParticlesToEmit = 1000
        
        let wait = SKAction.waitForDuration(strikeDuration)
        self.runAction(wait, completion: {
            self.shadowOverlay.alpha = 0.0
            self.cloudOverlay.alpha = 0.0
            self.activated = false
            self.lightningCropNode.alpha = 0.0
        })
    
    }
    
    func disappear() {
        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 1.0)
        
        runAction(fadeOut, completion: {
            self.removeFromParent()
        })
    }
    
}
