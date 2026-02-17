//
//  DragModelView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/13/26.
//

import SwiftUI
@_spi(Visualizer) import Neuron

struct DragModelView: View {
  @State private var viewModel: ModelDropViewModel
  @State private var module: ModelDropModule
  
  private let accentColor = Color(red: 0.4, green: 0.6, blue: 0.9)
  
  init(module: ModelDropModule = .init(builder: Builder())) {
    self.module = module
    self.viewModel = module.viewModel
  }
  
  private var isActive: Bool {
    viewModel.dropState == .enter
  }
  
  private var cardStyle: CardStyle {
    .dashed(color: accentColor, phase: viewModel.dashPhase)
  }
  
  var body: some View {
    CardView(style: cardStyle, isHighlighted: isActive) {
      HStack(spacing: 16) {
        CardIconBadge(icon: "arrow.down.doc.fill",
                      color: accentColor,
                      size: .large)
          .scaleEffect(isActive ? 1.1 : 1.0)
        
        VStack(alignment: .leading, spacing: 6) {
          Text("Drop Neuron Model")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
          
          Text("Drag and drop a .smodel file")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 40)
      .padding(.vertical, 21)
    }
    .scaleEffect(isActive ? 1.02 : 1.0)
    .animation(.easeInOut(duration: 0.2), value: isActive)
    .onDrop(of: [.data], delegate: module)
  }
}

#Preview {
  DragModelView()
    .padding(40)
    .background(Color(NSColor.windowBackgroundColor))
}
