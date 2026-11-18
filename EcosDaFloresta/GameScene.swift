import GameplayKit
import SpriteKit

final class GameScene: SKScene {
    static let title = "Ecos da Floresta"

    private let titleEntity = GKEntity()
    private let renderSystem = GKComponentSystem<GKSKNodeComponent>(
        componentClass: GKSKNodeComponent.self
    )

    override func didMove(to view: SKView) {
        guard renderSystem.components.isEmpty else { return }

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .black

        let label = SKLabelNode(fontNamed: "HelveticaNeue")
        label.text = Self.title
        label.fontSize = 32
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        let renderComponent = GKSKNodeComponent(node: label)
        titleEntity.addComponent(renderComponent)
        renderSystem.addComponent(renderComponent)

        for component in renderSystem.components {
            addChild(component.node)
        }
    }
}
