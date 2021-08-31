//
//  ViewController.swift
//  WhackAJellyfish
//
//  Created by Marko Jovanov on 31.8.21.
//

import UIKit
import SceneKit
import ARKit
import Each

class ViewController: UIViewController, ARSCNViewDelegate {
    var timer = Each(1).seconds
    var countdown = 10
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        setTimer()
        addNode()
        playButton.isEnabled = false
    }
    
    @IBAction func resetPressed(_ sender: UIButton) {
        timer.stop()
        restoreTimer()
        playButton.isEnabled = true
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
    }
    func addNode() {
        let jellyfishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        if let jellyfishNode = jellyfishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false) {
            jellyfishNode.position = SCNVector3(Float.random(in: -1.0...1.0),
                                                Float.random(in: -0.5...0.5),
                                                Float.random(in: -1.0...1.0))
            sceneView.scene.rootNode.addChildNode(jellyfishNode)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResult = sceneView.hitTest(touchLocation)
            if let hitResult = hitTestResult.first {
                if countdown > 0 {
                    if hitResult.node.animationKeys.isEmpty {
                        SCNTransaction.begin()
                        animateNode(node: hitResult.node)
                        SCNTransaction.completionBlock = {
                            hitResult.node.removeFromParentNode()
                            self.addNode()
                            self.restoreTimer()
                        }
                        SCNTransaction.commit()
                    }
                }
            }
        }
    }
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2,
                                  node.presentation.position.y - 0.2,
                                  node.presentation.position.z - 0.2)
        spin.duration = 0.1
        spin.repeatCount = 5
        spin.autoreverses = true
        node.addAnimation(spin, forKey: "position")
    }
    func setTimer() {
        timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = "\(self.countdown) seconds"
            if self.countdown == 0 {
                self.timerLabel.text = "You lose"
                return .stop
            }
            return .continue
        }
    }
    func restoreTimer() {
        countdown = 10
        timerLabel.text = "\(self.countdown) seconds"
    }
    
    
}
