extension Double {
    func absoluteValue() -> Double {
        return ( self < 0 ? -self : self )
    }
}

(-12.1).absoluteValue()