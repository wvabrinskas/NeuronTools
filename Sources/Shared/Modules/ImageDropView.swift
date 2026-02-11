//
//  MainView.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/4/24.
//

import SwiftUI
import AppKit
@_spi(Visualizer) import Neuron

@Observable
public final class ImageDropViewModel: Sendable {
  public enum DropState {
    case enter, none
  }
  
  public struct Loading {
    public var isLoading: Bool
    public var percentage: Double
    
    public init(isLoading: Bool = false,
         percentage: Double = 0.0) {
      self.isLoading = isLoading
      self.percentage = percentage
    }
  }
  
  public var loading: Loading
  public var message: String
  public var dropState: DropState
  public var dashPhase: CGFloat
  public var image: NSImage?
  
  public init(image: NSImage? = nil,
       loading: Loading = .init(),
       message: String = "",
       dropState: DropState = .none,
       dashPhase: CGFloat = 0.0) {
    self.image = image
    self.loading = loading
    self.message = message
    self.dropState = dropState
    self.dashPhase = dashPhase
  }
}

public struct ImageDropView: View {
  @State private var viewModel: ImageDropViewModel
  private var module: ImageDropModule
  
  public init(viewModel: ImageDropViewModel, module: ImageDropModule) {
    self.viewModel = viewModel
    self.module = module
  }
  
  public var body: some View {
    VStack {
      if viewModel.loading.isLoading {
        ProgressView()
      } else {
        Text("Drop image here")
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
      }

    }
    .onDrop(of: [.image], delegate: module)
  }
}
