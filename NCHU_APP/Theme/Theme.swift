import SwiftUI

enum Theme {
    enum Colors {
        static let primary = Color(red: 0.0, green: 0.478, blue: 1.0)
        static let primaryDark = Color(red: 0.0, green: 0.4, blue: 0.9)
        static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
        static let cardBackground = Color.white
        static let textPrimary = Color.black
        static let textSecondary = Color.gray
        static let iconColor = Color.gray
        static let border = Color(red: 0.9, green: 0.9, blue: 0.9)
    }
    
    enum Gradients {
        static let primaryButton = LinearGradient(
            gradient: Gradient(colors: [Colors.primary, Colors.primaryDark]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        static let fadeWhite = LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0), Color.white]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    enum Shadows {
        static let small = Shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        static let large = Shadow(color: Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 16
        static let iconSize: CGFloat = 20
    }
    
    enum FontSize {
        static let small: CGFloat = 14
        static let regular: CGFloat = 16
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 28
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func primaryButtonStyle() -> some View {
        self.font(.system(size: Theme.FontSize.regular, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Theme.Gradients.primaryButton)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(
                color: Theme.Shadows.large.color,
                radius: Theme.Shadows.large.radius,
                x: Theme.Shadows.large.x,
                y: Theme.Shadows.large.y
            )
    }
    
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(
                color: Theme.Shadows.small.color,
                radius: Theme.Shadows.small.radius,
                x: Theme.Shadows.small.x,
                y: Theme.Shadows.small.y
            )
    }
    
    func inputFieldStyle() -> some View {
        self.padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.white)
            .cornerRadius(Theme.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
    }
    
    func linkButtonStyle() -> some View {
        self
            .padding(.horizontal, Theme.Layout.padding)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.Layout.cornerRadius)
    }
    
    func homeworkItemStyle() -> some View {
        self
            .padding(.horizontal, Theme.Layout.padding)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.Layout.cornerRadius)
    }
} 