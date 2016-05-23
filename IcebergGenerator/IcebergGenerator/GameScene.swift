//
//  GameScene.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/22/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var testBerg: Iceberg?
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.6, green: 0.9, blue: 1, alpha: 1)
        
        testBerg = Iceberg(size: CGSize(width: 100.0, height: 100.0))
        testBerg!.position = view.center //CGPoint(x: view.center.x, y: view.center.y / 2)
        addChild(testBerg!)
        
        for count in 1 ... 3{
            let berg = Iceberg(size: CGSize(width: 100.0, height: 100.0))
            berg.position = CGPoint(x: view.center.x, y: view.center.y + 100 * CGFloat(count) )
            insertChild(berg, atIndex: 0)
        }

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for _ in touches {
            testBerg!.runSinkAction()
        }
    }
    
}
