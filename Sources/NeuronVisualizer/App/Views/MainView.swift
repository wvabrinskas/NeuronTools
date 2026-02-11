//
//  MainView.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/4/24.
//

import SwiftUI
import AppKit
import Shared
@_spi(Visualizer) import Neuron

struct MainView: View {
  @State private var viewModel: GraphViewModel
  private var module: GraphViewDropModule
  
  init(viewModel: GraphViewModel, module: GraphViewDropModule) {
    self.viewModel = viewModel
    self.module = module
  }
  
  var body: some View {
    VStack {
      Text("Drag Neuron model here")
        .font(.title)
        .padding(viewModel.dropState == .enter ? 20 : 16)
        .background {
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .strokeBorder(style: .init(lineWidth: 3, dash: [10.0], dashPhase: viewModel.dashPhase))
            .fill(.gray.opacity(0.3))
        }
        .padding()
        .opacity(viewModel.dropState == .enter ? 0.5 : 1.0)
        .animation(.easeInOut, value: viewModel.dropState == .enter)
      Color.gray.frame(height: 2)
      HStack {
        ScrollView {
          Text(viewModel.message)
            .padding([.leading, .trailing], 8)
          Spacer()
        }
        .overlay {
          if viewModel.loading.isLoading {
            ProgressView()
          }
        }
        viewModel.graphView
      }
    }
    .onDrop(of: [.data], delegate: module)
  }
}
