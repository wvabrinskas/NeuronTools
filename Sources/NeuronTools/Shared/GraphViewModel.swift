//
//  MainViewModel.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/11/26.
//

import SwiftUI
import Combine


@Observable
final class GraphViewModel: Sendable {
  enum DropState {
    case enter, none
  }

  struct Loading {
    var isLoading: Bool
    var percentage: Double

    init(isLoading: Bool = false,
         percentage: Double = 0.0) {
      self.isLoading = isLoading
      self.percentage = percentage
    }
  }

  var importData: Data?
  var loading: Loading
  var message: String
  var dropState: DropState
  var dashPhase: CGFloat
  var graphView: GraphView?

  init(importData: Data? = nil,
       loading: Loading = .init(),
       message: String = "",
       dropState: DropState = .none,
       dashPhase: CGFloat = 0.0,
       graphView: GraphView? = nil) {
    self.importData = importData
    self.loading = loading
    self.message = message
    self.dropState = dropState
    self.dashPhase = dashPhase
    self.graphView = graphView
  }
}
