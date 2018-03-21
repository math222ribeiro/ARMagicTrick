//
//  ViewController.swift
//  MagicTrick
//
//  Created by Matheus Ribeiro D'Azevedo Lopes on 20/03/18.
//  Copyright © 2018 Matheus Ribeiro D'Azevedo Lopes. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
  
  private var planeNode: SCNNode?
  @IBOutlet weak var sceneView: ARSCNView!
  
  @IBAction func didTapThrowBallButton(_ sender: Any) {
    guard let currentFrame = sceneView.session.currentFrame else { return }
    let sphere = SCNSphere(radius: 0.025)
    sphere.firstMaterial?.diffuse.contents = UIColor.green
    let node = SCNNode(geometry: sphere)
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphere, options: nil))
    node.physicsBody?.restitution = 0.9
    sceneView.scene.rootNode.addChildNode(node)
    
    var translation = matrix_identity_float4x4
    translation.columns.3.z = -0.1
    node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
    
    let original = SCNVector3(x: 0, y: 0, z: -2)
    let force = simd_make_float4(original.x, original.y, original.z, 0)
    let rotatedForce = simd_mul(currentFrame.camera.transform, force)
    
    let vectorForce = SCNVector3(x:rotatedForce.x, y:rotatedForce.y, z:rotatedForce.z)
    node.physicsBody?.applyForce(vectorForce, asImpulse: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    sceneView.showsStatistics = true
    
    let scene = SCNScene()
    sceneView.scene = scene
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    view.addGestureRecognizer(tap)
  }
  
  @objc
  func handleTap(_ sender: UITapGestureRecognizer) {
    let tapLocation = sender.location(in: sceneView)
    
    let results = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
    
    if let result = results.first {
      placeHat(result)
    }
  }
  
  func placeHat(_ result: ARHitTestResult) {
    let transform = result.worldTransform
    let planePosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    let hatNode = createHatFromScene(planePosition)!
    //    hatNode.scale = SCNVector3(x: 0.08, y: 0.08, z: 0.08)
    sceneView.scene.rootNode.addChildNode(hatNode)
  }
  
  private func createHatFromScene(_ position: SCNVector3) -> SCNNode? {
    guard let url = Bundle.main.url(forResource: "art.scnassets/hat", withExtension: "scn") else {
      NSLog("Could not find door scene")
      return nil
    }
    guard let node = SCNReferenceNode(url: url) else { return nil }
    
    node.load()
    
    // Position scene
    node.position = position
    
    return node
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    sceneView.session.pause()
  }
  
}

extension ViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    
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

extension ViewController: ARSessionDelegate {
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    
  }
  
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    
  }
}
