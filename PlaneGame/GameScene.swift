//
//  GameScene.swift
//  PlaneGame
//
//  Created by 谭钧豪 on 16/2/9.
//  Copyright (c) 2016年 谭钧豪. All rights reserved.
//

import SpriteKit

class enemytype: SKShapeNode {
    var life:Int!
    var totallife:Int!
}

class planetype: SKSpriteNode {
    var planelife:Int!
    var planetotallife:Int = 100
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //MARK:定义各种全局变量以及控件
    var CenterPoint:CGPoint!
    var plane:planetype!
    var scorelabel:SKLabelNode!
    var planelifelabel:SKLabelNode!
    var gameoverlabel:SKLabelNode!
    var insisttimelabel:SKLabelNode!
    var recordlabel:SKLabelNode!

    var lastbullettime:NSTimeInterval = 0
    var lastenemytime:NSTimeInterval = 0
    var lastweapontime:NSTimeInterval = 0
    var lastdifficultyleveluptime:NSTimeInterval = 0
    var lastupdatetime:NSTimeInterval = 0
    var lastaddlifetime:NSTimeInterval = 0
    
    var bullettime:NSTimeInterval = 0.4     //子弹初始发射间隔
    var enemyfalltime:NSTimeInterval = 8    //陨石陨落至底部初始所需时间
    var baseenemyinterval:Int = 12          //两颗陨石之间的最低时间间隔（10代表1秒）
    var weapontime:NSTimeInterval = 10      //生成武器升级方块最低间隔时间
    var difficultyleveluptime:NSTimeInterval = 10       //增加难度时间（每隔多少秒上调一次难度）
    var baseenemylifelevel:Double = 10      //基础陨石生命比例(反比，数值越大，基础陨石生命越小)
    var insisttime:NSTimeInterval = 0.0     //用于记录当前游戏时间
    var starttime:NSTimeInterval = 0        //用于记录开始游戏时间
    var bulletpower:Int = 1                 //单颗子弹火力
    var recoverlife:Int = 5                 //每次恢复生命值

    
    var record = [
        "score":0,
        "time":0.0
    ]
    var score:Int = 0
    var gameoverstatu:Bool = false
    
    //MARK:游戏视图加载时的动作
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        if let temprecord = NSUserDefaults.standardUserDefaults().valueForKey("record"){
            record = temprecord as! [String : Double]
        }
        self.CenterPoint = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        let bgimg = SKSpriteNode(imageNamed: "bg")
        bgimg.position = CenterPoint
        bgimg.name = "BACKGROUND"
        bgimg.zPosition = -99
        self.addChild(bgimg)
        
        
        plane = planetype(texture: SKTextureAtlas(named: "plane").textureNamed("Spaceship"))
        plane.xScale = 0.2
        plane.yScale = 0.2
        plane.planelife = plane.planetotallife
        plane.position = self.CenterPoint
        plane.physicsBody = SKPhysicsBody(rectangleOfSize: plane.size)
        setPhysicsBody(plane, categoryBitMask: BitMaskType.plane, contactTestBitMask: BitMaskType.enemy)
        
        scorelabel = SKLabelNode(text: "当前分数：\(String(score))")
        scorelabel.fontSize = 25
        scorelabel.position = CGPointMake(CenterPoint.x, self.frame.height-25)
        
        planelifelabel = SKLabelNode(text: "当前剩余生命值：\(String(plane.planelife))")
        planelifelabel.fontSize = 25
        planelifelabel.position = CGPointMake(scorelabel.position.x,scorelabel.position.y-25)
        
        insisttimelabel = SKLabelNode(text: "已坚持时间：\(String(insisttime))秒")
        insisttimelabel.fontSize = 25
        insisttimelabel.position = CGPointMake(planelifelabel.position.x,planelifelabel.position.y-25)
        
        
        
        
        let exitlabel = SKLabelNode(text: "X")
        let exitrect = SKShapeNode(rectOfSize: CGSizeMake(30,30))
        exitrect.position = CGPointMake(self.frame.width-25,self.frame.height-30)
        exitlabel.position = CGPointMake(exitrect.position.x,exitrect.position.y-13)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        self.addChild(exitlabel)
        self.addChild(exitrect)
        self.addChild(plane)
        self.addChild(scorelabel)
        self.addChild(planelifelabel)
        self.addChild(insisttimelabel)
        

    
    }
    
    //MARK:手势动作
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let action = SKAction.moveTo(location, duration: 0.1)
            plane.runAction(action, completion: {
                ()->Void in

            })
            if location.x>self.frame.width-50 && location.y>self.frame.height-50{
                let scene = FirstScene(size:CGSizeMake(self.frame.width,self.frame.height))
                self.view?.presentScene(scene)
            }else if gameoverstatu {
                resetgame()
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            plane.position = CGPointMake(location.x,location.y+10)
        }
    }
    
    //MARK: 游戏的停止以及重置控制
    func gameover(){
        if Double(score) > record["score"] && insisttime > record["time"]{
            record["score"] = Double(score)
            record["time"] = insisttime
            NSUserDefaults.standardUserDefaults().setValue(record, forKey: "record")
        }
        
        plane.removeFromParent()
        recordlabel = SKLabelNode(text: "最高记录：\(String(format:"%.0f" ,record["score"]!))分，\(String(format:"%.2f",record["time"]!))秒")
        recordlabel.position = CGPointMake(self.CenterPoint.x, self.CenterPoint.y+30)
        gameoverlabel = SKLabelNode(text: "Game Over!")
        gameoverlabel.fontName = "Chalkduster"
        gameoverlabel.position = self.CenterPoint
        gameoverstatu = true
        self.addChild(gameoverlabel)
        self.addChild(recordlabel)
    }
    
    func resetgame(){
        plane.planelife = plane.planetotallife
        gameoverstatu = false
        score = 0
        bullettime = 0.4
        bulletpower = 1
        enemyfalltime = 5
        baseenemyinterval = 12
        baseenemylifelevel = 10
        starttime = 0
        recoverlife = 5
        recordlabel.removeFromParent()
        gameoverlabel.removeFromParent()
        scorelabel.text = "当前分数：0"
        planelifelabel.text = "当前剩余生命值：\(String(plane.planelife!))"
        self.addChild(plane)
    }
    
    //MARK: 创造游戏的各种物体
    
    func createbullet(){
        let bullet = SKShapeNode(circleOfRadius: 5)
        bullet.position = CGPointMake(plane.position.x, plane.position.y+plane.frame.height/2)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        setPhysicsBody(bullet, categoryBitMask: BitMaskType.bullet, contactTestBitMask: BitMaskType.enemy)
        bullet.fillColor = SKColor.whiteColor()
        bullet.runAction(SKAction.sequence([SKAction.moveByX(0, y: size.height, duration: 1),SKAction.removeFromParent()]))
        self.addChild(bullet)
    }
    
    func createweapon(){
        let random = CGFloat(arc4random()%10 + 1)/10 * CGFloat(self.frame.width)
        let weapon = SKShapeNode(rectOfSize: CGSizeMake(16, 16))
        weapon.position = CGPointMake(CGFloat(random),self.frame.height)
        weapon.zPosition = 3
        weapon.physicsBody = SKPhysicsBody(rectangleOfSize: weapon.frame.size)
        setPhysicsBody(weapon, categoryBitMask: BitMaskType.weapon, contactTestBitMask: BitMaskType.plane)
        
        weapon.fillColor = SKColor.blueColor()
        weapon.runAction(SKAction.sequence([SKAction.moveByX(0,y: -size.height, duration: 2) ,SKAction.removeFromParent()]))
        self.addChild(weapon)
    }
    
    func createaddlife(){
        let random = CGFloat(arc4random()%10 + 1)/10 * CGFloat(self.frame.width)
        let addlife = SKShapeNode(rectOfSize: CGSizeMake(16, 16))
        addlife.position = CGPointMake(CGFloat(random),self.frame.height)
        addlife.zPosition = 3
        addlife.physicsBody = SKPhysicsBody(rectangleOfSize: addlife.frame.size)
        setPhysicsBody(addlife, categoryBitMask: BitMaskType.addlife, contactTestBitMask: BitMaskType.plane)
        addlife.fillColor = SKColor.greenColor()
        addlife.runAction(SKAction.sequence([SKAction.moveByX(0,y: -size.height, duration: 2) ,SKAction.removeFromParent()]))
        self.addChild(addlife)
    }
    
    func createenemy(){
        let random = arc4random()%80+10
        let enemylife = Int(random)
        let enemy = enemytype(circleOfRadius: CGFloat(random))
        enemy.life = Int(Double(enemylife)/baseenemylifelevel)
        enemy.totallife = enemy.life
        enemy.fillColor = SKColor.redColor()
        let x:CGFloat = CGFloat(arc4random()%UInt32(self.frame.width))
        enemy.position = CGPointMake(x, self.frame.height-25)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(random))
        setPhysicsBody(enemy, categoryBitMask: BitMaskType.enemy, contactTestBitMask: BitMaskType.bullet)
        
        enemy.runAction(SKAction.sequence([SKAction.moveByX(0, y: -size.height, duration: enemyfalltime),SKAction.removeFromParent()]))
        self.addChild(enemy)
    }
    
    
    func setPhysicsBody(node:SKNode,categoryBitMask:UInt32,contactTestBitMask:UInt32){
        node.physicsBody?.categoryBitMask = categoryBitMask
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = contactTestBitMask
    }

    //MARK:两两碰撞检测
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BitMaskType.bullet | BitMaskType.enemy{
            if let life = (contact.bodyA.node as? enemytype)?.life{
                if life > 0{
                (contact.bodyA.node as? enemytype)?.life = life - bulletpower
                }else{
                    score += ((contact.bodyA.node as? enemytype)?.totallife)!
                    scorelabel.text = "当前分数：\(String(score))"
                    contact.bodyA.node?.removeFromParent()
                }
                contact.bodyB.node?.removeFromParent()
            }else if let life = (contact.bodyB.node as? enemytype)?.life{
                
                if life > 0{
                    (contact.bodyB.node as? enemytype)?.life = life - bulletpower
                }else{
                    score += ((contact.bodyB.node as? enemytype)?.totallife)!
                    scorelabel.text = "当前分数：\(String(score))"
                    contact.bodyB.node?.removeFromParent()
                }
                contact.bodyA.node?.removeFromParent()
            
            }
        }else if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BitMaskType.plane | BitMaskType.enemy{
            if let planelife = (contact.bodyA.node as? planetype)?.planelife{
                if var enemylife = ((contact.bodyB.node as? enemytype)?.life){
                    if enemylife > 94{
                        enemylife = 94
                    }
                    (contact.bodyA.node as? planetype)?.planelife = planelife - enemylife
                }
                if (contact.bodyA.node as? planetype)?.planelife >= 0{
                    planelifelabel.text = "当前剩余生命值：\(String((contact.bodyA.node as! planetype).planelife!))"
                    contact.bodyB.node?.removeFromParent()
                }else{
                    gameover()
                }
            }else if let planelife = (contact.bodyB.node as? planetype)?.planelife{
                if var enemylife = ((contact.bodyB.node as? enemytype)?.life){
                    if enemylife > 94{
                        enemylife = 94
                    }
                    (contact.bodyB.node as? planetype)?.planelife = planelife - enemylife
                }
                if (contact.bodyA.node as? planetype)?.planelife >= 0{
                    planelifelabel.text = "当前剩余生命值：\(String((contact.bodyB.node as! planetype).planelife!))"
                    contact.bodyA.node?.removeFromParent()
                }else{
                    gameover()
                }
            }

        }else if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BitMaskType.plane | BitMaskType.weapon{
            if let _ = (contact.bodyA.node as? planetype)?.planelife{
                if bullettime < 0.1{
                    bulletpower++
                }else{
                    bullettime = bullettime*0.5
                }
                contact.bodyB.node?.removeFromParent()
            }else if let _ = (contact.bodyB.node as? planetype)?.planelife{
                if bullettime < 0.1{
                    bulletpower++
                }else{
                    bullettime = bullettime*0.5
                }
                contact.bodyA.node?.removeFromParent()
            }
            
        }else if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BitMaskType.plane | BitMaskType.addlife{
            if let planelife = (contact.bodyA.node as? planetype)?.planelife{
                if planelife < (contact.bodyA.node as? planetype)?.planetotallife{
                    (contact.bodyA.node as? planetype)?.planelife = planelife + recoverlife
                    if (contact.bodyA.node as? planetype)?.planelife > (contact.bodyA.node as? planetype)?.planetotallife{
                       (contact.bodyA.node as? planetype)?.planelife = (contact.bodyA.node as? planetype)?.planetotallife
                    }
                    planelifelabel.text = "当前剩余生命值：\(String((contact.bodyA.node as! planetype).planelife!))"
                    contact.bodyB.node?.removeFromParent()
                }
            }else if let planelife = (contact.bodyB.node as? planetype)?.planelife{
                if planelife < (contact.bodyB.node as? planetype)?.planetotallife{
                    (contact.bodyB.node as? planetype)?.planelife = planelife + recoverlife
                    if (contact.bodyB.node as? planetype)?.planelife > (contact.bodyB.node as? planetype)?.planetotallife{
                        (contact.bodyB.node as? planetype)?.planelife = (contact.bodyB.node as? planetype)?.planetotallife
                    }
                    planelifelabel.text = "当前剩余生命值：\(String((contact.bodyB.node as! planetype).planelife!))"
                    contact.bodyA.node?.removeFromParent()
                }
            }
            
        }
    }

   
    //MARK:刷新视图时的操作（时间的控制）
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if starttime == 0{
            starttime = currentTime
            lastweapontime = currentTime
            lastaddlifetime = currentTime
        }
        
        if gameoverstatu == false{
            if currentTime >= lastbullettime + bullettime{
                lastbullettime = currentTime
                createbullet()
            }
            
            if currentTime >= lastenemytime + NSTimeInterval(Int(arc4random() % 32)+baseenemyinterval) / 10{
                lastenemytime = currentTime
                createenemy()
            }
            
            if currentTime >= lastaddlifetime + NSTimeInterval(arc4random() % 10 + 10){
                lastaddlifetime = currentTime
                createaddlife()
            }
            
            if currentTime >= lastweapontime + weapontime{
                lastweapontime = currentTime
                createweapon()
                weapontime = NSTimeInterval(arc4random() % 10 + 5)
            }
            
            if currentTime >= lastdifficultyleveluptime + difficultyleveluptime{
                lastdifficultyleveluptime = currentTime
                if baseenemyinterval >= 1 {
                    baseenemyinterval -= 1
                }
                if recoverlife <= 90{
                    recoverlife++
                }
                if enemyfalltime >= 2.5{
                    enemyfalltime *= 0.8
                    baseenemylifelevel *= 0.9
                }else{
                    baseenemylifelevel *= 0.7
                }
            }
            
            if currentTime >= lastupdatetime + 0.01{
                lastupdatetime = currentTime
                insisttime = lastupdatetime - starttime
                insisttimelabel.text = "已坚持时间：\(String(format: "%.2f", insisttime))秒"
            }
        }
    }
}
