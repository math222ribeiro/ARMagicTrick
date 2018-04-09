//
//  ViewController+ARSessionDelegate.swift
//  MagicTrick
//
//  Created by Matheus Ribeiro D'Azevedo Lopes on 08/04/2018.
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import ARKit

extension ViewController: ARSessionDelegate {
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    guard let arError = error as? ARError else { return }
    
    let isRecoverable = (arError.code == .worldTrackingFailed)
    if isRecoverable {
      trackingLabel.text = "ERROR, TRY RESTARTING THE APP"
    } else {
      trackingLabel.text = "ERROR, CAMERA ACCESS DENIED"
    }
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    trackingLabel.text = "SESSION INTERRUPTED"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    resetTracking()
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .normal:
      trackingLabel.text = "TRACKING NORMAL"
    case .notAvailable:
      trackingLabel.text = "TRACKING NOT AVAILABLE"
    case .limited(.excessiveMotion):
      trackingLabel.text = "TRY MOVING SLOWLY"
    case .limited(.insufficientFeatures):
      trackingLabel.text = "TRY MOVING AROUND"
    case .limited(.initializing):
      fallthrough
    default:
      trackingLabel.text = "STARTING..."
    }
  }
}
