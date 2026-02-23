//
//  VisualizerView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import SwiftUI
@_spi(Visualizer) import Neuron

struct VisualizerView: View {
  @State private var viewModel: ModelDropViewModel
  @State private var module: ModelDropModule
  
  init(module: ModelDropModule = .init(builder: Builder())) {
    self.module = module
    self.viewModel = module.viewModel
  }

  var body: some View {
    VStack {
      DragModelView(module: module)
        .padding()
      Divider()
      HStack {
        ScrollView {
          Text(viewModel.message)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.primary)
          Spacer()
        }
        .padding([.leading, .trailing], 8)
        .overlay {
          if viewModel.loading.isLoading {
            ProgressView()
          }
        }
        viewModel.graphView
      }
    }
  }
}
