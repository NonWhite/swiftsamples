import Darwin

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
        return Int( arc4random_uniform( 6 ) ) + 1 ;
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

Dice.rollDice()
var mydice = Dice()

mydice.rotateDown()
mydice.getUpperFace()

mydice.rotateLeft()
mydice.getUpperFace()

mydice.rotateUp()
mydice.getUpperFace()

mydice.rotateRight()
mydice.getUpperFace()
