import AVFoundation
import GameplayKit
import SpriteKit

final class AudioSourceComponent: GKComponent {
    let playerNode = AVAudioPlayerNode()
    let audioFile: AVAudioFile?
    let loops: Bool
    let referenceDistance: Float
    var position: AVAudio3DPoint

    // When set, position is auto-synced from this node every update.
    weak var node: SKNode?

    init(
        fileName: String,
        position: AVAudio3DPoint = .init(x: 0, y: 0, z: 0),
        node: SKNode? = nil,
        loops: Bool = true,
        referenceDistance: Float = 30
    ) {
        self.loops = loops
        self.referenceDistance = referenceDistance
        self.node = node
        self.position = node.map { .init(x: Float($0.position.x), y: 0, z: -Float($0.position.y)) } ?? position
        let url = URL(fileURLWithPath: fileName)
        let resolved = Bundle.main.url(
            forResource: url.deletingPathExtension().lastPathComponent,
            withExtension: url.pathExtension,
            subdirectory: "Audio"
        ) ?? Bundle.main.url(
            forResource: url.deletingPathExtension().lastPathComponent,
            withExtension: url.pathExtension
        )
        assert(resolved != nil, "Audio file not found in bundle: \(fileName)")
        self.audioFile = resolved.flatMap { try? AVAudioFile(forReading: $0) }
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
}
