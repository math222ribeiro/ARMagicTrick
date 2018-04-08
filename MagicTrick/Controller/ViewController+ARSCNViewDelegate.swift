//
//  ViewController+ARSCNViewDelegate.swift
//  MagicTrick
//
//  Created by Matheus Ribeiro D'Azevedo Lopes on 08/04/2018.
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if let lightEstimate = sceneView.session.currentFrame?.lightEstimate {
      if let node = sceneView.scene.rootNode.childNode(withName: "omni", recursively: true) {
        node.light?.intensity = lightEstimate.ambientIntensity
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    if anchor is ARPlaneAnchor {
      planeNode = SCNNode()
      return planeNode
    }
    
    return nil
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else {
      return
    }
    
    node.addChildNode(createPlaneNode(planeAnchor: planeAnchor))
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    node.enumerateChildNodes {
      (childNode, _) in
      childNode.removeFromParentNode()
    }
    
    node.addChildNode(createPlaneNode(planeAnchor: planeAnchor))
    
  }
  
  func createPlaneNode(planeAnchor: ARPlaneAnchor) -> SCNNode {
    let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
    plane.materials = [planeMaterial]
    
    let alphaPlane = SCNNode(geometry: plane)
    alphaPlane.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
    alphaPlane.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    let shape = SCNPhysicsShape(geometry: plane, options: nil)
    alphaPlane.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
    return alphaPlane
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARPlaneAnchor else {
      return
    }
    node.enumerateChildNodes {
      (childNode, _) in
      childNode.removeFromParentNode()
    }
  }
}

