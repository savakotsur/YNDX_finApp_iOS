//
//  PieChartView.swift
//  
//
//  Created by Савелий Коцур on 25.07.2025.
//

import Foundation

import UIKit

public final class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    private let segmentColors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen,
        .systemOrange, .systemPurple, .systemGray
    ]

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !entities.isEmpty else { return }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * 0.8
        let lineWidth: CGFloat = 10 // Толщина кольца
        let total = entities.reduce(0) { $0 + (Double(truncating: $1.value as NSNumber)) }

        let limitedEntities = Array(entities.prefix(5))
        let remaining = entities.dropFirst(5)
        let remainingSum = remaining.reduce(0) { $0 + (Double(truncating: $1.value as NSNumber)) }

        var pieData = limitedEntities.map { (Double(truncating: $0.value as NSNumber), $0.label) }

        if remainingSum > 0 {
            pieData.append((remainingSum, "Остальные"))
        }

        var startAngle = -CGFloat.pi / 2

        context.setLineWidth(lineWidth)
        context.setLineCap(.butt)

        for (index, data) in pieData.enumerated() {
            let value = data.0
            let angle = CGFloat(value / total) * .pi * 2
            let endAngle = startAngle + angle

            context.setStrokeColor(segmentColors[index % segmentColors.count].cgColor)
            let path = UIBezierPath(arcCenter: center, radius: radius - lineWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.lineWidth = lineWidth
            path.stroke()

            startAngle = endAngle
        }

        // Легенда внутри круга
        let legendRectSize: CGFloat = 12
        let legendSpacing: CGFloat = 6

        let legendStartX = center.x - radius / 1.8
        var legendStartY = center.y - radius / 2  // подняли вверх

        for (index, data) in pieData.enumerated() {
            let color = segmentColors[index % segmentColors.count]
            let label = data.1
            let value = data.0

            // Вычисляем процент от общей суммы
            let percent = total > 0 ? Int(round(value / total * 100)) : 0
            let legendText = "\(percent)% \(label)"

            // Круглый индикатор цвета
            let circleRect = CGRect(x: legendStartX, y: legendStartY, width: legendRectSize, height: legendRectSize)
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: circleRect)

            // Текст
            let maxTextWidth = rect.width / 3
            let textRect = CGRect(x: legendStartX + legendRectSize + 6, y: legendStartY - 2, width: maxTextWidth, height: 20)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byTruncatingTail

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]

            (legendText as NSString).draw(with: textRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            legendStartY += legendRectSize + legendSpacing
        }
    }
}
