//
//  VisualizerView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import SwiftUI
@_spi(Visualizer) import Neuron

struct QuantizerView: View {
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
  }
}
