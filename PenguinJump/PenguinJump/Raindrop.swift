//
//  Raindrop.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Raindrop: SKNode {

    var raindrop: SKSpriteNode!
    var ripple: SKSpriteNode!
    
    override init() {
        super.init()
        name = "raindrop"

        raindrop = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 1, height: 80))
        ripple = SKSpriteNode(imageNamed: "white_circle")
        
        raindrop.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        ripple.xScale = 0
        ripple.yScale = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func testRotation(point: CGPoint, windSpeed: Double) {
        position = point
        
        let beginningDistance = 20.0
        let dropDuration = 1.0
        let dropRate = beginningDistance / dropDuration

        let angle = -asin(windSpeed / 500)
        
        print(raindrop.zRotation)
        
        raindrop.zRotation = CGFloat(angle)
//        print(angle)
        
        let startingX = sin(-angle) * beginningDistance
        let startingY = cos(-angle) * beginningDistance
//        let xFromCenter = sin(randomAngleInSection) * radius
//        let yFromCenter = cos(randomAngleInSection) * radius

        raindrop.position = CGPoint(x: startingX, y: startingY)
        
        addChild(raindrop)
        
        ripple.xScale = 0.25
        ripple.yScale = 0.25
        addChild(ripple)
    }
    
    func drop(point: CGPoint, windSpeed: Double, scene: SKScene) {
        position = point
        
        let dropDuration = 2.0
        let beginningDistance = Double(scene.size.height)// 2000.0
        let dropRate = beginningDistance / dropDuration
        
//        let startPositionX = windSpeed
        
        
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
