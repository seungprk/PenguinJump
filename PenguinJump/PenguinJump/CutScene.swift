//
//  CutScene.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/12/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class CutScene: SKScene {
    
    let image = SKSpriteNode(imageNamed: "cutscene")
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0/255, green: 151/255, blue: 255/255, alpha: 1.0)
        
        image.alpha = 0
        image.position = view.center
        image.position.x += view.frame.width
        addChild(image)
        
        let fadeIn = SKAction.fadeAlphaTo(1, duration: 1)
        let moveInFromRight = SKAction.moveTo(CGPoint(x: view.center.x + 5, y: view.center.y), duration: 1)
        fadeIn.timingMode = .EaseOut
        moveInFromRight.timingMode = .EaseOut
        
        let moveSlowly = SKAction.moveBy(CGVector(dx: -10, dy: 0), duration: 7)

        image.runAction(fadeIn)
        image.runAction(moveInFromRight, completion: {
            self.image.runAction(moveSlowly, completion: {
                self.presentGameScene()
            })
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        presentGameScene()
    }
    
    func presentGameScene() {
        let fadeOut = SKAction.fadeAlphaTo(0, duration: 0.5)
        let moveOutToLeft = SKAction.moveTo(CGPoint(x: view!.center.x - view!.frame.width, y: view!.center.y), duration: 0.5)
        fadeOut.timingMode = .EaseIn
        moveOutToLeft.timingMode = .EaseIn
        
        image.runAction(fadeOut)
        image.runAction(moveOutToLeft, completion: {
            // Set Up and Present Main Game Scene
            let gameScene = GameScene(size: self.size)
            
            let transition = SKTransition.moveInWithDirection(.Right, duration: 0.5)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            
            if let view = self.view {
                view.presentScene(gameScene, transition: transition)
            }
        })
    }
}
