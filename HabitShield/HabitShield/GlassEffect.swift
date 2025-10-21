import SwiftUI

extension View {
    func glassEffect(in shape: some Shape) -> some View {
        self
            .background(
                shape
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}
