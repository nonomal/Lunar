//
//  GammaViewController.swift
//  Lunar
//
//  Created by Alin Panaitiu on 18.05.2021.
//  Copyright © 2021 Alin. All rights reserved.
//

import AtomicWrite
import Cocoa
import Foundation

class GammaViewController: NSViewController {
    @IBOutlet var dot: NSTextField!

    @AtomicWrite var highlighterTask: CFRunLoopTimer?
    var highlighterSemaphore = DispatchSemaphore(value: 1)

    func highlight() {
        mainThread {
            guard highlighterTask == nil,
                  dot != nil, let w = view.window, w.isVisible
            else {
                return
            }

            highlighterTask = operationHighlightQueue.async(every: 200.milliseconds) { [weak self] (_: CFRunLoopTimer?) in
                self?.highlighterSemaphore.wait()
                defer {
                    self?.highlighterSemaphore.signal()
                }

                guard let s = self else {
                    if let timer = self?.highlighterTask {
                        operationHighlightQueue.cancel(timer: timer)
                        self?.highlighterTask = nil
                    }
                    return
                }

                var windowVisible: Bool = false
                mainThread {
                    windowVisible = s.view.window?.isVisible ?? false
                }
                guard windowVisible, let dot = s.dot
                else {
                    if let timer = self?.highlighterTask {
                        operationHighlightQueue.cancel(timer: timer)
                    }
                    return
                }

                mainThread {
                    if dot.alphaValue == 0.0 {
                        dot.layer?.add(fadeTransition(duration: 0.25), forKey: "transition")
                        dot.alphaValue = 0.8
                        dot.needsDisplay = true
                    } else {
                        dot.layer?.add(fadeTransition(duration: 0.35), forKey: "transition")
                        dot.alphaValue = 0.0
                        dot.needsDisplay = true
                    }
                }
            }
        }
    }

    func stopHighlighting() {
        highlighterSemaphore.wait()
        defer {
            self.highlighterSemaphore.signal()
        }

        if let timer = highlighterTask {
            operationHighlightQueue.cancel(timer: timer)
        }
        highlighterTask = nil

        mainThread { [weak self] in
            guard let dot = self?.dot else { return }
            dot.layer?.add(fadeTransition(duration: 0.2), forKey: "transition")
            dot.alphaValue = 0.0
            dot.needsDisplay = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}