import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    
    var movesLeft = 0
    var score = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int( UIInterfaceOrientationMask.AllButUpsideDown.toRaw() )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        scene = GameScene( size: skView.bounds.size )
        scene.scaleMode = .AspectFill
        
        level = Level( filename: "Level_3" )
        scene.level = level
        scene.addTiles()
        
        scene.swipeHandler = handleSwipe
        
        skView.presentScene( scene )
        
        beginGame()
    }
    
    func beginGame(){
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        shuffle()
    }
    
    func shuffle(){
        let cookies = level.shuffle()
        scene.addSpritesForCookies( cookies )
    }
    
    func handleSwipe( swap: Swap ) {
        view.userInteractionEnabled = false
        if level.isPossibleSwap( swap ) {
            level.performSwap( swap )
            scene.animateSwap( swap , completion: handleMatches )
        }else{
            scene.animateInvalidSwap( swap ){
                self.view.userInteractionEnabled = true
            }
        }
    }
 
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies( chains ) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies( columns ) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies( columns ) {
                    self.handleMatches()
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
    }
    
    func updateLabels() {
        targetLabel.text = NSString( format: "%ld" , level.targetScore )
        movesLabel.text = NSString( format: "%ld" , movesLeft )
        scoreLabel.text = NSString( format: "%ld" , score )
    }
}