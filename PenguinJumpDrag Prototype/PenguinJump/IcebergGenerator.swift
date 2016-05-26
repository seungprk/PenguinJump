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
    
    var visibleView: SKView!
//    var gameScene: SKScene!
    var camera:SKCameraNode!
    
    var bergSize:CGFloat = 150.0
    var gapDistance:CGFloat = 300.0
    var forkingFrequency = 7
    
    var mode = pathingMode.straight
    
    var currentBerg: Iceberg?
    var firstBergOfFork: Iceberg?
    var highestBerg: Iceberg?
    var normalBergCount = 0
    
    var highestLeftBerg: Iceberg?
    var highestRightBerg: Iceberg?
    
    init(view: SKView, camera: SKCameraNode) {
        super.init(texture: nil, color: UIColor.clearColor(), size: view.frame.size)
        position = view.center

        visibleView = view
        self.camera = camera
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func newGame(startPoint: CGPoint) {
        removeAllChildren()
        
        let firstBerg = Iceberg(size: CGSize(width: 150.0, height: 150.0))
        firstBerg.position = startPoint
        
        insertChild(firstBerg, atIndex: 0)
        highestBerg = firstBerg
        
        generateBerg()
    }
    
    func scroll(velocity: CGVector) {
        for child in children {
            child.position.x -= velocity.dx
            child.position.y += velocity.dy
        }
    }
    
    func scrollTo(velocity: CGVector, duration: NSTimeInterval) {
        let movePlatformAction = SKAction.moveBy(velocity, duration: NSTimeInterval(duration))
        for child in children{
            child.runAction(movePlatformAction)
        }
    }
    
    func update() {
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
//
//            if highestBerg.frame.origin.y + highestBerg.frame.height < camera.position.y {
//                return true
//            } else {
//                return false
//            }
//            
//            if highestBerg.frame.origin.y + highestBerg.frame.height < frame.height / 2 {
//                return true
//            } else {
//                return false
//            }
        } else {
            return false
        }
    }
    
    func clearBerg() {
        for child in children {
            // If top edge of child's frame is less than bottom edge of view's frame, remove child.
            if child.position.y < camera.position.y - visibleView.frame.height - 100 {
                child.removeFromParent()
            }
            
//            if child.frame.origin.y + child.frame.height < -frame.height / 2 {
//                child.removeFromParent()
//            }
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
            
            highestBerg = highestLeftBerg?.position.y > highestRightBerg?.position.y ?
                highestLeftBerg : highestRightBerg // doesn't really matter since they are equal

            
            mode = .straight
        } else {
            while shouldGenerate() {
                
                let berg = Iceberg(size: CGSize(width: bergSize, height: bergSize))
                
                let deltaX = CGFloat(random()) % frame.width * 0.8 - frame.width * 0.4
                
                let xPosition = highestBerg!.position.x + deltaX
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
                
            }
        }
        
    }
}