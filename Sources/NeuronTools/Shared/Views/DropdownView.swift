//
//  BadgeView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/15/26.
//

import SwiftUI

struct DropdownOption: Equatable {
  let text: String
  let color: Color
  let id: String
}

enum DropdownSize {
  case small
  case medium
  case large
  
  var height: CGFloat {
    switch self {
    case .small:
      10
    case .medium:
      16
    case .large:
      25
    }
  }
  
  var offset: CGFloat {
    switch self {
    case .small:
      (height + (height / 10 * 8) * 2 + 16)
    case .medium:
      (height + (height / 10 * 8) * 2 + 21)
    case .large:
      (height + (height / 10 * 8) * 2 + 25)
    }
  }
}

struct DropdownView: View {
  @Binding var selectedOption: DropdownOption
  @State var menuOpen: Bool = false
  
  var options: [DropdownOption]
  var size: DropdownSize
  
  private var unselectedOptions: [DropdownOption] {
    options.filter { $0 != selectedOption }
  }
  
  init(options: [DropdownOption],
       selectedOption: Binding<DropdownOption>,
       size: DropdownSize = .medium,
       selectedIndex: Int = 0) {
    self.options = options
    self.size = size
    _selectedOption = selectedOption
  }
  
  var body: some View {
   // ZStack(alignment: .leading) {
      DropdownCapsuleView(selectedOption: selectedOption,
                          height: size.height,
                          fontSize: size.height,
                          trailingIcon: menuOpen ? "chevron.up" :"chevron.down")
      .onTapGesture {
        menuOpen.toggle()
      }
      .overlay {
        if menuOpen {
          VStack(alignment: .leading, spacing: 10) {
            ForEach(unselectedOptions.indices, id: \.self) { index in
              DropdownCapsuleView(selectedOption: unselectedOptions[index],
                                  height: size.height,
                                  fontSize: size.height,
                                  trailingIcon: nil)
              .onTapGesture {
                selectedOption = unselectedOptions[index]
                menuOpen.toggle()
              }
            }
          }
         .offset(y: size.offset)
        }
      }
    .animation(.spring, value: menuOpen)
  }
}

fileprivate struct DropdownCapsuleView: View {
  @State private var isHovered: Bool = false
  
  var selectedOption: DropdownOption
  let height: CGFloat
  let fontSize: CGFloat
  let trailingIcon: String?
  
  var body: some View {
    HStack {
      Text(selectedOption.text)
        .font(.system(size: fontSize, weight: .bold, design: .monospaced))
        .foregroundStyle(selectedOption.color)
        .multilineTextAlignment(.leading)
      
      if let trailingIcon {
        Image(systemName: trailingIcon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: fontSize, height: fontSize)
          .foregroundStyle(selectedOption.color)
      }
    }
    .background(
      Capsule()
        .fill(selectedOption.color.opacity(0.15))
        .frame(width: height * 9, height: height * 2)
    )
    .opacity(isHovered ? 1 : 0.8)
    .scaleEffect(isHovered ? 1.05 : 1.0)
    .animation(.easeInOut(duration: 0.2), value: isHovered)
    .focusEffectDisabled()
    .onHover { hovering in
      isHovered = hovering
    }
    .frame(width: height * 9, height: height * 2)
  }
}

#Preview {
  VStack(spacing: 200) {
    DropdownView(options: [.init(text: "Classifier", color: .blue, id: ""),
                           .init(text: "RNN", color: .green, id: ""),
                           .init(text: "GAN", color: .red, id: "")],
                 selectedOption: .constant(.init(text: "Classifier", color: .blue, id: "")),
                 size: .small)
    
    DropdownView(options: [.init(text: "Classifier", color: .blue, id: ""),
                           .init(text: "RNN", color: .green, id: ""),
                           .init(text: "GAN", color: .red, id: "")],
                 selectedOption: .constant(.init(text: "Classifier", color: .blue, id: "")),
                 size: .medium)
    
    DropdownView(options: [.init(text: "Classifier", color: .blue, id: ""),
                           .init(text: "RNN", color: .green, id: ""),
                           .init(text: "GAN", color: .red, id: "")],
                 selectedOption: .constant(.init(text: "Classifier", color: .blue, id: "")),
                 size: .large)
  }
  .frame(width: 300, height: 900)

}
