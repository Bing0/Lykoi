//
// Created by Thomas on 2020/12/12.
//

import Foundation
import CoreGraphics

class PDFDoc: NSObject {

    private var cgPDF: CGPDFDocument
    private var fpPDF: FPDF_DOCUMENT
    private var pages: NSMapTable<NSNumber, PDFPage>
    private var intToNSNumber: [Int: NSNumber]

    var numberOfPages: Int {
        cgPDF.numberOfPages
    }

    init?(withURL documentURL: URL) {
        guard let _cgPDF = CGPDFDocument(documentURL as CFURL) else {
            print("document read failed")
            return nil
        }
        let filePath = (documentURL.path as NSString).utf8String
        guard let _fpPDF = FPDF_LoadDocument(filePath, nil) else {
            print("document read failed with PDFium")
            return nil
        }

        cgPDF = _cgPDF
        fpPDF = _fpPDF
        pages = NSMapTable.weakToStrongObjects()
        intToNSNumber = [Int: NSNumber]()

        for index in 0..<cgPDF.numberOfPages {
            intToNSNumber[index] = NSNumber(value: index)
        }
    }

    func pageSize(atIndex index: Int) -> CGSize {
        var width: Double = 0
        var height: Double = 0

        FPDF_GetPageSizeByIndex(fpPDF, Int32(index), &width, &height)

        let size = CGSize(width: width, height: height)
        return size
    }

    func page(atIndex index: Int) -> PDFPage? {
        guard let pageIndex = intToNSNumber[index] else {
            return nil
        }

        if let page = pages.object(forKey: pageIndex) {
            return page
        }

        guard let cgPDFPage = cgPDF.page(at: index + 1) else {
            return nil
        }
        guard let fpPDFPage = FPDF_LoadPage(self.fpPDF, Int32(index)) else {
            return nil
        }

        let page = PDFPage(cgPage: cgPDFPage, fpPage: fpPDFPage)

        pages.setObject(page, forKey: pageIndex)

        return page
    }


}
