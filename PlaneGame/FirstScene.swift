//
//  FirstScene.swift
//  PlaneGame
//
//  Created by 谭钧豪 on 16/2/9.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

import SpriteKit

class FirstScene: SKScene {
    let myLabel = SKLabelNode(fontNamed:"Chalkduster")
    var CenterPoint:CGPoint!
    override func didMoveToView(view: SKView) {
        CenterPoint = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        myLabel.text = "拖动我!"
        myLabel.fontSize = 45
        myLabel.position = CenterPoint
        let nodesLabel1 = SKLabelNode(text: "拉到这玩飞机打陨石")
        nodesLabel1.position = CGPointMake(CenterPoint.x, 100)
        let rectshape1 = SKShapeNode(rectOfSize: CGSizeMake(self.frame.width-80, 95))
        rectshape1.position = CGPointMake(CenterPoint.x, 100)
        
        
        self.addChild(myLabel)
        self.addChild(nodesLabel1)
        self.addChild(rectshape1)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches{
            let location = touch.locationInNode(self)
            myLabel.runAction(SKAction.moveToY(location.y, duration: 0.2), completion:{
                if self.myLabel.position.y < 100{
                    self.jumptoplane()
                }else{
                    self.myLabel.runAction(SKAction.moveToY(self.CenterPoint.y, duration: 0.1))
                }
            })
            
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches{
            let location = touch.locationInNode(self)
            myLabel.position.y = location.y
        }
        if myLabel.position.y < 100{
            jumptoplane()
        }
    }
    
    func jumptoplane(){
        let gamescene = GameScene(size:self.size)
        self.view?.presentScene(gamescene, transition: SKTransition.crossFadeWithDuration(0.5))
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        myLabel.position = CenterPoint
    }
    override func update(currentTime: NSTimeInterval) {
        
    }
}
