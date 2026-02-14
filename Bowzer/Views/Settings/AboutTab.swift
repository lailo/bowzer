import SwiftUI

struct AboutTab: View {
    private let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            Text("Bowzer")
                .font(.title)
                .fontWeight(.bold)

            Text("about.version \(version) (\(build))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("about.appDescription")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(24)
        .frame(width: 300, height: 200)
    }
}
