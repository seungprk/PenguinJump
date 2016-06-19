//
//  AboutScene.swift
//  PenguinJump
//
//  Created by Seung Park on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class AboutScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.whiteColor()
        
        let logo = SKSpriteNode(texture: SKTexture(image: UIImage(named: "logo")!))
        logo.name = "logo"
        logo.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5 + logo.frame.height - 25)
        addChild(logo)
        
        let teamName = SKLabelNode(text: "TEAM PENGUIN")
        teamName.fontName = "Helvetica Neue Condensed Black"
        teamName.fontSize = 24
        teamName.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        teamName.fontColor = SKColor.blackColor()
        addChild(teamName)
        
        let memberOne = SKLabelNode(text: "David Park")
        memberOne.fontName = "Helvetica Neue"
        memberOne.fontSize = 19
        memberOne.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5 - 50)
        memberOne.fontColor = SKColor.blackColor()
        addChild(memberOne)
        
        let memberOneDescript = SKLabelNode(text: "@seungprk")
        memberOneDescript.fontName = "Helvetica Neue"
        memberOneDescript.fontSize = 19
        memberOneDescript.position = memberOne.position
        memberOneDescript.position.y -= memberOne.frame.height + 5
        memberOneDescript.fontColor = SKColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1.0)
        addChild(memberOneDescript)
        
        let plusSign = SKLabelNode(text: "+")
        plusSign.fontName = "Helvetica Neue"
        plusSign.fontSize = 19
        plusSign.position = memberOneDescript.position
        plusSign.position.y -= 25
        plusSign.fontColor = SKColor.blackColor()
        addChild(plusSign)
        
        let memberTwo = SKLabelNode(text: "Matthew Tso")
        memberTwo.fontName = "Helvetica Neue"
        memberTwo.fontSize = 19
        memberTwo.position = plusSign.position
        memberTwo.position.y -= 25
        memberTwo.fontColor = SKColor.blackColor()
        addChild(memberTwo)
        
        let memberTwoDescript = SKLabelNode(text: "@matthewtso")
        memberTwoDescript.fontName = "Helvetica Neue"
        memberTwoDescript.fontSize = 19
        memberTwoDescript.position = memberTwo.position
        memberTwoDescript.position.y -= memberTwo.frame.height + 5
        memberTwoDescript.fontColor = SKColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1.0)
        addChild(memberTwoDescript)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let gameScene = GameScene(size: self.size)
        let transition = SKTransition.pushWithDirection(.Up, duration: 0.5)
        gameScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(gameScene, transition: transition)
    }
}
