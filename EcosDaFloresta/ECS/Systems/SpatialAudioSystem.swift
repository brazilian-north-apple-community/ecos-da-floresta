import AVFoundation
import GameplayKit
import SpriteKit

final class SpatialAudioSystem {
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private var sources: [AudioSourceComponent] = []
    private var listener: ListenerComponent?

    init() {
        configureAudioSession()
        engine.attach(environment)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        environment.reverbParameters.enable = true
        environment.reverbParameters.level = -20
    }

    private func configureAudioSession() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }

    // MARK: - Setup

    func addSource(_ source: AudioSourceComponent) {
        sources.append(source)
        engine.attach(source.playerNode)
        let format = source.audioFile?.processingFormat
            ?? AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(source.playerNode, to: environment, format: format)
        source.playerNode.position = source.position
        source.playerNode.renderingAlgorithm = .HRTFHQ
    }

    func removeSource(_ source: AudioSourceComponent) {
        source.playerNode.stop()
        engine.disconnectNodeOutput(source.playerNode)
        engine.detach(source.playerNode)
        sources.removeAll { $0 === source }
    }

    func setListener(_ listener: ListenerComponent) {
        self.listener = listener
    }

    // MARK: - Playback

    func start() {
        guard !engine.isRunning else { return }
        try? engine.start()
        for source in sources {
            guard source.audioFile != nil else { continue }
            schedule(source: source)
            source.playerNode.play()
        }
    }

    func play(_ source: AudioSourceComponent) {
        guard engine.isRunning, source.audioFile != nil else { return }
        schedule(source: source)
        source.playerNode.play()
    }

    func stop(_ source: AudioSourceComponent) {
        source.playerNode.stop()
    }

    // MARK: - Update

    func update() {
        syncNodePositions()
        guard let listener else { return }
        environment.listenerPosition = listener.position
        environment.listenerAngularOrientation = listener.angularOrientation
        for source in sources {
            source.playerNode.position = source.position
            source.playerNode.volume = volume(from: listener.position, to: source)
        }
    }

    // MARK: - Private

    private func syncNodePositions() {
        if let node = listener?.node {
            listener?.position = AVAudio3DPoint(x: Float(node.position.x), y: 0, z: -Float(node.position.y))
            listener?.yaw = -Float(node.zRotation) * 180 / .pi
        }
        for source in sources {
            guard let node = source.node else { continue }
            source.position = AVAudio3DPoint(x: Float(node.position.x), y: 0, z: -Float(node.position.y))
        }
    }

    // Tries gapless buffer loop first; falls back to completion-handler loop for formats
    // where AVAudioFile.length is imprecise (e.g. VBR MP3).
    private func schedule(source: AudioSourceComponent) {
        guard let file = source.audioFile else { return }
        file.framePosition = 0

        if source.loops,
           let buffer = AVAudioPCMBuffer(
               pcmFormat: file.processingFormat,
               frameCapacity: AVAudioFrameCount(file.length)
           ),
           (try? file.read(into: buffer)) != nil,
           buffer.frameLength > 0 {
            source.playerNode.scheduleBuffer(buffer, at: nil, options: .loops)
            return
        }

        source.playerNode.scheduleFile(file, at: nil) { [weak self, weak source] in
            guard let self, let source, source.loops else { return }
            self.schedule(source: source)
        }
    }

    private func volume(from listener: AVAudio3DPoint, to source: AudioSourceComponent) -> Float {
        let dx = source.position.x - listener.x
        let dy = source.position.y - listener.y
        let dz = source.position.z - listener.z
        let dist = max(sqrt(dx*dx + dy*dy + dz*dz), 1)
        return min(1.0, pow(source.referenceDistance / dist, 2.0))
    }
}
