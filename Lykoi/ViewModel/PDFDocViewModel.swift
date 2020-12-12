//
// Created by Thomas on 2020/12/11.
//

import Foundation
import CocoaLumberjack

class PDFDocViewModel: ObservableObject {
    init() {
        DDLog.add(DDOSLogger.sharedInstance)

        dynamicLogLevel = .warning

        DDLogVerbose("Verbose")
        DDLogDebug("Debug")
        DDLogInfo("Info")
        DDLogWarn("Warn")
        DDLogError("Error")
        
        var config = FPDF_LIBRARY_CONFIG(version: 2, m_pUserFontPaths: nil, m_pIsolate: nil, m_v8EmbedderSlot: 0, m_pPlatform: nil)
        FPDF_InitLibraryWithConfig(&config)
        FPDF_DestroyLibrary()
    }
}
