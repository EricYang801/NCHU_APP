import SwiftUI

// MARK: - Navigation Bar
struct NavigationBarView: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("返回")
                            .font(.system(size: Theme.FontSize.regular))
                    }
                    .foregroundColor(Theme.Colors.primary)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text(title)
                .font(.system(size: Theme.FontSize.regular, weight: .semibold))
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(
            color: Theme.Shadows.medium.color,
            radius: Theme.Shadows.medium.radius,
            x: Theme.Shadows.medium.x,
            y: Theme.Shadows.medium.y
        )
    }
}

// MARK: - Input Fields
struct InputField: View {
    let title: String
    let placeholder: String
    let icon: String
    let isSecure: Bool
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: Theme.FontSize.small, weight: .medium))
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: Theme.Layout.iconSize))
                    .foregroundColor(Theme.Colors.iconColor)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: Theme.FontSize.regular))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: Theme.FontSize.regular))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
            .inputFieldStyle()
        }
    }
}

// MARK: - Buttons
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .primaryButtonStyle()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
        .disabled(isLoading)
    }
}

struct LinkButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: Theme.Layout.iconSize))
                    .foregroundColor(Theme.Colors.iconColor)
                Text(title)
                    .font(.system(size: Theme.FontSize.regular))
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.FontSize.small))
                    .foregroundColor(Theme.Colors.iconColor)
            }
            .linkButtonStyle()
        }
    }
}

// MARK: - Cards
struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Colors.iconColor)
                Text(title)
                    .font(.system(size: Theme.FontSize.regular, weight: .medium))
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            content
        }
        .cardStyle()
    }
}

// MARK: - Section Views
struct SettingSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: Theme.FontSize.regular, weight: .semibold))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.leading, 4)
            
            content
                .cardStyle()
        }
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
} 