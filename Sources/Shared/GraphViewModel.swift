//
//  MainViewModel.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/11/26.
//

import SwiftUI
import Combine


@Observable
public final class GraphViewModel: Sendable {
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
  
  public var importData: Data?
  public var loading: Loading
  public var message: String
  public var dropState: DropState
  public var dashPhase: CGFloat
  public var graphView: GraphView?
  
  public init(importData: Data? = nil,
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
