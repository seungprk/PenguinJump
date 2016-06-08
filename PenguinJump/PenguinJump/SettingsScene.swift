//
//  SettingsScene.swift
//  PenguinJump
//
//  Created by Seung Park on 6/6/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class SettingsScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.name = "logo"
        logo.position = CGPoint(x: size.width/2, y: size.height/2)
        logo.zPosition = 0
        addChild(logo)
        
        let musicLabel = SKLabelNode(text: "Music")
        musicLabel.color = UIColor.whiteColor()
        musicLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        musicLabel.zPosition = 100
        addChild(musicLabel)
        
        let soundsLabel = SKLabelNode(text: "Sounds")
        soundsLabel.color = UIColor.whiteColor()
        soundsLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        soundsLabel.zPosition = 100
        addChild(soundsLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if touchedNode.name == "logo" {
                    let gameScene = GameScene(size: self.size)
                    let transition = SKTransition.pushWithDirection(.Up, duration: 0.5)
                    gameScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(gameScene, transition: transition)
                }
            }
        }
    }
}
