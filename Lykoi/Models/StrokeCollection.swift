//
//  StrokeCollection.swift
//  Lykoi
//
//  Created by Thomas on 2020/12/17.
//

import UIKit

struct StrokePoint {
    let timestamp: TimeInterval
    let location: CGPoint

    init(timestamp: TimeInterval, location: CGPoint) {
        self.timestamp = timestamp
        self.location = location
    }
}

class Stroke {
    var points = [StrokePoint]()

    func add(point: StrokePoint) {
        points.append(point)
    }
}
