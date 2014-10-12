enum Suit {
    case Spades , Hearts , Diamonds , Clubs
    
    func simpleDescription() -> String {
        switch( self ){
        case .Spades: return "spades"
        case .Hearts: return "hearts"
        case .Diamonds: return "diamonds"
        case .Clubs: return "clubs"
        }
    }
    
    func color() -> String {
        switch( self ){
        case .Spades , .Clubs: return "black"
        case .Hearts , .Diamonds: return "red"
        }
    }
    
    static func list() -> [Suit] {
        var lst = [Suit]()
        lst.append( .Spades )
        lst.append( .Hearts )
        lst.append( .Diamonds )
        lst.append( .Clubs )
        return lst
    }
}

enum Rank : Int {
    case Ace = 1
    case Two , Three , Four , Five , Six , Seven , Eigth , Nine , Ten
    case Jack , Queen , King
    
    func simpleDescription() -> String {
        switch( self ){
        case .Ace: return "ace"
        case .Jack: return "jack"
        case .Queen: return "queen"
        case .King: return "king"
        default: return String( self.toRaw() )
        }
    }
    
    static func list() -> [Rank] {
        var lst = [Rank]()
        for x in 1...13 {
            lst.append( Rank.fromRaw( x )! )
        }
        return lst
    }
}

struct Card {
    var rank : Rank
    var suit : Suit
    
    func simpleDescription() -> String {
        return "The card is \(rank.simpleDescription()) of \(suit.simpleDescription())"
    }
    
    static func createDeck() -> [Card] {
        var deck = [Card]()
        var ranks = Rank.list()
        var suits = Suit.list()
        for s in suits {
            for r in ranks {
                deck.append( Card( rank: r , suit: s ) )
            }
        }
        return deck
    }
}

var hearts = Suit.Hearts
hearts.simpleDescription()
hearts.color()

var card = Card( rank: .Ace , suit : .Spades )
card.simpleDescription()
var deck = Card.createDeck()
for c in deck {
    c.simpleDescription()
}
