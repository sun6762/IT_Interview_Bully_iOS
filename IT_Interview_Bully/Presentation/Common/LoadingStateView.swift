import SwiftUI

struct LoadingStateView: View {
    let title: String
    let systemImageName: String
    let tintColor: Color

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImageName)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(tintColor)

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

