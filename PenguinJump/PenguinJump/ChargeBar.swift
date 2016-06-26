//
//  ChargeBar.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class ChargeBar: SKSpriteNode {
    
    var bar: SKSpriteNode!
    var barFlash: SKSpriteNode!
    var increment: CGFloat!
    var mask: SKSpriteNode!
    
    var flashing = false
    
    init(size:CGSize) {
        super.init(texture: nil, color: SKColor.clear(), size: CGSize(width: size.width, height: size.height / 3))
        anchorPoint = CGPoint(x: 0.0, y: 0.5)
        
        increment = size.width / 10
        
        mask = SKSpriteNode(color: SKColor.black(), size: CGSize(width: size.width, height: size.height))
        mask.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        
        let crop = SKCropNode()
        crop.maskNode = mask
        
        bar = SKSpriteNode(color: SKColor.black(), size: CGSize(width: size.width * 2, height: size.height / 3))
        bar.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        
        barFlash = SKSpriteNode(color: SKColor.white(), size: CGSize(width: size.width * 2, height: size.height / 3))
        barFlash.zPosition = 10
        barFlash.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        barFlash.alpha = 0.0
        bar.addChild(barFlash)
        
        crop.addChild(bar)
        
        addChild(crop)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flash(completion block: (() -> ())? ) {
        flashing = true
        let flashUp = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let flashDown = SKAction.fadeAlpha(to: 0.0, duration: 0.1)
        flashUp.timingMode = .easeOut
        flashDown.timingMode = .easeIn
        let wait = SKAction.wait(forDuration: 0.1)
        
        let flashSequence = SKAction.sequence([flashUp, wait, wait, flashDown, wait])
        
        barFlash.run(SKAction.repeat(flashSequence, count: 3), completion: {
            self.barFlash.alpha = 1.0
            self.flashing = false
            block?()
        })
    }
    
    func flashOnce() {
        flashing = true
        let flashUp = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let flashDown = SKAction.fadeAlpha(to: 0.0, duration: 0.1)
        flashUp.timingMode = .easeOut
        flashDown.timingMode = .easeIn

        let flashSequence = SKAction.sequence([flashUp, flashDown])
        barFlash.run(flashSequence, completion: {
            self.flashing = false
        })
    }
}
