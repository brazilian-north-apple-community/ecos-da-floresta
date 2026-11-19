import AVFoundation
import GameplayKit
import SpriteKit

final class ListenerComponent: GKComponent {
    var position: AVAudio3DPoint
    // degrees; positive = counterclockwise from above (facing -z = "screen up" at 0°)
    var yaw: Float

    // When set, position and yaw are auto-synced from this node every update.
    weak var node: SKNode?

    var angularOrientation: AVAudio3DAngularOrientation {
        AVAudio3DAngularOrientation(yaw: yaw, pitch: 0, roll: 0)
    }

    init(
        position: AVAudio3DPoint = .init(x: 0, y: 0, z: 0),
        yaw: Float = 0,
        node: SKNode? = nil
    ) {
        self.position = position
        self.yaw = yaw
        self.node = node
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}
