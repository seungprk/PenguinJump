//
//  MenuScene.swift
//  PenguinJump
//
//  Created by Seung Park on 5/8/16.
//  Copyright © 2016 DeAnza. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    let titleLabel = SKLabelNode(fontNamed:"Chalkduster")
    let newGameLabel = SKLabelNode(fontNamed:"Chalkduster")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        titleLabel.text = "Penguin Jump"
        titleLabel.fontSize = 45
        titleLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        newGameLabel.text = "New Game"
        newGameLabel.fontSize = 22
        newGameLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - titleLabel.frame.height)
        
        self.addChild(titleLabel)
        self.addChild(newGameLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.locationInNode(self)
            let node = self.nodeAtPoint(pos)
            
            if node == newGameLabel {
                if let view = view {
                    let scene = GameScene(fileNamed:"GameScene")
                    scene!.scaleMode = .AspectFill
                    view.presentScene(scene)
                }
            }
        }
        

        
    }
}
