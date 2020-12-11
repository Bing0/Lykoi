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
    }
}