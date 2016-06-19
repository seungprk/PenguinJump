//
//  Raindrop.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Raindrop: SKNode {

    let raindrop = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 1, height: 80))
    let ripple = SKSpriteNode(texture: SKTexture(image: UIImage(named: "white_circle")!))
    
    override init() {
        super.init()
        name = "raindrop"
        
        raindrop.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        ripple.setScale(0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        Drops the raindrop at a point. Make sure to call this *after* it is added as a child to a scene because it uses the containing scene's height to calculate where to place the raindrop at the start of the animation.
        - parameter point: The point to drop at.
        - parameter windSpeed: The current windspeed determined by the storm intensity. The raindrop animates to the left if this value is negative and to the right if positive.
    */
    func drop(point: CGPoint, windSpeed: Double) {
        
        if let scene = scene {
            
            position = point
            
            let dropDuration = 2.0
            let beginningDistance = Double(scene.size.height)
            let dropRate = beginningDistance / dropDuration
            
            let angle = asin(windSpeed / dropRate)
            let startingX = sin(-angle) * beginningDistance
            let startingY = cos(-angle) * beginningDistance
            
            raindrop.zRotation = CGFloat(angle)
            raindrop.position = CGPoint(x: startingX, y: startingY)
            
            let drop = SKAction.moveTo(CGPointZero, duration: dropDuration - 0.5)
            let scaleToZero = SKAction.scaleYTo(0, duration: 0.5)
            let rippleScale = SKAction.scaleTo(1, duration: 0.5)
            let rippleFade = SKAction.fadeAlphaTo(0, duration: 0.5)
            
            drop.timingMode = .EaseIn
            scaleToZero.timingMode = .EaseOut
            rippleScale.timingMode = .EaseOut
            rippleFade.timingMode = .EaseIn
            
            addChild(raindrop)
            raindrop.runAction(drop, completion: {
                self.raindrop.runAction(scaleToZero, completion: {
                    self.raindrop.removeFromParent()
                })
                
                self.addChild(self.ripple)
                self.ripple.runAction(rippleScale)
                self.ripple.runAction(rippleFade, completion: {
                    self.removeFromParent()
                })
            })
        }
    }
    
}
