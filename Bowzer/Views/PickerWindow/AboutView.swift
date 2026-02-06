import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "safari")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Bowzer")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Browser Picker for macOS")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Version 1.0")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    AboutView()
}
