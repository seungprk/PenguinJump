//
//  GameScene.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/22/16.
//  Copyright (c) 2016 De Anza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let showDots = false

    let bergSize = 100.0
//    let grid = SKSpriteNode()
    
    var bergOffset = 0.0
    var shadowHeight:CGFloat = 10.0
    var underwaterHeight:CGFloat = 6.0
    
    var bergVertices:[CGPoint]?
    var shadowVertices:[CGPoint]?
    var underwaterVertices:[CGPoint]?
    
    var berg:SKShapeNode?
    var shadow:SKShapeNode?
    var underwater:SKShapeNode?
    
//    var shadowCrop:SKCropNode?
    var shadowMask:SKShapeNode?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor(red: 0.6, green: 0.9, blue: 1, alpha: 1)

//        createGrid()
        let bergVertices:[CGPoint] = generateRandomPoints(CGPoint(x: 0, y: 0)) // <- 0, 0 here refers to the berg's center point
        
//        createBerg()
//        let points = bergVertices
        let bergPath = CGPathCreateMutable()
        CGPathMoveToPoint(bergPath, nil, bergVertices[0].x, bergVertices[0].y)
        for point in 1..<bergVertices.count {
            CGPathAddLineToPoint(bergPath, nil, bergVertices[point].x, bergVertices[point].y)
        }
        CGPathCloseSubpath(bergPath)
        
        berg = SKShapeNode(path: bergPath)
        berg!.path = bergPath
        berg!.position = view.center
        berg!.fillColor = SKColor.whiteColor()
//        berg!.strokeColor = SKColor.redColor()
        berg!.strokeColor = SKColor.whiteColor()
        berg!.lineWidth = 1
        
        addChild(berg!)

        
        
        
        if showDots {
            addDot(self, point: view.center)
            for point in 0..<bergVertices.count {
                addDot(berg!, point: bergVertices[point])
            }
        }
        
//        createShadow()
        createUnderwater()
        
        
        let rightDeltaX = bergVertices[1].x - bergVertices[2].x
        let rightDeltaY = bergVertices[1].y - bergVertices[2].y
        let rightSlope = rightDeltaY / rightDeltaX
        //        let check = rightSlope > 0 ? "vertex 1 overhangs" : "vertex 2 begins shadow"
        let beginsWith1 = rightSlope > 0 ? true : false
        let startPoint = rightSlope > 0 ? 1 : 2
        
        let leftDeltaX = bergVertices[6].x - bergVertices[5].x
        let leftDeltaY = bergVertices[6].y - bergVertices[5].y
        let leftSlope = leftDeltaY / leftDeltaX
        let leftCheck = leftSlope > 0 ? "vertex 5 begins shadow" : "vertex 6 overhangs"
        let endsWith6 = leftSlope > 0 ? false : true
        let endPoint = leftSlope > 0 ? 5 : 6
        
        let shadowPath = CGPathCreateMutable()
        
        CGPathMoveToPoint(shadowPath, nil, bergVertices[startPoint].x, bergVertices[startPoint].y)
        CGPathAddLineToPoint(shadowPath, nil, bergVertices[startPoint].x, bergVertices[startPoint].y - shadowHeight)
        
        for point in startPoint + 1 ..< endPoint {
            CGPathAddLineToPoint(shadowPath, nil, bergVertices[point].x, bergVertices[point].y - shadowHeight)
        }
        
        CGPathAddLineToPoint(shadowPath, nil, bergVertices[endPoint].x, bergVertices[endPoint].y - shadowHeight)
        CGPathAddLineToPoint(shadowPath, nil, bergVertices[endPoint].x, bergVertices[endPoint].y)
        CGPathCloseSubpath(shadowPath)
        
        shadow = SKShapeNode()
        shadow!.path = shadowPath
        shadow!.position = CGPoint(x: view.center.x, y: view.center.y)// - shadowHeight)
        let shadowColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 1.0)
        shadow!.fillColor = shadowColor
        shadow!.strokeColor = shadowColor
        shadow!.lineWidth = 1
        shadow!.zPosition = -10
        
//        addChild(shadow!)
        
        
        
        let underwaterPath = CGPathCreateMutable()
        
        CGPathMoveToPoint(underwaterPath, nil, bergVertices[startPoint].x, bergVertices[startPoint].y)
        CGPathAddLineToPoint(underwaterPath, nil, bergVertices[startPoint].x, bergVertices[startPoint].y - shadowHeight - underwaterHeight)
        
        for point in startPoint + 1 ..< endPoint {
            CGPathAddLineToPoint(underwaterPath, nil, bergVertices[point].x, bergVertices[point].y - shadowHeight - underwaterHeight)
        }
        
        CGPathAddLineToPoint(underwaterPath, nil, bergVertices[endPoint].x, bergVertices[endPoint].y - shadowHeight - underwaterHeight)
        CGPathAddLineToPoint(underwaterPath, nil, bergVertices[endPoint].x, bergVertices[endPoint].y)
        CGPathCloseSubpath(underwaterPath)
        
        underwater = SKShapeNode()
        underwater!.path = underwaterPath
        underwater!.position = CGPoint(x: view.center.x, y: view.center.y)// - underwaterHeight)
        let underwaterColor = SKColor(red: 0.88, green: 0.93, blue: 0.96, alpha: 0.5)
        underwater!.fillColor = underwaterColor
        underwater!.strokeColor = underwaterColor
        underwater!.lineWidth = 1
        underwater!.zPosition = -20
        
        addChild(underwater!)
        
        
        
        let shadowCrop = SKCropNode()
        shadowMask = SKShapeNode(path: underwaterPath)
        shadowMask!.fillColor = SKColor.blackColor()
        shadowMask!.position = CGPointZero
        shadowMask!.name = "shadowMask"
        
        shadow!.position = CGPointZero
        shadowCrop.addChild(shadow!)
        
        shadowCrop.maskNode = shadowMask
        shadowCrop.position = view.center
        shadowCrop.zPosition = -10
        
        addChild(shadowCrop)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches {
            let sinkDepth = 10.0
            let sinkDuration = 1.0
            
            let sink = SKAction.moveBy(CGVector(dx: 0.0, dy: -sinkDepth), duration: sinkDuration)
            let wait = SKAction.waitForDuration(sinkDuration * 2)
            let rise = SKAction.moveBy(CGVector(dx: 0.0, dy: sinkDepth), duration: sinkDuration)
            
            let sinkSequence = SKAction.sequence([sink, wait, rise])
            
            underwater!.runAction(sinkSequence)
            shadowMask!.runAction(sinkSequence)
            
            berg!.runAction(sink, completion: {
                let underwaterColor = SKColor(red: 0.8, green: 0.95, blue: 1, alpha: 1)
                self.berg!.fillColor = underwaterColor
                self.berg!.strokeColor = underwaterColor
                
                self.berg!.runAction(wait, completion: {
                    self.berg!.fillColor = SKColor.whiteColor()
                    self.berg!.strokeColor = SKColor.whiteColor()
                    
                    self.berg!.runAction(rise)
                })
            })
        }
        
    }
    
    func createBerg() {
//        let points = bergVertices!
//        let bergPath = CGPathCreateMutable()
//        CGPathMoveToPoint(bergPath, nil, points[0].x, points[0].y)
//        for point in 1..<bergVertices!.count {
//            CGPathAddLineToPoint(bergPath, nil, bergVertices![point].x, bergVertices![point].y)
//        }
//        CGPathCloseSubpath(bergPath)
//        
////        let berg = SKShapeNode(path: bergPath)
//        berg!.path = bergPath
//        berg!.position = view!.center
//        berg!.fillColor = SKColor.whiteColor()
//        berg!.strokeColor = SKColor.redColor()
//        berg!.lineWidth = 2
//        
//        addChild(berg!)
    }
    func createShadow() {
//        var points = [CGPoint]()
//        for point in bergVertices! {
//            points.append(point)
//        }
////        let points = bergVertices!
////        let shadowHeight = 10.0
//        
//        let rightDeltaX = points[1].x - points[2].x
//        let rightDeltaY = points[1].y - points[2].y
//        let rightSlope = rightDeltaY / rightDeltaX
////        let check = rightSlope > 0 ? "vertex 1 overhangs" : "vertex 2 begins shadow"
//        let beginsWith1 = rightSlope > 0 ? true : false
//        let startPoint = rightSlope > 0 ? 1 : 2
//        
//        let leftDeltaX = points[6].x - points[5].x
//        let leftDeltaY = points[6].y - points[5].y
//        let leftSlope = leftDeltaY / leftDeltaX
//        let leftCheck = leftSlope > 0 ? "vertex 5 begins shadow" : "vertex 6 overhangs"
//        let endsWith6 = leftSlope > 0 ? false : true
//        let endPoint = leftSlope > 0 ? 5 : 6
//        
//        let shadowPath = CGPathCreateMutable()
//       
//        CGPathMoveToPoint(shadowPath, nil, points[startPoint].x, points[startPoint].y)
//        CGPathAddLineToPoint(shadowPath, nil, points[startPoint].x, points[startPoint].y - shadowHeight)
//        
//        for point in startPoint + 1 ..< endPoint - 1 {
//            CGPathAddLineToPoint(shadowPath, nil, points[point].x, points[point].y)
//        }
//        
//        CGPathAddLineToPoint(shadowPath, nil, points[endPoint].x, points[endPoint].y - shadowHeight)
//        CGPathAddLineToPoint(shadowPath, nil, points[endPoint].x, points[endPoint].y)
//        CGPathCloseSubpath(shadowPath)
//        
//        shadow!.path = shadowPath
//        shadow!.fillColor = SKColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 1.0)
//        shadow!.position = CGPoint(x: view!.center.x, y: view!.center.y - shadowHeight)
//        shadow!.zPosition = -10
//        
//        berg!.addChild(shadow!)
        
        
        
        
        
        
    }
    func createUnderwater() {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func generateRandomPoints(aroundPoint: CGPoint) -> [CGPoint] {
        let center = aroundPoint // view!.center
        let radius = bergSize / 2
        
        var randomPoints = [CGPoint]()
        
//        print(M_PI * 2) // 1 Radian (360˚)
        
        for count in 0..<8 {
            let section = M_PI / 4 * Double(count)
            let randomAngleInSection = section + Double(arc4random_uniform(628)) / 100 / 8
            
            let xFromCenter = sin(randomAngleInSection) * radius
            let yFromCenter = cos(randomAngleInSection) * radius
            
            let pointX = center.x + CGFloat(xFromCenter)
            let pointY = center.y + CGFloat(yFromCenter)
            
            let point = CGPoint(x: pointX, y: pointY)
            randomPoints.append(point)
        }
        
        return randomPoints
    }
    
    func addDot(node: SKNode, point: CGPoint) {
        let dot = SKSpriteNode()
        dot.size = CGSize(width: 1.5, height: 1.5)
        dot.position = point
        dot.color = SKColor.blackColor()
        dot.zPosition = 100
        
//        let square = SKSpriteNode()
//        square.size = CGSize(width: 10, height: 10)
//        square.position = CGPoint(x: 0,y: 0)
//        square.color = SKColor.greenColor()
//        square.zPosition = -10
//        square.alpha = 0.5
        
        let circle = SKShapeNode()
        circle.path = CGPathCreateWithEllipseInRect(CGRect(x: -5, y: -5, width: 10, height: 10), nil)
        circle.position = CGPoint(x: 0,y: 0)
        circle.fillColor = SKColor.clearColor()
        circle.strokeColor = SKColor.greenColor()
        circle.zPosition = -10
        
        dot.addChild(circle)
        node.addChild(dot)
    }
    
    /*
    func createGrid() {
        grid.position = CGPoint(x: view!.center.x, y: view!.center.y)
        grid.size = CGSize(width: bergSize, height: bergSize)
        grid.color = SKColor.whiteColor()
        addChild(grid)
        
        let cellSize = CGSize(width: bergSize / 4, height: bergSize / 4)
        let gridStartingPoint = CGPoint(
            x: -grid.size.width / 2 + cellSize.width / 2,
            y: -grid.size.height / 2 + cellSize.height / 2)
        
        var cellCounter = 0
        for row in 0..<4 {
            for column in 0..<4 {
                let cell = SKSpriteNode()
                cell.color = Bool((row + column) % 2) ? SKColor.redColor() : SKColor.yellowColor()
                cell.size = cellSize
                
                let cellX = gridStartingPoint.x + cellSize.width * CGFloat(row)
                let cellY = gridStartingPoint.y + cellSize.height * CGFloat(column)
                cell.position = CGPoint(x: cellX, y: cellY)
                
                grid.addChild(cell)
                
                cell.name = String("cell\(cellCounter)")
                cellCounter += 1
            }
        }
    }
    */
}
