//
//  StageScene.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/25/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

// Overload minus operator to use on CGPoint
func -(first: CGPoint, second: CGPoint) -> CGPoint {
    let deltaX = first.x - second.x
    let deltaY = first.y - second.y
    return CGPoint(x: deltaX, y: deltaY)
}

class StageScene: SKScene {
    
    var stage : IcebergGenerator?
    let penguin = SKSpriteNode(imageNamed: "penguintemp")
    
    override func didMoveToView(view: SKView) {
        
        stage = IcebergGenerator(view: view)
        addChild(stage!)
        
        newGame()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: UITouch in touches {
            let positionInScene = touch.locationInNode(self)
            let touchedNodes = self.nodesAtPoint(positionInScene)
            for touchedNode in touchedNodes {
                if touchedNode.isKindOfClass(Iceberg) {
                    let berg = touchedNode as! Iceberg
                    berg.removeAllActions()
                    
                    stage?.updateCurrentBerg(berg)
                    berg.sink(7.0, completion: {
                        
                    })
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: UITouch in touches {
            let previousPosition = touch.previousLocationInView(view)
            let currentPosition = touch.locationInView(view)
            let delta = previousPosition - currentPosition
            
            let velocity = CGVector(dx: delta.x, dy: delta.y)
            stage!.scroll(velocity)
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        stage!.update()
    }
    
    func newGame() {
        let penguinPositionInScene = CGPoint(x: view!.frame.width * 0.5, y: view!.frame.height * 0.1)

        penguin.position = penguinPositionInScene
        penguin.zPosition = 1000
        addChild(penguin)
        
        stage!.newGame(convertPoint(penguinPositionInScene, toNode: stage!))
    }
}
