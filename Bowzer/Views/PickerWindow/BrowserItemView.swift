import SwiftUI

struct BrowserItemView: View {
    let item: BrowserDisplayItem
    let index: Int
    let isHovered: Bool
    let showLabel: Bool
    let hasAnyLabels: Bool  // Whether any item in the picker has labels
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(nsImage: item.browser.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: isHovered)

                    // Keyboard shortcut badge
                    if index <= 9 {
                        Text("\(index)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.7))
                            )
                            .offset(x: 4, y: -4)
                    }
                }

                // Label or spacer for alignment
                if hasAnyLabels {
                    Text(showLabel ? (item.profile?.truncatedName ?? "") : " ")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: 60)
                        .opacity(showLabel ? 1 : 0)
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.gray.opacity(0.2) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
