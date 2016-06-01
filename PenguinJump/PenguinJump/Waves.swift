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
        
        highestNodeY = -10000.0
        lowestNodeY = CGFloat.max
        leftmostNodeX = CGFloat.max
        rightmostNodeX = -10000.0
        updateFurthestNodes()
        
        for _ in 0...rowsInView {
            update()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        updateFurthestNodes()
        if highestNodeY < camera.position.y + gameScene!.frame.height / 6 {
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
        if leftmostNodeX > camera.position.x - gameScene!.frame.width  {
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
        
    }
    
    func updateFurthestNodes() {
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
        waveNode.size = CGSize(width: nodeWidth, height: 1)
        
        return waveNode
    }
    
}
