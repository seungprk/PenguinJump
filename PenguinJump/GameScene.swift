//
//  GameScene.swift
//  PenguinJump
//
//  Created by Seung Park on 5/7/16.
//  Copyright (c) 2016 DeAnza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed:"Spaceship")
    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.blackColor()
        
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1 );
        player.xScale = 0.1
        player.yScale = 0.1
        player.zPosition = 100.0
        
        myLabel.text = "Start!";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(player)
        self.addChild(myLabel)
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock(addPlatform),
            SKAction.waitForDuration(1.0)
            ])
        ))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func addPlatform() {
        let platform = SKSpriteNode(imageNamed: "Spaceship")
        
        let actualX = random(min: platform.size.width, max: size.width - platform.size.width)
        platform.position = CGPoint(x: actualX, y: size.height + platform.size.height/2)
        
        addChild(platform)

        let actualDuration = 3.0//random(min: CGFloat(2.0), max: CGFloat(4.0))

        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: -platform.size.height/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        platform.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
