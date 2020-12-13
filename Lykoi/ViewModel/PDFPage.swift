//
// Created by Thomas on 2020/12/12.
//

import Foundation
import CoreGraphics

class PDFPage: NSObject {
    private var cgPage:     CGPDFPage
    private var fpPage:     FPDF_PAGE
    private var fpTextPage: FPDF_TEXTPAGE
    private var stepSearch = 10

    private let selectionTolerance: Double = 5

    init(cgPage: CGPDFPage, fpPage: FPDF_PAGE) {
        self.cgPage = cgPage
        self.fpPage = fpPage
        fpTextPage = FPDFText_LoadPage(self.fpPage)
    }


    deinit {
        FPDF_ClosePage(fpPage)
        FPDFText_ClosePage(fpTextPage)
    }

    private var _pageSize:  CGSize? = nil
    private var _charCount: Int?    = nil

    var pageSize: CGSize {
        if _pageSize == nil {
            let width  = FPDF_GetPageWidth(fpPage)
            let height = FPDF_GetPageHeight(fpPage)
            _pageSize = CGSize(width: width, height: height)
        }
        return _pageSize!
    }

    private var charCount: Int {
        if _charCount == nil {
            _charCount = Int(FPDFText_CountChars(fpTextPage))
        }
        return _charCount!
    }

    func drawPage(inContext ctx: CGContext, fillColor color: CGColor) {
        ctx.setFillColor(color)
        ctx.fill(ctx.boundingBoxOfClipPath)
        ctx.translateBy(x: 0, y: pageSize.height)
        // TODO:  check iOS or macOS
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.concatenate(cgPage.getDrawingTransform(.cropBox,
                rect: CGRect(origin: .zero, size: pageSize),
                rotate: 0,
                preserveAspectRatio: true))
        ctx.drawPDFPage(cgPage)
    }

    func searchWordIndex(around point: CGPoint) -> (startIndex: Int, endIndex: Int)? {
        let x         = Double(point.x)
        let y         = Double(point.y)
        let charIndex = FPDFText_GetCharIndexAtPos(fpTextPage, x, y, selectionTolerance, selectionTolerance)
        if charIndex < 0 {
            return nil
        }

        let endIndex   = searchWordBackward(from: Int(charIndex))
        let startIndex = searchWordForward(from: Int(charIndex))

        guard endIndex >= startIndex else {
            return nil
        }

        return (startIndex, endIndex)
    }

    func getRects(fromCharIndex startIndex: Int, toCharIndex endIndex: Int) -> [CGRect] {
        let rectsCount = FPDFText_CountRects(fpTextPage, Int32(startIndex), Int32(endIndex - startIndex))
        var rects      = [CGRect]()

        for index in 0..<Int(rectsCount) {
            if let rect = getTextRects(atIndex: index) {
                rects.append(rect)
            }
        }
        return rects
    }

    private func getTextRects(atIndex index: Int) -> CGRect? {
        var left:   Double = 0
        var top:    Double = 0
        var right:  Double = 0
        var bottom: Double = 0

        guard FPDFText_GetRect(fpTextPage, Int32(index), &left, &top, &right, &bottom) == 1 else {
            return nil
        }

        // TODO: consider rotation
        top = Double(pageSize.height) - top
        bottom = Double(pageSize.height) - bottom

        let rect = CGRect(x: left, y: top, width: right - left, height: bottom - top)

        return rect
    }

    private func searchWordBackward(from index: Int) -> Int {
        var searchLength = stepSearch

        while true {
            var searchToEnd = false
            if index + searchLength > charCount {
                searchLength = charCount - index
                searchToEnd = true
            }

            let text   = getText(fromIndex: index, withLength: searchLength)
            let tokens = text.tokenize()
            if tokens.count > 1 {
                let length = tokens[0].count
                return index + length
            }
            if searchToEnd {
                return index + searchLength
            }

            searchLength = searchLength + stepSearch
        }
    }

    private func searchWordForward(from index: Int) -> Int {
        var startIndex = index - stepSearch + 1

        while true {
            if startIndex < 0 {
                startIndex = 0
            }

            let text   = getText(fromIndex: startIndex, withLength: index - startIndex + 1)
            let tokens = text.tokenize()
            if tokens.count > 1 {
                let length = tokens[tokens.count - 1].count
                return index - length + 1
            }

            if startIndex == 0 {
                return 0
            }

            startIndex = startIndex - stepSearch

        }
    }

    func getText(fromIndex index: Int, withLength length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        let legalLength: Int
        if index + length > charCount {
            legalLength = charCount - index
        } else {
            legalLength = length
        }

        var data = Data(count: (legalLength + 1) * UInt16.bitWidth / UInt8.bitWidth)

        let text = data.withUnsafeMutableBytes { (pointer: UnsafeMutablePointer<UInt16>) -> String in
            let length = FPDFText_GetText(fpTextPage, Int32(index), Int32(legalLength), pointer)
            let text   = String(utf16CodeUnitsNoCopy: pointer, count: Int(length - 1), freeWhenDone: false)
            return text
        }
        return text
    }
}


extension String {
    func tokenize() -> [String] {
        let inputRange       = CFRangeMake(0, CFStringGetLength(self as CFString))
        let flag             = UInt(kCFStringTokenizerUnitWordBoundary)
        let locale           = CFLocaleCopyCurrent()
        let tokenizer        = CFStringTokenizerCreate(kCFAllocatorDefault, self as CFString, inputRange, flag, locale)
        var tokenType        = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var tokens: [String] = []

        while tokenType != CFStringTokenizerTokenType(rawValue: 0) {
            let currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let substring         = self.substringWithRange(aRange: currentTokenRange)
            tokens.append(substring)
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }

        return tokens
    }

    func substringWithRange(aRange: CFRange) -> String {

        let nsRange   = NSMakeRange(aRange.location, aRange.length)
        let substring = (self as NSString).substring(with: nsRange)
        return substring
    }
}