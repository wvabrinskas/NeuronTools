//
//  VisualizerView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import SwiftUI
@_spi(Visualizer) import Neuron

struct VisualizerView: View {
  @State private var viewModel = GraphViewModel()
  @State private var module: GraphViewDropModule?
  
  var body: some View {
    content
      .onAppear {
        if module == nil {
          module = GraphViewDropModule(viewModel: viewModel, builder: Builder())
        }
      }
  }
  
  @ViewBuilder
  private var content: some View {
    if let module {
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
    } else {
      ProgressView()
    }
  }
}
