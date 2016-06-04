//
//  GameScene.swift
//  TexturedIceberg
//
//  Created by Matthew Tso on 6/2/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var stage: IcebergGenerator!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        stage = IcebergGenerator(view: view)
        stage.position = view.center
        addChild(stage)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
//            stage.generateBerg()
            for child in stage.children {
                let berg = child as! Iceberg
                berg.ripple()
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
