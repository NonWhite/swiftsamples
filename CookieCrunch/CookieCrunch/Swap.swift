struct Swap: Printable, Hashable {
    let cookieA: Cookie
    let cookieB: Cookie
    
    var hashValue: Int {
        return cookieA.hashValue ^ cookieB.hashValue
    }
    
    init( cookieA: Cookie , cookieB: Cookie ){
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}

func ==( s1: Swap , s2: Swap ) -> Bool {
    return ( s1.cookieA == s2.cookieA && s1.cookieB == s2.cookieB ) ||
        ( s1.cookieB == s2.cookieA && s1.cookieA == s2.cookieB )
}