//
//  DrawAnnotationGestureRecognizer.swift
//  Lykoi
//
//  Created by Thomas on 2020/12/17.
//

import UIKit

class DrawAnnotationGestureRecognizer: UIGestureRecognizer {
    var isPencilDetected = false
    var trackedTouch:     UITouch?
    var initialTimestamp: TimeInterval?
    var stroke           = Stroke()

    var fingerStartTimer: Timer?
    private let cancellationTimeInterval = TimeInterval(0.1)
    var coordinateSpaceView: UIView?

    var updateCoordinateSpaceView: ((_ location: CGPoint) -> UIView)?

    func append(touches: Set<UITouch>, event: UIEvent?) -> Bool {
        // Check that we have a touch to append, and that touches
        // doesn't contain it.
        guard let touchToAppend = trackedTouch, touches.contains(touchToAppend) == true
            else {
            return false
        }

        // Cancel the stroke recognition if we get a second touch during cancellation period.
        if shouldCancelRecognition(touches: touches, touchToAppend: touchToAppend) {
            if state == .possible {
                state = .failed
            } else {
                state = .cancelled
            }
            return false
        }

        if let event = event {
            let coalescedTouches = event.coalescedTouches(for: touchToAppend)!
            for touch in coalescedTouches {
                let location = touch.location(in: coordinateSpaceView)
                let point    = StrokePoint(timestamp: touch.timestamp, location: location)
                stroke.add(point: point)
            }
        }

        return true
    }

    func shouldCancelRecognition(touches: Set<UITouch>, touchToAppend: UITouch) -> Bool {
        var shouldCancel = false
        for touch in touches {
            if touch !== touchToAppend &&
               touch.timestamp - initialTimestamp! < cancellationTimeInterval {
                shouldCancel = true
                break
            }
        }
        return shouldCancel
    }

    override func location(in view: UIView?) -> CGPoint {
        guard let touchToAppend = trackedTouch else {
            return CGPoint.zero
        }
        let location = touchToAppend.location(in: view)
        return location

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if trackedTouch == nil {
            trackedTouch = touches.first
            initialTimestamp = trackedTouch?.timestamp

            coordinateSpaceView = updateCoordinateSpaceView?(trackedTouch!.location(in: view!))

            if isPencilDetected == false {
                if trackedTouch?.type == UITouch.TouchType.pencil {
                    isPencilDetected = true
                }
            }

            if trackedTouch?.type != .pencil {
                // Give other gestures, such as pan and pinch, a chance by
                // slightly delaying the `.begin.
                fingerStartTimer = Timer.scheduledTimer(
                    withTimeInterval: cancellationTimeInterval,
                    repeats: false,
                    block: { [weak self] (timer) in
                        guard let strongSelf = self else { return }
                        if strongSelf.state == .possible {
                            strongSelf.state = .began
                        }
                    }
                )
            }
        }
        if append(touches: touches, event: event) {
            if trackedTouch?.type == .pencil {
                state = .began
            }
        }


        if isPencilDetected == false {
            if touches.first?.type == UITouch.TouchType.pencil {
                isPencilDetected = true
            }
        }

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if append(touches: touches, event: event) {
            if state == .began {
                state = .changed
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if append(touches: touches, event: event) {
            if state == .possible {
                state = .began
            }
            state = .ended
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        if append(touches: touches, event: event) {
            state = .failed
        }
    }

    override func reset() {
        trackedTouch = nil
        if let timer = fingerStartTimer {
            timer.invalidate()
            fingerStartTimer = nil
        }
        stroke = Stroke()
        super.reset()
    }
}
