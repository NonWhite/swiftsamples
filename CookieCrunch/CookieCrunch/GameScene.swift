import SpriteKit

class GameScene: SKScene {
    var level: Level!
    let tileWidth: CGFloat = 32.0
    let tileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookieLayer = SKNode()
    let tilesLayer = SKNode()
    
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    var swipeHandler: ((Swap) -> ())?
    
    var selectionSprite = SKSpriteNode()
    
    let swapSound = SKAction.playSoundFileNamed( "Chomp.wav" , waitForCompletion: false )
    let invalidSwapSound = SKAction.playSoundFileNamed( "Error.wav" , waitForCompletion: false )
    let matchSound = SKAction.playSoundFileNamed( "Ka-Ching.wav" , waitForCompletion: false )
    let fallingCookieSound = SKAction.playSoundFileNamed( "Scrape.wav" , waitForCompletion: false )
    let addCookieSound = SKAction.playSoundFileNamed( "Drip.wav" , waitForCompletion: false )
    
    required init( coder aDecoder: NSCoder ){
        super.init( coder: aDecoder )
        setup()
    }
    
    override init( size: CGSize ){
        super.init( size: size )
        setup()
    }
    
    func setup(){
        anchorPoint = CGPoint( x: 0.5 , y: 0.5 )
        
        let background = SKSpriteNode( imageNamed: "Background" )
        addChild( background )
        
        addChild( gameLayer )
        
        let layerPosition = CGPoint(
            x: -tileWidth * CGFloat( NumColumns ) / 2 ,
            y: -tileHeight * CGFloat( NumRows ) / 2 )
        
        tilesLayer.position = layerPosition
        gameLayer.addChild( tilesLayer )
        
        cookieLayer.position = layerPosition
        gameLayer.addChild( cookieLayer )
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    func addSpritesForCookies( cookies: Set<Cookie> ){
        for cookie in cookies {
            let sprite = SKSpriteNode( imageNamed: cookie.cookieType.spriteName )
            sprite.position = pointForCookie( cookie.column , row: cookie.row )
            cookieLayer.addChild( sprite )
            cookie.sprite = sprite
        }
    }
    
    func pointForCookie( column: Int , row: Int ) -> CGPoint {
        return CGPoint(
            x: tileWidth * CGFloat( column ) + tileWidth / 2 ,
            y: tileHeight * CGFloat( row ) + tileHeight / 2 )
    }
    
    func addTiles(){
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtPosition( column, row: row ){
                    let tileNode = SKSpriteNode( imageNamed: "Tile" )
                    tileNode.position = pointForCookie( column , row: row )
                    tilesLayer.addChild( tileNode )
                }
            }
        }
    }
    
    override func touchesBegan( touches: NSSet , withEvent event: UIEvent ){
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode( cookieLayer )
        let ( success , column , row ) = convertPoint( location )
        if success {
            if let cookie = level.cookieAtPosition( column , row: row ){
                showSelectionIndicatorForCookie( cookie )
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    func convertPoint( point: CGPoint ) -> ( success: Bool , column: Int , row: Int ) {
        if point.x >= 0 && point.x < CGFloat( NumColumns ) * tileWidth &&
            point.y >= 0 && point.y < CGFloat( NumRows ) * tileHeight {
                return ( true , Int( point.x / tileWidth ) , Int( point.y / tileHeight ) )
        }else{
            return ( false , 0 , 0 )
        }
    }
    
    override func touchesMoved( touches: NSSet , withEvent event: UIEvent ){
        if swipeFromColumn == nil { return }
        
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode( cookieLayer )
        
        let ( success , column , row ) = convertPoint( location )
        if success {
            var horzDelta = 0 , vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal( horzDelta , vertical: vertDelta )
                hideSelectionIndicator()
                swipeFromColumn = nil
            }
        }
    }
    
    func trySwapHorizontal( horzDelta: Int , vertical vertDelta: Int ){
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        if let toCookie = level.cookieAtPosition( toColumn , row: toRow ){
            if let fromCookie = level.cookieAtPosition( swipeFromColumn! , row: swipeFromRow! ){
//                println( "*** swapping \( fromCookie ) with \( toCookie )" )
                if let handler = swipeHandler {
                    let swap = Swap( cookieA: fromCookie , cookieB: toCookie )
                    handler( swap )
                }
            }
        }
    }
    
    override func touchesEnded( touches: NSSet , withEvent event: UIEvent ){
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled( touches: NSSet , withEvent event: UIEvent ){
        touchesEnded( touches , withEvent: event )
    }
    
    func animateSwap( swap: Swap , completion: () -> () ){
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo( spriteB.position , duration: Duration )
        moveA.timingMode = .EaseOut
        spriteA.runAction( moveA , completion: completion )
        
        let moveB = SKAction.moveTo( spriteA.position , duration: Duration )
        moveB.timingMode = .EaseOut
        spriteB.runAction( moveB )
        
        runAction( swapSound )
    }
    
    func showSelectionIndicatorForCookie( cookie: Cookie ){
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite {
            let texture = SKTexture( imageNamed: cookie.cookieType.highlightedSpriteName )
            selectionSprite.size = texture.size()
            selectionSprite.runAction( SKAction.setTexture( texture ) )
            
            sprite.addChild( selectionSprite )
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.runAction( SKAction.sequence( [
            SKAction.fadeOutWithDuration( 0.3 ) ,
            SKAction.removeFromParent() ] ) )
    }
    
    func animateInvalidSwap( swap: Swap , completion: () -> () ){
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo( spriteB.position , duration: Duration )
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo( spriteA.position , duration: Duration )
        moveB.timingMode = .EaseOut
        
        spriteA.runAction( SKAction.sequence( [ moveA , moveB ] ) , completion: completion )
        spriteB.runAction( SKAction.sequence( [ moveB , moveA ] ) )
        
        runAction( invalidSwapSound )
    }
    
    func animateMatchedCookies( chains: Set<Chain> , completion: () -> () ) {
        for chain in chains {
            for cookie in chain.cookies {
                if let sprite = cookie.sprite {
                    if sprite.actionForKey( "removing" ) == nil {
                        let scaleAction = SKAction.scaleTo( 0.1 , duration: 0.3 )
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction( SKAction.sequence( [
                            scaleAction ,
                            SKAction.removeFromParent() ] ) ,
                            withKey: "removing" )
                    }
                }
            }
        }
        runAction( matchSound )
        runAction( SKAction.waitForDuration( 0.3 ) , completion: completion )
    }
    
    func animateFallingCookies( columns: [[ Cookie ]] , completion: () -> () ) {
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for ( idx , cookie ) in enumerate( array ) {
                let newPosition = pointForCookie( cookie.column , row: cookie.row )
                let delay = 0.05 + 0.15 * NSTimeInterval( idx )
                let sprite = cookie.sprite!
                let duration = NSTimeInterval( ( ( sprite.position.y - newPosition.y ) / tileHeight ) * 0.1 )
                longestDuration = max( longestDuration , duration + delay )
                let moveAction = SKAction.moveTo( newPosition , duration: duration )
                moveAction.timingMode = .EaseOut
                sprite.runAction(
                    SKAction.sequence( [
                        SKAction.waitForDuration( delay ) ,
                        SKAction.group( [ moveAction , fallingCookieSound ] ) ] ) )
            }
        }
        runAction( SKAction.waitForDuration( longestDuration ) , completion: completion )
    }
    
    func animateNewCookies( columns: [[ Cookie ]], completion: () -> () ) {
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            let startRow = array[ 0 ].row + 1
            for ( idx , cookie ) in enumerate( array ) {
                let sprite = SKSpriteNode( imageNamed: cookie.cookieType.spriteName )
                sprite.position = pointForCookie( cookie.column , row: startRow )
                cookieLayer.addChild( sprite )
                cookie.sprite = sprite
                let delay = 0.1 + 0.2 * NSTimeInterval( array.count - idx - 1 )
                let duration = NSTimeInterval( startRow - cookie.row ) * 0.1
                longestDuration = max( longestDuration , duration + delay )
                let newPosition = pointForCookie( cookie.column , row: cookie.row )
                let moveAction = SKAction.moveTo( newPosition , duration: duration )
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(
                    SKAction.sequence( [
                        SKAction.waitForDuration( delay ) ,
                        SKAction.group( [
                            SKAction.fadeInWithDuration( 0.05 ) ,
                            moveAction ,
                            addCookieSound ] )
                        ] ) )
            }
        }
        runAction( SKAction.waitForDuration( longestDuration ) , completion: completion )
    }
}