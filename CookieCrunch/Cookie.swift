import SpriteKit

enum CookieType: Int , Printable {
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie
    
    var description : String {
        return spriteName ;
    }
    
    var spriteName: String {
        let spriteNames = [ "Croissant" , "Cupcake" , "Danish" ,
                            "Donut" , "Macaroon" , "SugarCookie" ]
            return spriteNames[ toRaw() - 1 ]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> CookieType {
        return CookieType.fromRaw( Int( arc4random_uniform( 6 ) ) + 1 )!
    }
}

class Cookie : Printable , Hashable {
    var column: Int
    var row: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode?
    
    var description: String {
        return "type: \(cookieType), square =(\(row),\(column))"
    }
    
    var hashValue: Int {
        return row * 10 + column
    }
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }
}

func ==( c1: Cookie, c2: Cookie ) -> Bool {
    return c1.column == c2.column && c1.row == c2.row
}
