import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
    if( url == nil ){
        println( "Could not find file: \(filename)" )
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer = AVAudioPlayer( contentsOfURL: url , error: &error )
    if backgroundMusicPlayer == nil {
        println( "Could not create audio player: \(error!)" )
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

func + ( left: CGPoint , right: CGPoint ) -> CGPoint {
    return CGPoint( x: left.x + right.x , y: left.y + right.y )
}

func - ( left: CGPoint , right: CGPoint ) -> CGPoint {
    return CGPoint( x: left.x - right.x , y: left.y - right.y )
}

func * ( point: CGPoint , scalar: CGFloat ) -> CGPoint {
    return CGPoint( x: point.x * scalar , y: point.y * scalar )
}

func / ( point: CGPoint , scalar: CGFloat ) -> CGPoint {
    return CGPoint( x: point.x / scalar , y: point.y / scalar )
}

#if !( arch( x86_64 ) || arch( arm64 ) )
    func sqrt( a: CGFloat ) -> CGFloat {
    return CGFloat( sqrtf( Float( a ) ) )
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt( x * x + y * y )
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

