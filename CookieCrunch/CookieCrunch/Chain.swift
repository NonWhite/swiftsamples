class Chain: Hashable, Printable {
    var cookies = [ Cookie ]()
    
    var score = 0
    
    enum ChainType: Printable {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
                case .Horizontal: return "Horizontal"
                case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init( chainType: ChainType ) {
        self.chainType = chainType
    }
    
    func addCookie( cookie: Cookie ) {
        cookies.append( cookie )
    }
    
    func firstCookie() -> Cookie {
        return cookies[ 0 ]
    }
    
    func lastCookie() -> Cookie {
        return cookies[ cookies.count - 1 ]
    }
    
    var length: Int {
        return cookies.count
    }
    
    var description: String {
        return "type:\(chainType) cookies:\(cookies)"
    }
    
    var hashValue: Int {
        return reduce( cookies , 0 ) { $0.hashValue ^ $1.hashValue }
    }
}

func ==( c1: Chain, c2: Chain ) -> Bool {
    return c1.cookies == c2.cookies
}