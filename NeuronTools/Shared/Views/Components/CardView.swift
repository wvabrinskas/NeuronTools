//
//  CardView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/13/26.
//

import SwiftUI

// MARK: - Card Style Configuration

struct CardStyle {
  var accentColor: Color
  var cornerRadius: CGFloat
  var showAccentBar: Bool
  var borderStyle: BorderStyle
  var shadowIntensity: ShadowIntensity
  
  enum BorderStyle {
    case solid
    case dashed(dash: [CGFloat], phase: CGFloat)
  }
  
  enum ShadowIntensity {
    case none
    case subtle
    case medium
    case strong
    
    var radius: CGFloat {
      switch self {
      case .none: 0
      case .subtle: 4
      case .medium: 8
      case .strong: 12
      }
    }
    
    var opacity: CGFloat {
      switch self {
      case .none: 0
      case .subtle: 0.1
      case .medium: 0.2
      case .strong: 0.3
      }
    }
  }
  
  static func `default`(color: Color = .blue) -> CardStyle {
    CardStyle(
      accentColor: color,
      cornerRadius: 16,
      showAccentBar: true,
      borderStyle: .solid,
      shadowIntensity: .medium
    )
  }
  
  static func dashed(color: Color = .blue, phase: CGFloat = 0) -> CardStyle {
    CardStyle(
      accentColor: color,
      cornerRadius: 16,
      showAccentBar: true,
      borderStyle: .dashed(dash: [8, 6], phase: phase),
      shadowIntensity: .medium
    )
  }
  
  static func compact(color: Color = .blue) -> CardStyle {
    CardStyle(
      accentColor: color,
      cornerRadius: 12,
      showAccentBar: false,
      borderStyle: .solid,
      shadowIntensity: .subtle
    )
  }
}

// MARK: - Card View

struct CardView<Content: View>: View {
  let style: CardStyle
  let isHighlighted: Bool
  @ViewBuilder let content: () -> Content
  
  init(
    style: CardStyle = .default(),
    isHighlighted: Bool = false,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.style = style
    self.isHighlighted = isHighlighted
    self.content = content
  }
  
  private var effectiveOpacity: (border: CGFloat, shadow: CGFloat) {
    isHighlighted ? (0.7, style.shadowIntensity.opacity * 1.5) : (0.4, style.shadowIntensity.opacity)
  }
  
  var body: some View {
    content()
      .background(
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
          .fill(.ultraThinMaterial)
          .shadow(
            color: style.accentColor.opacity(effectiveOpacity.shadow),
            radius: isHighlighted ? style.shadowIntensity.radius * 1.5 : style.shadowIntensity.radius,
            x: 0,
            y: 4
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
          .stroke(
            LinearGradient(
              colors: [
                style.accentColor.opacity(effectiveOpacity.border),
                style.accentColor.opacity(effectiveOpacity.border * 0.4)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            style: strokeStyle
          )
      )
      .overlay(alignment: .leading) {
        if style.showAccentBar {
          RoundedRectangle(cornerRadius: 2)
            .fill(style.accentColor.gradient)
            .frame(width: 4)
            .padding(.vertical, 12)
            .padding(.leading, 2)
            .opacity(isHighlighted ? 1.0 : 0.7)
        }
      }
  }
  
  private var strokeStyle: StrokeStyle {
    switch style.borderStyle {
    case .solid:
      return StrokeStyle(lineWidth: 1.5)
    case .dashed(let dash, let phase):
      return StrokeStyle(lineWidth: 2, dash: dash, dashPhase: phase)
    }
  }
}

// MARK: - Card Header

struct CardHeader: View {
  let icon: String
  let iconColor: Color
  let title: String
  let subtitle: String?
  let trailing: AnyView?
  
  init(
    icon: String,
    iconColor: Color,
    title: String,
    subtitle: String? = nil,
    trailing: AnyView? = nil
  ) {
    self.icon = icon
    self.iconColor = iconColor
    self.title = title
    self.subtitle = subtitle
    self.trailing = trailing
  }
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 18, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 36, height: 36)
        .background(
          Circle()
            .fill(iconColor.gradient)
        )
      
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.primary)
        
        if let subtitle {
          Text(subtitle)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
        }
      }
      
      Spacer()
      
      if let trailing {
        trailing
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}

// MARK: - Card Badge

struct CardBadge: View {
  let text: String
  let color: Color
  let trailingIcon: String?
  
  init(text: String, color: Color, trailingIcon: String? = nil) {
    self.text = text
    self.color = color
    self.trailingIcon = trailingIcon
  }
  
  var body: some View {
    HStack {
      Text(text)
        .font(.system(size: 10, weight: .bold, design: .monospaced))
        .foregroundStyle(color)
      
      if let trailingIcon {
        Image(systemName: trailingIcon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 10, height: 10)
          .foregroundStyle(color)
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      Capsule()
        .fill(color.opacity(0.15))
    )
  }
}

// MARK: - Card Icon Badge

struct CardIconBadge: View {
  let icon: String
  let color: Color
  let size: Size
  
  enum Size {
    case small
    case medium
    case large
    
    var iconSize: CGFloat {
      switch self {
      case .small: 14
      case .medium: 18
      case .large: 24
      }
    }
    
    var frameSize: CGFloat {
      switch self {
      case .small: 28
      case .medium: 36
      case .large: 48
      }
    }
  }
  
  init(icon: String, color: Color, size: Size = .medium) {
    self.icon = icon
    self.color = color
    self.size = size
  }
  
  var body: some View {
    Image(systemName: icon)
      .font(.system(size: size.iconSize, weight: .semibold))
      .foregroundStyle(.white)
      .frame(width: size.frameSize, height: size.frameSize)
      .background(
        Circle()
          .fill(color.gradient)
      )
  }
}

// MARK: - Card Divider

struct CardDivider: View {
  var body: some View {
    Divider()
      .background(Color.primary.opacity(0.1))
  }
}

// MARK: - Card Stat Item

struct CardStatItem: View {
  let label: String
  let value: String
  let icon: String?
  
  init(label: String, value: String, icon: String? = nil) {
    self.label = label
    self.value = value
    self.icon = icon
  }
  
  var body: some View {
    HStack(spacing: 8) {
      if let icon {
        Image(systemName: icon)
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
      }
      
      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.system(size: 9, weight: .medium))
          .foregroundStyle(.secondary)
        Text(value)
          .font(.system(size: 12, weight: .semibold, design: .monospaced))
          .foregroundStyle(.primary)
      }
      
      Spacer()
    }
  }
}

// MARK: - Card Flow Item (Input -> Output)

struct CardFlowItem: View {
  let inputLabel: String
  let inputValue: String
  let outputLabel: String
  let outputValue: String
  let arrowColor: Color
  
  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .center, spacing: 4) {
        Text(inputLabel)
          .font(.system(size: 9, weight: .medium))
          .foregroundStyle(.secondary)
        Text(inputValue)
          .font(.system(size: 12, weight: .semibold, design: .monospaced))
          .foregroundStyle(.primary)
      }
      .frame(maxWidth: .infinity)
      
      Image(systemName: "arrow.right")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(arrowColor)
        .frame(width: 30)
      
      VStack(alignment: .center, spacing: 4) {
        Text(outputLabel)
          .font(.system(size: 9, weight: .medium))
          .foregroundStyle(.secondary)
        Text(outputValue)
          .font(.system(size: 12, weight: .semibold, design: .monospaced))
          .foregroundStyle(.primary)
      }
      .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
  }
}

// MARK: - Pill Card (for compact items like activation layers)

struct PillCardView<Content: View>: View {
  let style: CardStyle
  let isHighlighted: Bool
  @ViewBuilder let content: () -> Content
  
  init(
    style: CardStyle = .default(),
    isHighlighted: Bool = false,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.style = style
    self.isHighlighted = isHighlighted
    self.content = content
  }
  
  private var effectiveOpacity: CGFloat {
    isHighlighted ? 0.6 : 0.4
  }
  
  var body: some View {
    content()
      .background(
        Capsule()
          .fill(.ultraThinMaterial)
          .shadow(
            color: style.accentColor.opacity(style.shadowIntensity.opacity),
            radius: style.shadowIntensity.radius,
            x: 0,
            y: 3
          )
      )
      .overlay(
        Capsule()
          .stroke(
            LinearGradient(
              colors: [
                style.accentColor.opacity(effectiveOpacity),
                style.accentColor.opacity(effectiveOpacity * 0.4)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            style: strokeStyle
          )
      )
  }
  
  private var strokeStyle: StrokeStyle {
    switch style.borderStyle {
    case .solid:
      return StrokeStyle(lineWidth: 1.5)
    case .dashed(let dash, let phase):
      return StrokeStyle(lineWidth: 1.5, dash: dash, dashPhase: phase)
    }
  }
}

// MARK: - Previews

#Preview("Card Styles") {
  VStack(spacing: 20) {
    // Default card
    CardView(style: .default(color: .blue)) {
      VStack(alignment: .leading, spacing: 0) {
        CardHeader(
          icon: "brain",
          iconColor: .blue,
          title: "Neural Network",
          subtitle: "Deep Learning Model",
          trailing: AnyView(CardBadge(text: "65.5K", color: .blue))
        )
        CardDivider()
        CardFlowItem(
          inputLabel: "Input",
          inputValue: "224×224×3",
          outputLabel: "Output",
          outputValue: "1000",
          arrowColor: .blue
        )
      }
      .frame(width: 300)
    }
    
    // Dashed card
    CardView(style: .dashed(color: .green)) {
      VStack(spacing: 16) {
        CardIconBadge(icon: "arrow.down.doc.fill", color: .green, size: .large)
        Text("Drop File Here")
          .font(.system(size: 14, weight: .semibold))
      }
      .padding(24)
    }
    
    // Pill card
    PillCardView(style: .dashed(color: .orange)) {
      HStack(spacing: 10) {
        CardIconBadge(icon: "bolt.fill", color: .orange, size: .small)
        Text("ReLU")
          .font(.system(size: 14, weight: .semibold))
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
    }
    
    CardBadge(text: "Classifier", color: .blue, trailingIcon: "chevron.down")
  }
  .padding(40)
  .background(Color(NSColor.windowBackgroundColor))
}
