//
//  LauncherView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import SwiftUI

struct LauncherView: View {
  @Environment(\.openWindow) private var openWindow
  
  private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.9)
  
  var body: some View {
    VStack(spacing: 32) {
      // Header
      VStack(spacing: 8) {
        HStack(spacing: 12) {
          CardIconBadge(icon: "brain.head.profile", color: accentColor, size: .large)

          Text("Neuron Toolkit")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.primary)
        }

        Text("Select a tool to get started")
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(.secondary)
      }
      
      // Tool cards\
      LazyVGrid(columns: [.init(.adaptive(minimum: 180, maximum: 250)),
                          .init(.adaptive(minimum: 180, maximum: 250))],
                alignment: .center,
                spacing: 40) {
        ForEach(ToolDefinition.allTools) { tool in
          ToolCard(tool: tool) {
            openWindow(id: tool.id)
          }
        }
      }
    }
    .padding(40)
  }
    
}

struct ToolCard: View {
  let tool: ToolDefinition
  let action: () -> Void
  
  @State private var isHovered = false
  
  private var toolColor: Color {
    switch tool.id {
    case "visualizer": Color(red: 0.5, green: 0.3, blue: 0.8)
    case "model-playground": Color(red: 0.3, green: 0.6, blue: 0.5)
    case "quantizer": Color(red: 0.8, green: 0.3, blue: 0.3)
    default: Color(red: 0.5, green: 0.5, blue: 0.5)
    }
  }
  
  var body: some View {
    Button(action: action) {
      CardView(style: .default(color: toolColor), isHighlighted: isHovered) {
        VStack(alignment: .leading, spacing: 0) {
          CardHeader(
            icon: tool.icon,
            iconColor: toolColor,
            title: tool.name,
            trailing: AnyView(
              Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(toolColor.opacity(isHovered ? 1.0 : 0.5))
            )
          )

          CardDivider()

          Text(tool.description)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 220)
      }
      .scaleEffect(isHovered ? 1.02 : 1.0)
      .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
    .buttonStyle(.plain)
    .focusEffectDisabled()
    .onHover { hovering in
      isHovered = hovering
    }
  }
}
#Preview {
  LauncherView()
    .frame(width: 700, height: 500)
}

