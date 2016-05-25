//
//  Stage.swift
//  IcebergGenerator
//
//  Created by Matthew Tso on 5/24/16.
//  Copyright © 2016 De Anza. All rights reserved.
//

import SpriteKit

class IcebergGenerator: SKSpriteNode {
    init(size: CGSize, penguinPosition: CGPoint) {
        super.init(texture: nil, color: UIColor.clearColor(), size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update() {
        
    }
}