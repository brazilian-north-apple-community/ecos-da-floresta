import SpriteKit
import SwiftUI

@main
struct EcosDaFlorestaApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}

private struct GameView: View {
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 1, height: 1))
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: GameScene.title))
    }
}
