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
  
  @IBOutlet weak var sceneView: ARSCNView!
  @IBOutlet weak var trackingLabel: UILabel!
  
  var planeNode: SCNNode?
  var hatNode: SCNNode!
  var hidden = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    
    let scene = SCNScene()
    sceneView.scene = scene
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    view.addGestureRecognizer(tap)
    
    setupLights()
    
    createHatFromScene()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    configuration.worldAlignment = .gravity
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    sceneView.session.pause()
  }
  
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
  
  @IBAction func didTapMagicButton(_ sender: Any) {
    sceneView.scene.rootNode.enumerateChildNodes {node, _ in
      if hatBoundingBoxContains(node.presentation.position) {
        node.isHidden = hidden
        hidden = !hidden
      }
    }
  }
  
  @objc
  func handleTap(_ sender: UITapGestureRecognizer) {
    let tapLocation = sender.location(in: sceneView)
    
    let results = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
    
    if let result = results.first {
      placeHat(result)
    }
  }
  
  func setupLights() {
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light?.type = .ambient
    ambientLightNode.light?.intensity = 500
    sceneView.scene.rootNode.addChildNode(ambientLightNode)
    
    let omniLightNode = SCNNode()
    omniLightNode.name = "omni"
    omniLightNode.light = SCNLight()
    omniLightNode.light?.type = .omni
    omniLightNode.light?.color = UIColor.white
    omniLightNode.light?.intensity = 500
    sceneView.scene.rootNode.addChildNode(omniLightNode)
  }
  
  func placeHat(_ result: ARHitTestResult) {
    let transform = result.worldTransform
    let planePosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    hatNode.position = planePosition
    sceneView.scene.rootNode.addChildNode(hatNode)
  }
  
  private func createHatFromScene() {
    guard let scene = SCNScene(named: "art.scnassets/hat.scn") else {
      fatalError("hat.scn not found")
    }
    
    hatNode = scene.rootNode.childNode(withName: "hat", recursively: true)
  }
  
  public func resetTracking() {
    for node in sceneView.scene.rootNode.childNodes {
      node.removeFromParentNode()
    }
    
    planeNode = nil
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
  func hatBoundingBoxContains(_ point: SCNVector3) -> Bool {
    let node = self.hatNode!
    
    let min = node.convertPosition((node.boundingBox.min), to: sceneView.scene.rootNode)
    let max = node.convertPosition((node.boundingBox.max), to: sceneView.scene.rootNode)
    
    return
      point.x > min.x  &&
        point.y > min.y  &&
        point.z > min.z  &&
        point.x < max.x &&
        point.y < max.y &&
        point.z < max.z
  }
}
