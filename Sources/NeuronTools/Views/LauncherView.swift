//
//  LauncherView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import SwiftUI

struct LauncherView: View {
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(spacing: 24) {
      Text("NeuronTools")
        .font(.largeTitle)
        .bold()

      Text("Select a tool to get started")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      HStack(spacing: 20) {
        ForEach(ToolDefinition.allTools) { tool in
          Button {
            openWindow(id: tool.id)
          } label: {
            VStack(spacing: 8) {
              Image(systemName: tool.icon)
                .font(.system(size: 32))
              Text(tool.name)
                .font(.headline)
              Text(tool.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .frame(width: 160, height: 120)
          }
          .buttonStyle(.bordered)
        }
      }
    }
    .padding(40)
  }
}
