//
//  ModelPlaygroundView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import SwiftUI
import Neuron

struct ModelPlaygroundView: View {
  @State private var viewModel: ModelDropViewModel
  @State private var module: ModelDropModule
  @State private var selectedOption: DropdownOption = ModelType.classifier.asDropdownItem
  
  // Classifier parameters
  @State private var classifierViewParameters: ClassifierViewParameters = .init()
  
  // GAN Parameters
  @State private var ganViewParameters: GANViewParameters = .init()
  
  @State private var imageDropViewModel: ImageDropViewModel
  private let imageDropModule: ImageDropModule
  
  private let modelTypes: [ModelType] = [.classifier, .rnn, .gan]
  
  init(module: ModelDropModule = .init(builder: Builder()),
       imageDropModule: ImageDropModule = .init()) {
    self.module = module
    self.viewModel = module.viewModel
    self.imageDropModule = imageDropModule
    self.imageDropViewModel = imageDropModule.viewModel
  }
  
  var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading) {
          DragModelView(module: module)
            .padding(.leading, 16)
            .padding(.top, 8)

          VStack(alignment: .leading) {
            Text("Model type")
              .font(.system(size: 15, weight: .semibold))
              .foregroundStyle(.secondary)
              .offset(x: 8)
            
            DropdownView(options: modelTypes.map(\.asDropdownItem),
                         selectedOption: $selectedOption)
          }
          .padding(.leading, 16)
          .padding(.vertical, 8)
        }
    
        Spacer()
        
        switch ModelType(rawValue: selectedOption.id)! {
        case .gan:
          ganParametersView
            .animation(.spring, value: selectedOption)
        case .classifier:
          classifierParametersView
            .animation(.spring, value: selectedOption)
        case .rnn:
          EmptyView()
        }
        
        Spacer()
        
      }
      Divider()
      // other content
      
      if viewModel.loading.isLoading {
        ProgressView()
      }
      
      if let content = viewModelSelectedOption(),
         viewModel.loading.isLoading == false {
        AnyView(content)
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onChange(of: viewModel.modelProperties) { _, newValue in
      guard let newValue else { return }
      handleModelChange(modelProperties: newValue)
    }
  }
  
  private func handleModelChange(modelProperties: ModelProperties) {
    guard let type = ModelType(rawValue: selectedOption.id) else { return }
    
    switch type {
    case .classifier:
      handleClassifierParameters(modelProperites: modelProperties)
    default:
      break
    }
  }
  
  private func handleClassifierParameters(modelProperites: ModelProperties) {
    
    let classes = modelProperites.outputSize.columns
    let inputSize = modelProperites.inputSize
    
    classifierViewParameters.numberOfClasses = "\(classes)"
    classifierViewParameters.inputRows = "\(inputSize.rows)"
    classifierViewParameters.inputColumns = "\(inputSize.columns)"
    classifierViewParameters.inputDepth = "\(inputSize.depth)"
  }
  
  private func viewModelSelectedOption() -> (any View)? {
    guard viewModel.modelProperties != nil,
          let type = ModelType(rawValue: selectedOption.id) else { return nil }

    switch type {
    case .classifier:
      return AnyView(
        ClassifierResultView(imageDropViewModel: imageDropViewModel,
                             imageDropModule: imageDropModule,
                             classifierViewParameters: classifierViewParameters,
                             feedImage: feedImage)
      )
    case .gan:
      return AnyView(
        GANResultView(parameters: ganViewParameters) {
          module.generate()
        }
      )
    default:
      break
    }
    
    return nil
  }
  
  private func feedImage(_ image: NSImage?) {
    guard let image,
    let imageWidth = Float(classifierViewParameters.inputColumns),
    let imageHeight = Float(classifierViewParameters.inputRows),
    let imageResized = image.resized(to: CGSize(width: CGFloat(imageWidth), height: CGFloat(imageHeight))) else { return }
    
    //resize image
    let imageAsTensor = imageResized.asRGBTensor()
    let imageSize = TensorSize(array: imageAsTensor.shape)
    
    guard imageSize == viewModel.modelProperties?.inputSize else {
      // TODO: throw error
      return
    }
    
    guard let prediction = module.predict([imageAsTensor]),
          let firstPrediction = prediction.first else {
      // TODO: throw differnet error
      return
    }
    
    let indexOfMax = firstPrediction.storage.indexOfMax
    
    classifierViewParameters.indexOfMax = Int(indexOfMax.0 + 1)
    classifierViewParameters.confidence = indexOfMax.1
  }
  
  private var ganParametersView: some View {
    Text("Upload a generator smodel file")
      .font(.system(size: 15, weight: .semibold))
      .foregroundStyle(.secondary)
  }
  
  private var classifierParametersView: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Number of classes field
      VStack(alignment: .leading, spacing: 4) {
        Text("Number of classes")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.secondary)
        NumberTextField(text: $classifierViewParameters.numberOfClasses, placeholder: "10")
      }
      
      // Input size fields
      VStack(alignment: .leading, spacing: 4) {
        Text("Input size")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.secondary)
        HStack(spacing: 12) {
          LabeledNumberField(label: "Rows", text: $classifierViewParameters.inputRows, placeholder: "28")
          LabeledNumberField(label: "Columns", text: $classifierViewParameters.inputColumns, placeholder: "28")
          LabeledNumberField(label: "Depth", text: $classifierViewParameters.inputDepth, placeholder: "1")
        }
      }
    }
    .padding(16)
  }
}
#Preview {
  ModelPlaygroundView()
    .frame(width: 700, height: 570)
}
