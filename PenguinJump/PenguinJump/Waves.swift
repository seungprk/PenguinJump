//
//  Waves.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/1/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Waves: SKSpriteNode {

    let waveColor = SKColor(red: 0.8, green: 0.91, blue: 0.95, alpha: 1.0)
    let rowsInView = 20
    let columnsInView = 20
    
    var camera: SKCameraNode!
    var gameScene: GameScene!
    
    var totalRows = 0
    var totalColumns = 0
    var waveGap: CGFloat!
    var nodeWidth: CGFloat!
    
    var highestNodeY: CGFloat!
    var lowestNodeY: CGFloat!
    var leftmostNodeX: CGFloat!
    var rightmostNodeX: CGFloat!
    
    var animationBegan = false
    var stormMode = false
    
    init(camera: SKCameraNode, gameScene: GameScene) {
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeZero)
        
        self.camera = camera
        self.gameScene = gameScene
        
        waveGap = gameScene.frame.height / CGFloat(rowsInView)
        nodeWidth = gameScene.frame.width / CGFloat(columnsInView)

        let firstWaveNode = SKSpriteNode()
        firstWaveNode.color = waveColor
        firstWaveNode.size = CGSize(width: nodeWidth, height: 1)
        firstWaveNode.position = CGPointZero
        firstWaveNode.position.y = gameScene.frame.origin.y - gameScene.frame.height / 2
        addChild(firstWaveNode)

        totalRows = 1
        totalColumns = 1
        
        updateFurthestNodes()
        
        for _ in 0...rowsInView {
            update()
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        // Add wave nodes to fill screen
        updateFurthestNodes()
        if highestNodeY < camera.position.y + gameScene.frame.height / 6 {
            totalRows += 1
            for cell in 0..<totalColumns {
                let waveNode = newWaveNode()
                waveNode.position = CGPoint(
                    x: leftmostNodeX + nodeWidth * CGFloat(cell),
                    y: highestNodeY + waveGap)
                
                addChild(waveNode)
            }
        }
        
        updateFurthestNodes()
        if leftmostNodeX > camera.position.x - gameScene.frame.width  {
            totalColumns += 1
            for cell in 0..<totalRows {
                let waveNode = newWaveNode()
                waveNode.position = CGPoint(
                    x: leftmostNodeX - nodeWidth,
                    y: highestNodeY - waveGap * CGFloat(cell))
                
                addChild(waveNode)
            }
        }
        
        updateFurthestNodes()
        if rightmostNodeX < camera.position.x {
            totalColumns += 1
            for cell in 0..<totalRows {
                let waveNode = newWaveNode()
                waveNode.position = CGPoint(
                    x: rightmostNodeX + nodeWidth,
                    y: highestNodeY - waveGap * CGFloat(cell))
                
                addChild(waveNode)
            }
        }
        
        // Delete wave nodes that are no longer visible
        updateFurthestNodes()
        while lowestNodeY < camera.position.y - gameScene.frame.height {
            for waveNode in children {
                if waveNode.position.y < lowestNodeY + waveGap / 2 {
                    waveNode.removeFromParent()
                }
                
            }
            totalRows -= 1
            updateFurthestNodes()
        }
        
        updateFurthestNodes()
        while rightmostNodeX > camera.position.x + nodeWidth {
            for waveNode in children {
                if waveNode.position.x > rightmostNodeX - nodeWidth / 2 {
                    waveNode.removeFromParent()
                }
                
            }
            totalColumns -= 1
            updateFurthestNodes()
        }
        
        updateFurthestNodes()
        while leftmostNodeX < camera.position.x - gameScene.frame.width - nodeWidth {
            for waveNode in children {
                if waveNode.position.x < leftmostNodeX + nodeWidth / 2 {
                    waveNode.removeFromParent()
                }
                
            }
            totalColumns -= 1
            updateFurthestNodes()
        }
    }
    
    func updateFurthestNodes() {
        // Reset values
        highestNodeY = -10000.0
        lowestNodeY = CGFloat.max
        leftmostNodeX = CGFloat.max
        rightmostNodeX = camera.position.x - gameScene.frame.width

        for waveNode in children {
            if highestNodeY < waveNode.position.y {
                highestNodeY = waveNode.position.y
            }
            if lowestNodeY > waveNode.position.y {
                lowestNodeY = waveNode.position.y
            }
            
            if leftmostNodeX > waveNode.position.x {
                leftmostNodeX = waveNode.position.x
            }
            if rightmostNodeX < waveNode.position.x {
                rightmostNodeX = waveNode.position.x
            }
        }
        
    }
    
    func newWaveNode() -> SKSpriteNode {
        let waveNode = SKSpriteNode()
        waveNode.color = waveColor
        waveNode.size = CGSize(width: nodeWidth, height: 1.0)
        
        return waveNode
    }
    
    func bob() {
        let bobDepth = stormMode ? 6.0 : 4.0
        let bobDuration = stormMode ? 1.8 : 3.0
        
        let fadeOut = SKAction.fadeAlphaTo(0.3, duration: bobDuration * 0.25)
        let fadeIn = SKAction.fadeAlphaTo(0.7, duration: bobDuration * 0.25)
        fadeOut.timingMode = .EaseOut
        fadeIn.timingMode = .EaseIn
        let wait = SKAction.waitForDuration(bobDuration * 0.5)
        let fadeSequence = SKAction.sequence([fadeOut, wait, fadeIn])
        
        let down = SKAction.moveBy(CGVector(dx: 0.0, dy: -bobDepth), duration: bobDuration * 0.5)
        let up = SKAction.moveBy(CGVector(dx: 0.0, dy: bobDepth), duration: bobDuration * 0.5)
        down.timingMode = .EaseInEaseOut
        up.timingMode = .EaseInEaseOut
        let bobSequence = SKAction.sequence([down, up])
        
        removeAllActions()
        runAction(SKAction.repeatActionForever(SKAction.group([fadeSequence, bobSequence])))
    }
    
}
