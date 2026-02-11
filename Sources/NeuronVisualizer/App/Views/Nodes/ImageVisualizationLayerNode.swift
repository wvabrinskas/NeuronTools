//
//  ImageVisualizationLayerNode.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 7/30/25.
//

import Neuron
import NumSwift
import SwiftUI

@Observable
final class ImageVisualizationViewModel {
  var imageFilterPreview: [[Float]] = []
  var imageDropViewModel: ImageDropViewModel
  var imageDropModule: ImageDropModule
  var images: [Tensor] = []
  var showImageDrop: Bool = false
  var showDetails: Bool = false
  var imageSize: TensorSize
  
  init(imageFilterPreview: [[Float]] = [],
       imageDropViewModel: ImageDropViewModel,
       imageDropModule: ImageDropModule,
       images: [Tensor] = [],
       imageSize: TensorSize) {
    self.imageFilterPreview = imageFilterPreview
    self.imageDropViewModel = imageDropViewModel
    self.imageDropModule = imageDropModule
    self.images = images
    self.imageSize = imageSize
  }
}

protocol ImageVisualizationViewProtocol {
  func previewFilters(image: NSImage?)
  func clearPreview()
  func close()
}

class ImageVisualizationLayerNode: DetailedLayerNode, ImageVisualizationViewProtocol {
  private lazy var viewModel = ImageVisualizationViewModel(imageDropViewModel: imageDropViewModel,
                                                           imageDropModule: imageDropModule,
                                                           imageSize: payload.weightsSize)
  
  private var imageDropViewModel = ImageDropViewModel()
  private lazy var imageDropModule = ImageDropModule(viewModel: imageDropViewModel)
  
  lazy var images: [Tensor] = {
    var result: [Tensor] = []
    
    payload.weights.forEach { tensor in
      
      for d in 0..<tensor.size.depth {
        result.append(Tensor(tensor.depthSlice(d), size: .init(rows: tensor.size.rows,
                                                               columns: tensor.size.columns,
                                                               depth: 1)))
      }
    }
    
    return result
  }()

  required init(payload: NodePayload) {
    super.init(payload: payload)
    viewModel.images = images
  }
  
  @ViewBuilder
  override func build() -> any View {
    ImageVisualizationView(payload: payload,
                           baseView: super.build,
                           viewModel: viewModel,
                           node: self)
  }
  
  func previewFilters(image: NSImage?) {
    guard let image else { return }
    let imageAsTensor = image.asRGBTensor()
    let imageSize = TensorSize(array: imageAsTensor.shape)
        
    let flatWeights = payload.weights
    
    var result: [Tensor] = []
    
    flatWeights.forEach { filterLayer in
      var resultForImage: Tensor = .init([], size: imageAsTensor.size)
      
      for d in 0..<imageAsTensor.size.depth {
        let filter = filterLayer.depthSlice(d)
        let imageLayer = imageAsTensor.depthSlice(d)
        
        let conv2d = NumSwiftFlat.conv2d(signal: imageLayer,
                                         filter: filter,
                                         padding: .same,
                                         filterSize: (payload.weightsSize.rows,
                                                      payload.weightsSize.columns),
                                         inputSize: (imageSize.rows,
                                                     imageSize.columns))
        
        let newTensor = Tensor(conv2d, size: .init(rows: imageSize.rows, columns: imageSize.columns, depth: 1))
        resultForImage = resultForImage.concat(newTensor, axis: 2)
      }
      
      result.append(resultForImage)
    }

    viewModel.imageSize = imageSize
    viewModel.images = result
    close()
  }

  func clearPreview() {
    viewModel.imageSize = payload.weightsSize
    viewModel.imageDropViewModel.loading = .init()
    viewModel.imageDropViewModel.dropState = .none
    viewModel.imageDropViewModel.image = nil
    viewModel.images = images
  }
  
  func close() {
    viewModel.showImageDrop = false
    viewModel.showDetails = true
  }
}

private struct ImageVisualizationView: View {
  let payload: NodePayload
  @ViewBuilder var baseView: any View

  @State private var sizeScale: CGFloat = 1.0
  @State private var interpolate: Bool = true
  @State var viewModel: ImageVisualizationViewModel
  var node: ImageVisualizationViewProtocol
  
  private let maxSize: CGFloat = 128
  private let minSizeScale: CGFloat = 0.2

  var body: some View {
    HStack {
      AnyView(baseView)
      Image(systemName: "chevron.right")

    }
      .onTapGesture {
        viewModel.showDetails = true
      }
      .sheet(isPresented: $viewModel.showImageDrop) {
        ImageDropView(viewModel: viewModel.imageDropViewModel,
                      module: viewModel.imageDropModule)
        .toolbar {
          Button("Back") {
            node.close()
          }
        }
        .onChange(of: viewModel.imageDropViewModel.image) { _, newValue in
          node.previewFilters(image: newValue)
        }
      }
      .sheet(isPresented: $viewModel.showDetails) {
        VStack {
          ScrollView(.vertical) {
            let images = viewModel.images.batched(into: 3)
            ForEach(0..<images.count, id: \.self) { i in
              let imageRow = images[i]
              
              LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
              ]) {
                ForEach(0..<imageRow.count, id: \.self) { index in
                  let imageInRow = imageRow[index]
                  let image = mapImage(imageInRow)
                  
                  image
                    .interpolation(interpolate == true ? .high : .none)
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: maxSize * sizeScale,
                           height: maxSize * sizeScale)
                }
              }
            }
          }
          .padding()
        }
        .toolbar(content: {
          ToolbarItemGroup {
            HStack {
              Image(systemName: "textformat.size.smaller")
                .bold()
              Slider(value: $sizeScale, in: minSizeScale...1.0) { _ in }
              Image(systemName: "textformat.size.larger")
                .bold()
            }
            .frame(width: 200)
            .padding(.leading)
            
            Toggle(isOn: $interpolate) {
              Text("Interpolate")
            }
            .padding([.leading, .trailing])
                      
            if viewModel.imageDropViewModel.image != nil {
              Button("Clear preview") {
                node.clearPreview()
              }
            } else {
              Button("Preview filters") {
                node.clearPreview()
                viewModel.showDetails = false
                viewModel.showImageDrop = true
              }
            }

          }

          ToolbarItem(placement: .primaryAction) {
            Button("Close") {
              viewModel.showDetails = false
            }
          }
        })

        .frame(width: maxSize * 4, height: 600)
        .windowResizable()
      }
  }
  
  private func mapImage(_ image: Tensor) -> Image {
    if image.shape.last == 3 {
      let flatValue = Array(image.storage)
      let min = flatValue.min() ?? 0
      let max = flatValue.max() ?? 0
      
      if let nsImage = NSImage.colorImage(flatValue.scale(from: min...max, to: 0...1),
                                    size: (viewModel.imageSize.rows, viewModel.imageSize.columns)) {
        return Image(nsImage: nsImage)
      }
    }
    
    let flatValue = Array(image.storage)
    
    let min = flatValue.min() ?? 0
    let max = flatValue.max() ?? 0
    
    guard let nsImage = NSImage.from(flatValue.scale(from: min...max, to: 0...1), size: (viewModel.imageSize.rows, viewModel.imageSize.columns)) else {
      return Image("")
    }
    
    return Image(nsImage: nsImage)
  }
}

fileprivate extension View {
  func windowResizable() -> some View {
    if #available(macOS 15.0, *) {
      return self.windowResizeBehavior(.enabled)
    } else {
      return self
    }
  }
}

fileprivate extension CGSize {
  func adding(_ value: Float) -> CGSize {
    return .init(width: width + CGFloat(value), height: height + CGFloat(value))
  }
  
  func subtracting(_ value: Float) -> CGSize {
    return .init(width: width - CGFloat(value), height: height - CGFloat(value))
  }
}
