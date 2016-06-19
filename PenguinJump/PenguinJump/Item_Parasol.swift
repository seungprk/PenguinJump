//
//  Item_Parasol.swift
//  PenguinJump
//
//  Created by Matthew Tso on 6/11/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class Item_Parasol: SKNode {
    
    let parasol_closed = SKSpriteNode(texture: SKTexture(image: UIImage(named: "parasol_closed")!))
    let parasol_open = SKSpriteNode(texture: SKTexture(image: UIImage(named: "parasol_open")!))
    
    override init() {
        super.init()
        
        parasol_closed.anchorPoint = CGPoint(x: 0.5, y: 0.1)
        addChild(parasol_closed)
        
        parasol_open.alpha = 0
        addChild(parasol_open)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func open() {
        parasol_closed.alpha = 0
        parasol_open.alpha = 1
    }
    
    func close() {
        parasol_closed.alpha = 1
        parasol_open.alpha = 0
    }
}
