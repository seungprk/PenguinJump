//
//  Stage.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/24/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

enum pathingMode {
    case forking
    case straight
}

class IcebergGenerator: SKSpriteNode {
    
    var camera:SKCameraNode!
    
    var bergSize:CGFloat = 150.0
    let maxBergSize:CGFloat = 150.0
    let minBergSize:CGFloat = 100.0
    var gapDistance:CGFloat = 250.0
    var forkingFrequency = 7
    var shouldMove = true
    
    var mode = pathingMode.straight
    
    var currentBerg: Iceberg?
    var firstBergOfFork: Iceberg?
    var highestBerg: Iceberg?
    var normalBergCount = 0
    
    var highestLeftBerg: Iceberg?
    var highestRightBerg: Iceberg?
    
    init(view: SKView, camera sceneCamera: SKCameraNode) {
        super.init(texture: nil, color: UIColor.clearColor(), size: view.frame.size)
        position = view.center
        camera = sceneCamera
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func newGame(startPoint: CGPoint) {
        removeAllChildren()
        
        let firstBergSize = CGSize(width: scene!.view!.frame.width, height: scene!.view!.frame.width)
        let firstBerg = Iceberg(size: firstBergSize)
        firstBerg.name = "firstBerg"
        firstBerg.position = startPoint
        firstBerg.position.y -= firstBerg.frame.height * 0.38
        
        let secondBerg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
        secondBerg.position = startPoint
        secondBerg.position.y += 300
        
        insertChild(firstBerg, atIndex: 0)
        insertChild(secondBerg, atIndex: 0)
        
        highestBerg = secondBerg
        
        generateBerg()
    }
    
    func update() {
        let currentDifficulty = CGFloat((scene as! GameScene).difficulty)
        bergSize = maxBergSize - (maxBergSize - minBergSize) * currentDifficulty
        
        clearBerg()
        generateBerg()
    }
    
    func shouldGenerate() -> Bool {
        if let highestBerg = highestBerg {
            
            if highestBerg.position.y < camera.position.y {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func clearBerg() {
        // If top edge of child's frame is less than bottom edge of view's frame, remove child.
        for child in children {
            if child.name == "firstBerg" {
                if child.position.y + child.frame.height < camera.position.y - scene!.view!.frame.height {
                    child.removeFromParent()
                }
            } else if child.position.y < camera.position.y - scene!.view!.frame.height - 100 {
                child.removeFromParent()
            }
            
            
        }
    }
    func updateCurrentBerg(berg: Iceberg) {
        currentBerg = berg
        if berg.name == "leftBerg" {
            highestBerg = highestLeftBerg
        } else if berg.name == "rightBerg" {
            highestBerg = highestRightBerg
        }
    }
    func generateBerg() {
        if mode == .forking {
            firstBergOfFork = highestBerg
            
            highestLeftBerg = firstBergOfFork
            highestRightBerg = firstBergOfFork
            
            for _ in 1...3 {
                let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
                berg.name = "leftBerg"
                
                let deltaX = CGFloat(random()) % frame.width * 0.15 + frame.width * 0.2
                
                let xPosition = highestLeftBerg!.position.x - deltaX
                let yPosition = highestLeftBerg!.position.y + gapDistance
                
                berg.position = CGPoint(x: xPosition, y: yPosition)
                
                highestLeftBerg = berg
                
                insertChild(berg, atIndex: 0)
            }
            for _ in 1...3 {
                let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
                berg.name = "rightBerg"
                
                let deltaX = CGFloat(random()) % frame.width * 0.15 + frame.width * 0.2
                
                let xPosition = highestRightBerg!.position.x + deltaX
                let yPosition = highestRightBerg!.position.y + gapDistance
                
                berg.position = CGPoint(x: xPosition, y: yPosition)
                
                highestRightBerg = berg
                
                insertChild(berg, atIndex: 0)
            }
            
            // doesn't really matter since they are equal
            // but by default the path will continue on the right
            highestBerg = highestLeftBerg?.position.y > highestRightBerg?.position.y ? highestLeftBerg : highestRightBerg
            
            mode = .straight
        } else {
            while shouldGenerate() {
                let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
                
//                let deltaX = CGFloat(random()) % frame.width * 0.8 - frame.width * 0.4
                
                let xPosition = highestBerg!.position.x // + deltaX * 0.2
                let yPosition = highestBerg!.position.y + gapDistance
                
                berg.position = CGPoint(x: xPosition, y: yPosition)
                
                highestBerg = berg
                
                if let currentBerg = currentBerg {
                    if currentBerg.name == "leftBerg" {
                        highestLeftBerg = berg
                        highestBerg = highestLeftBerg
                    } else if currentBerg.name == "rightBerg" {
                        highestRightBerg = berg
                        highestBerg = highestRightBerg
                    }
                }
                
                normalBergCount += 1
                if normalBergCount >= forkingFrequency {
                    // Enter forking mode
                    mode = .forking
                    normalBergCount = 0
                }
                
                insertChild(berg, atIndex: 0)
                
                if shouldMove {
                    berg.beginMoving()
                }
            }
        }
    }
    
}