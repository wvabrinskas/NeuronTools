//
//  main.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/4/24.
//

@_spi(Visualizer) import Neuron
import AppKit
import SwiftUI

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
