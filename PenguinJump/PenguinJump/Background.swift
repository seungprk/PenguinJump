//
//  Background.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/1/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Background: SKSpriteNode {

    var camera: SKCameraNode!
    
    init(view: SKView, camera sceneCamera: SKCameraNode) {
        super.init(texture: nil, color: UIColor.clearColor(), size: view.frame.size)
        position = view.center
        camera = sceneCamera
        zPosition = -5000
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func generateSilhouette() {
        let sharkPosition = CGPoint(x: camera.position.x - scene!.frame.width / 2, y: camera.position.y + scene!.frame.height / 2)
        
        let shark = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: 50, height: 50))
        shark.alpha = 0.3
        
        let circle = SKShapeNode(circleOfRadius: 25)
        circle.fillColor = SKColor.blackColor()
        circle.strokeColor = SKColor.clearColor()
        shark.addChild(circle)
        
        shark.position = sharkPosition
        addChild(shark)
        
        let swimDown = SKAction.moveBy(CGVector(dx: 0, dy: -scene!.frame.height * 2.0), duration: 30.0)
        shark.runAction(swimDown, completion: {
            shark.removeFromParent()
        })
    }
}
