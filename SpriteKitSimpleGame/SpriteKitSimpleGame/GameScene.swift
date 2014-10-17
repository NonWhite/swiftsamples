import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "player")
    var monstersDestroyed = 0

    override func didMoveToView(view: SKView) {
        playBackgroundMusic( "background-music-aac.caf" )
        
        backgroundColor = SKColor.whiteColor()
        player.position = CGPoint( x: size.width * 0.1 , y: size.height * 0.5 )
        addChild( player )
        
        physicsWorld.gravity = CGVectorMake( 0 , 0 )
        physicsWorld.contactDelegate = self
        
        runAction( SKAction.repeatActionForever(
            SKAction.sequence( [ SKAction.runBlock( addMonster ) , SKAction.waitForDuration( 1.0 ) ] )
        ) )
    }
    
    func random() -> CGFloat {
        return CGFloat( Float( arc4random() ) / 0xFFFFFFFF )
    }
    
    func random( #min: CGFloat , max: CGFloat ) -> CGFloat {
        return random() * ( max - min ) + min
    }
    
    func addMonster() {
        let monster = SKSpriteNode( imageNamed: "monster" )
        monster.physicsBody = SKPhysicsBody( rectangleOfSize: monster.size )
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualY = random( min: monster.size.height/2 , max: size.height - monster.size.height / 2 )
        
        monster.position = CGPoint( x: size.width + monster.size.width / 2 , y: actualY )
        
        addChild( monster )
        
        let actualDuration = random( min: CGFloat( 2.0 ) , max: CGFloat( 4.0 ) )

        let actionMove = SKAction.moveTo(
            CGPoint( x: -monster.size.width / 2 , y: actualY ) ,
            duration: NSTimeInterval( actualDuration ) )
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock(){
            let reveal = SKTransition.flipHorizontalWithDuration( 0.5 )
            let gameOverScene = GameOverScene( size: self.size , won: false )
            self.view?.presentScene( gameOverScene , transition: reveal )
        }
        monster.runAction( SKAction.sequence( [ actionMove , loseAction , actionMoveDone ] ) )
        
    }
    
    override func touchesEnded( touches: NSSet , withEvent event: UIEvent ){
        runAction( SKAction.playSoundFileNamed( "pew-pew-lei.caf" , waitForCompletion: false ) )
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode( self )
        
        let projectile = SKSpriteNode( imageNamed: "projectile" )
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody( circleOfRadius: projectile.size.width / 2 )
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let offset = touchLocation - projectile.position
        
        if( offset.x < 0 ){
            return
        }
        
        addChild( projectile )
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.moveTo( realDest , duration: 2.0 )
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction( SKAction.sequence( [ actionMove , actionMoveDone ] ) )
    }
    
    func projectileDidCollideWithMonster( projectile: SKSpriteNode , monster: SKSpriteNode ){
        println( "Hit" )
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed++
        if( monstersDestroyed > 30 ){
            let reveal = SKTransition.flipHorizontalWithDuration( 0.5 )
            let gameOverScene = GameOverScene( size: self.size , won: true )
            self.view?.presentScene( gameOverScene , transition: reveal )
        }
    }
    
    func didBeginContact( contact: SKPhysicsContact ){
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if( ( firstBody.categoryBitMask & PhysicsCategory.Monster != 0 ) &&
            ( secondBody.categoryBitMask & PhysicsCategory.Projectile != 0 ) ){
                projectileDidCollideWithMonster( firstBody.node as SKSpriteNode , monster: secondBody.node as SKSpriteNode )
        }
    }
}