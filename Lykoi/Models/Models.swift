//
//  Models.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/21.
//

import Foundation

struct ParentInfo: Hashable {
    var name: String
    var url: URL
}

struct DirectoryContent {
    var currentURL: URL

    private var _parentsInfo: [ParentInfo]
    var parentsInfo: [ParentInfo] {
        _parentsInfo
    }

    private var _content: [URL]
    var content: [URL] {
        _content
    }

    init() {
        self.init(getDocumentsDirectory())
    }


    init(_ url: URL) {
        currentURL = url
        _content = urlOfContents(in: url)
        _parentsInfo = [ParentInfo]()

        let rootURL = getDocumentsDirectory()
        var tmpURL = currentURL
        while tmpURL != rootURL {
            let name = tmpURL.lastPathComponent
            _parentsInfo.append(ParentInfo(name: name, url: tmpURL))
            tmpURL.deleteLastPathComponent()
        }

        _parentsInfo.append(ParentInfo(name: "Home", url: rootURL))
        _parentsInfo.reverse()
    }

}


fileprivate func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


fileprivate func urlOfContents(in documentsURL: URL, skipsHiddenFiles: Bool = true) -> [URL] {
    let fileURLs = try? FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [])
    return fileURLs ?? [URL]()
}

extension URL {
    func relativeToHome() -> String {
        let homeAbsolutePath = getDocumentsDirectory().resolvingSymlinksInPath().absoluteString
        let absoluteString = resolvingSymlinksInPath().absoluteString
        guard absoluteString.hasPrefix(homeAbsolutePath) else {
            return self.absoluteString
        }

        let str = String(absoluteString.dropFirst(homeAbsolutePath.count))

        return str
    }
}


enum EditingMode {
    case hand
    case highlight
    case draw
}

