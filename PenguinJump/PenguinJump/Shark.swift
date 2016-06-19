//
//  Shark.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/10/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Shark: SKNode {
    
    var face = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_face")!))
    var mouth = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_mouth")!))
    var faceMask = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_face")!))
    var fin = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_fin")!))
    var wave = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_wave")!))
    var shadow = SKSpriteNode(texture: SKTexture(image: UIImage(named: "shark_shadow")!))
    var finMask = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeZero)
    
    var didBeginKill = false
    
    override init() {
        super.init()
        
        // Face node
        let faceCropNode = SKCropNode()
        faceCropNode.maskNode = faceMask
        faceCropNode.zPosition = 20
        
        mouth.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        mouth.position.y = -face.size.height / 2
        face.addChild(mouth)
        
        face.position.y -= face.size.height
        faceCropNode.addChild(face)
        addChild(faceCropNode)
        
        faceMask.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        faceMask.position.y -= shadow.size.height / 2 - wave.size.height
        
        face.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        face.position.y -= shadow.size.height / 2 - wave.size.height
        
        // Set up sprite nodes
        shadow.physicsBody = shadowPhysicsBody(shadow.texture!, category: SharkCategory)
        
        shadow.alpha = 0.1
        shadow.zPosition = -20
        wave.zPosition = 10
        
        fin.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        let offset = wave.size.height * 2
        wave.position.x += offset * 2
        wave.position.y += offset
        
        finMask.size = fin.size
        finMask.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        finMask.position.y += offset
        let finCropNode = SKCropNode()
        finCropNode.maskNode = finMask
        finCropNode.zPosition = 10
        
        finCropNode.addChild(fin)
        addChild(finCropNode)
        addChild(shadow)
        addChild(wave)
        
        // Begin actions
        bob()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bob() {
        let bobDepth = 2.0
        let bobDuration = 2.0
        let bobUp = SKAction.moveBy(CGVector(dx: 0, dy: bobDepth), duration: bobDuration)
        let bobDown = SKAction.moveBy(CGVector(dx: 0, dy: -bobDepth), duration: bobDuration)
        bobUp.timingMode = .EaseInEaseOut
        bobDown.timingMode = .EaseInEaseOut
        
        let bob = SKAction.repeatActionForever(SKAction.sequence([bobUp, bobDown]))
        finMask.runAction(bob)
        wave.runAction(bob)
        
        let counterBob = SKAction.repeatActionForever(SKAction.sequence([bobDown, bobUp]))
        fin.runAction(counterBob)
        shadow.runAction(counterBob)
    }
    
    func beginSwimming() {
        if (self.scene as! GameScene).gameData.soundEffectsOn as Bool {
            (scene as! GameScene).lurkingSound?.play()
        }
        
        position.x += 100
        swimLeft()
    }
    
    func swimLeft() {
        let swimLeft = SKAction.moveBy(CGVector(dx: -200, dy: 0), duration: 10.0)
        swimLeft.timingMode = .EaseInEaseOut
        
        self.xScale = 1
        runAction(swimLeft, completion: {
            self.swimRight()
        })
    }
    
    func swimRight() {
        let swimRight = SKAction.moveBy(CGVector(dx: 200, dy: 0), duration: 10.0)
        swimRight.timingMode = .EaseInEaseOut
        
        self.xScale = -1
        runAction(swimRight, completion: {
            self.swimLeft()
        })
    }
    
    func kill(blockAfterFaceUp block: (() -> ())?) {
        let bang = SKLabelNode(text: "!")
        bang.fontName = "Helvetica Neue Condensed Black"
        bang.fontSize = 18
        bang.fontColor = SKColor.whiteColor()
        bang.position.y += fin.size.height / 2
        addChild(bang)
        
        let reactionTime = SKAction.waitForDuration(0.2)
        let faceMoveUp = SKAction.moveBy(CGVector(dx: 0, dy: face.size.height), duration: 0.5)
        let faceMoveDown = SKAction.moveBy(CGVector(dx: 0, dy: -face.size.height), duration: 0.5)
        faceMoveUp.timingMode = .EaseOut
        faceMoveDown.timingMode = .EaseIn

        if (scene as! GameScene).gameData.soundEffectsOn as Bool {
            (scene as! GameScene).alertSound?.play()
        }
        
        removeAllActions()
        finMask.removeAllActions()
        wave.removeAllActions()
        fin.removeAllActions()
        shadow.removeAllActions()
        
        runAction(reactionTime, completion: {
            if (self.scene as! GameScene).gameData.soundEffectsOn as Bool {
                (self.scene as! GameScene).sharkSound?.play()
            }
            
            self.fin.runAction(faceMoveDown, completion: {
                self.wave.removeFromParent()
                self.fin.removeFromParent()
            })
            
            self.face.runAction(faceMoveUp, completion: {
                bang.removeFromParent()
                
                self.runAction(reactionTime, completion: {
                    block?()
                    
                    self.face.runAction(faceMoveDown)
                })
            })
        })
    }
    
}
