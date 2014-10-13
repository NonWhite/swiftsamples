import Darwin

class Utils {
    class func random( maxVal : Int ) -> Int { // between 0 and maxVal
        return Int( arc4random_uniform( UInt32( maxVal ) + 1 ) )
    }
    
    class func random( minVal : Int , maxVal : Int ) -> Int { // between minVal and maxVal
        return random( maxVal - minVal ) + minVal
    }
}

class Dice {
    var centervals : [Int]
    var leftval : Int
    var rightval : Int
    
    init(){
        centervals = [Int]( count: 4 , repeatedValue: 0 )
        centervals[ 0 ] = 3         //    3
        centervals[ 1 ] = 1         //  2 1 5
        centervals[ 2 ] = 4         //    4
        centervals[ 3 ] = 6         //    6
        leftval = 2
        rightval = 5
    }
    
    class func rollDice() -> Int {
        return Utils.random( 1 , maxVal: 6 )
    }
    
    func rotateLeft() {
        var aux = centervals[ 1 ]
        centervals[ 1 ] = rightval
        rightval = leftval
        leftval = aux
    }
    
    func rotateRight() {
        var aux = centervals[ 1 ]
        centervals[ 1 ] = leftval
        leftval = rightval
        rightval = aux
    }
    
    func rotateUp() {
        centervals.append( centervals.first! )
        centervals.removeAtIndex( 0 )
    }
    
    func rotateDown() {
        centervals.insert( centervals.last! , atIndex: 0 )
        centervals.removeLast()
    }
    
    func getUpperFace() -> Int {
        return centervals[ 1 ] ;
    }
}

class Game {
    var board : [Int]
    var player : Int
    var playerPosition : [Int]
    private let sizeOfBoard = 30
    private let maxNumberOfPlayers = 2
    private let maxNumberOfSnakes = 4
    private let maxNumberOfLadders = 4
    private let maxLengthForJump = 10
    
    init(){
        player = 0
        playerPosition = [Int]( count: 2 , repeatedValue: 0 )
        board = [Int]()
        board = generateBoard()
    }
    
    private func generateBoard() -> [Int] {
        var table = [Int]( count: sizeOfBoard , repeatedValue: 0 )
        for i in 1...maxNumberOfSnakes {
            var move = Utils.random( maxLengthForJump )
            var pos = Utils.random( move , maxVal: sizeOfBoard - 2 )
            table[ pos ] = -move
        }
        for i in 1...maxNumberOfLadders {
            var move = Utils.random( maxLengthForJump )
            var pos = Utils.random( 0 , maxVal: sizeOfBoard - move )
            table[ pos ] = move
        }
        for i in 0..<sizeOfBoard {
            print( "\(table[ i ]) " )
        }
        println()
        return table
    }
    
    func nextTurn(){
        player = ( player + 1 ) % maxNumberOfPlayers
    }
    
    func play() -> Int {
        var move = Dice.rollDice()
        var newPos = playerPosition[ player ] + move
        println( "Player #\(player) is in \(playerPosition[ player ]) and has \(move) in dice, moves to \(newPos)" )
        if( newPos >= sizeOfBoard ){
            println( "Player #\(player) has won" )
            return player // In case player wins
        }
        if( board[ newPos ] != 0 ){
            let typeOfCell = board[ newPos ] < 0 ? "snake" : "ladder"
            println( "Player #\(player) is in a \(typeOfCell), has to move to \( newPos + board[ newPos ] )" )
            newPos += board[ newPos ]
        }
        playerPosition[ player ] = newPos
        if( newPos >= sizeOfBoard ){
            println( "Player #\(player) has won" )
            return player // In case player wins
        }
        return -1
    }
}

var game = Game()

while( game.play() < 0 ){
    game.nextTurn()
}