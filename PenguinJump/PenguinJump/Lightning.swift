//
//  Lightning.swift
//  PenguinJump
//
//  Created by Matthew Tso on 5/26/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Lightning: SKNode {
    
    let strikeDuration = 5.0
    
    var cloud: SKSpriteNode!
    var cloudOverlay: SKSpriteNode!
    var shadow: SKSpriteNode!
    var shadowOverlay: SKSpriteNode!
    
    var lightning: SKEmitterNode!
    var lightningEffectNode: SKEffectNode!
    var lightningCropNode: SKCropNode!
    
    var activated = false
    
//    let lightningTexture = SKTexture(imageNamed: "lightning")
    
    init(view: SKView) {
        super.init()
        
        name = "lightning"
        let cloudHeight = view.frame.height / 4
        
        cloud = SKSpriteNode(imageNamed: "black_cloud")
        cloudOverlay = SKSpriteNode(imageNamed: "blue_cloud")
        shadow = SKSpriteNode(imageNamed: "black_ellipse_5040")
        shadowOverlay = SKSpriteNode(imageNamed: "blue_ellipse_5040")
        
        shadow.alpha = 0.1
        
        let path = NSBundle.mainBundle().pathForResource("Lightning", ofType: "sks")
        lightning = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
        lightning.position.y += cloudHeight / 2
        
        lightningEffectNode = SKEffectNode()
        
        lightningCropNode = SKCropNode()
        let lightningMask = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: cloud.size.width, height: cloudHeight))
        lightningMask.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        lightning.particleAction = SKAction.moveTo(CGPointZero, duration: 0.1)
        
        lightningCropNode.maskNode = lightningMask
        lightningMask.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        lightningMask.position.y -= cloudHeight * 0.1
        
//        let lightningTarget = SKNode()
        
        
//        lightningEffectNode.addChild(lightning)
        lightningCropNode.addChild(lightning)
//        lightningCropNode.addChild(lightningTarget)
//        lightningCropNode.addChild(lightningEffectNode)
        
        cloud.position.y += cloudHeight
        cloudOverlay.position.y += cloudHeight
        
        
        cloudOverlay.alpha = 0.0
        shadowOverlay.alpha = 0.0
        
        cloudOverlay.zPosition = 10
        shadowOverlay.zPosition = 10
        
        addChild(cloudOverlay)
        addChild(shadowOverlay)

        addChild(shadow)
        addChild(cloud)
        
        self.addChild(self.lightningCropNode)
        lightningCropNode.alpha = 0.0
//        addChild(lightning)
//        addChild(lightningCropNode)
        
//        lightning.numParticlesToEmit = 1000
//        lightning.targetNode = lightningTarget
//        lightning.targetNode = lightningEffectNode
        beginStrike()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginStrike() {
        
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
        
        let wait = SKAction.waitForDuration(strikeDuration)
        
        shadowOverlay.alpha = 1.0
        cloudOverlay.alpha = 1.0
        self.activated = true
        self.lightningCropNode.alpha = 1.0
//            self.addChild(self.lightningCropNode)
        self.lightning.numParticlesToEmit = 1000
        
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
