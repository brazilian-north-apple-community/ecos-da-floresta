import AVFoundation
import GameplayKit
import SpriteKit

final class GameScene: SKScene {
    static let title = "Ecos da Floresta"

    private let spatialAudio = SpatialAudioSystem()
    private var entities: [GKEntity] = []
    private var listenerArrow: SKShapeNode?

    // audio (x, y, z) → screen (x, -z): z negativo é "para cima" na tela
    private let soundSources: [(file: String, position: AVAudio3DPoint, color: SKColor, label: String)] = [
        ("cobra.mp3",           .init(x: -140, y: 0, z:    0), .systemRed,    "cobra"),
        ("sapo.mp3",            .init(x:  140, y: 0, z:    0), .systemGreen,  "sapo"),
        ("passaro_longe.mp3",   .init(x:    0, y: 0, z: -260), .systemBlue,   "pássaro longe"),
        ("passaro_dnv.mp3",     .init(x:    0, y: 0, z:  -90), .systemCyan,   "pássaro perto"),
        ("quebrando_galho.mp3", .init(x: -120, y: 0, z:  130), .systemOrange, "galho"),
        ("agua_caverna.mp3",    .init(x:    0, y: 0, z:  220), .systemPurple, "caverna"),
    ]

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = SKColor(red: 0.05, green: 0.1, blue: 0.05, alpha: 1)

        setupSoundEntities()
        setupListener()
        addInstructions()
        spatialAudio.start()
    }

    // MARK: - Entity registration

    // Single entry point: add an entity to the scene and auto-register
    // its components with every system. As new systems are added to the
    // game (physics, AI, etc.), wire them up here — callers never change.
    private func addEntity(_ entity: GKEntity) {
        entities.append(entity)

        if let audio = entity.component(ofType: AudioSourceComponent.self) {
            spatialAudio.addSource(audio)
        }
        if let listener = entity.component(ofType: ListenerComponent.self) {
            spatialAudio.setListener(listener)
        }
        if let node = entity.component(ofType: GKSKNodeComponent.self) {
            addChild(node.node)
        }
    }

    func removeEntity(_ entity: GKEntity) {
        if let audio = entity.component(ofType: AudioSourceComponent.self) {
            spatialAudio.removeSource(audio)
        }
        if let node = entity.component(ofType: GKSKNodeComponent.self) {
            node.node.removeFromParent()
        }
        entities.removeAll { $0 === entity }
    }

    // MARK: - Setup

    private func setupSoundEntities() {
        for source in soundSources {
            let entity = GKEntity()
            entity.addComponent(AudioSourceComponent(fileName: source.file, position: source.position))
            addEntity(entity)

            let dot = SKShapeNode(circleOfRadius: 12)
            dot.fillColor = source.color
            dot.strokeColor = .white
            dot.lineWidth = 1.5
            dot.position = CGPoint(x: CGFloat(source.position.x), y: -CGFloat(source.position.z))
            addChild(dot)

            let nameLabel = SKLabelNode(text: source.label)
            nameLabel.fontSize = 11
            nameLabel.fontColor = source.color
            nameLabel.position = CGPoint(x: dot.position.x, y: dot.position.y - 22)
            addChild(nameLabel)
        }
    }

    private func setupListener() {
        let arrow = makeArrow()
        arrow.position = .zero
        addChild(arrow)
        listenerArrow = arrow

        let entity = GKEntity()
        entity.addComponent(ListenerComponent(node: arrow))
        addEntity(entity)
    }

    private func makeArrow() -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 22))
        path.addLine(to: CGPoint(x: -11, y: -11))
        path.addLine(to: CGPoint(x: 0, y: -5))
        path.addLine(to: CGPoint(x: 11, y: -11))
        path.closeSubpath()
        let shape = SKShapeNode(path: path)
        shape.fillColor = .white
        shape.strokeColor = .clear
        return shape
    }

    private func addInstructions() {
        let label = SKLabelNode(text: "arrasta para mover o ouvido")
        label.fontSize = 13
        label.fontColor = .lightGray
        label.position = CGPoint(x: 0, y: -(frame.height / 2) + 40)
        addChild(label)
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        spatialAudio.update()
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveListener(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveListener(touches)
    }

    private func moveListener(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let cur = touch.location(in: self)
        let prev = touch.previousLocation(in: self)
        listenerArrow?.position.x += cur.x - prev.x
        listenerArrow?.position.y += cur.y - prev.y
    }
}
