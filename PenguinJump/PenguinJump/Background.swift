//
//  Background.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/1/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Background: SKSpriteNode {

    unowned let camera: SKCameraNode
    
    init(view: SKView, camera sceneCamera: SKCameraNode) {
        camera = sceneCamera
        super.init(texture: nil, color: UIColor.clearColor(), size: view.frame.size)
        position = view.center
        zPosition = -5000
        
        _ = NSTimer.scheduledTimerWithTimeInterval(7.0, target: self, selector: "randomSharkGenerate", userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func randomSharkGenerate() {
        if arc4random_uniform(4) > 0 {
            generateSilhouette()
        }
    }
    
    func generateSilhouette() {
        var fishFrames = [SKTexture]()
        for number in 1...4 {
            let texture = SKTexture(image: UIImage(named: "fish\(number)")!)
            
            fishFrames.append(texture)
        }
        let fishAnim = SKAction.animateWithTextures(fishFrames, timePerFrame: 0.6)
        
        let randomX = CGFloat(random()) % scene!.frame.width
        let sharkPosition = CGPoint(
            x: camera.position.x - scene!.frame.width + randomX,
            y: camera.position.y + scene!.frame.height / 2)
        
        let shark = SKSpriteNode(texture: fishFrames.first)
        shark.xScale = 2.0
        shark.yScale = 2.0
        shark.yScale = shark.yScale * -1
        shark.alpha = 0.3
        shark.position = sharkPosition
        addChild(shark)
        
        let swimDown = SKAction.moveBy(CGVector(dx: 0, dy: -scene!.frame.height * 2.0), duration: 70.0)
        shark.runAction(swimDown, completion: {
            shark.removeFromParent()
        })
        shark.runAction(SKAction.repeatActionForever(fishAnim))
    }
}
