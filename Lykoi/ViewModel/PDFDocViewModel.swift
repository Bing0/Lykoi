//
//  PDFDocViewModel.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/21.
//

import Foundation


class PDFDocViewModel: ObservableObject {
    @Published var directoryContent: DirectoryContent
    private var folderMonitor: FolderMonitor?

    init() {
        directoryContent = DirectoryContent()
        monitorURLOf(directoryContent.currentURL)

        var config
            = FPDF_LIBRARY_CONFIG(version: 3, m_pUserFontPaths: nil, m_pIsolate: nil, m_v8EmbedderSlot: 0, m_pPlatform: nil)
        FPDF_InitLibraryWithConfig(&config)
    }

    deinit {
        FPDF_DestroyLibrary()
    }

    func copy(from sourceURL: URL) {
        let fileName       = sourceURL.lastPathComponent
        let destinationURL = directoryContent.currentURL.appendingPathComponent(fileName)
        let isAccessing: Bool
        do {
            isAccessing = sourceURL.startAccessingSecurityScopedResource()
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        } catch {
            print("copy failed. \(error)")
        }

        if isAccessing {
            sourceURL.stopAccessingSecurityScopedResource()
        }
    }

    func enter(newURL url: URL) {
        directoryContent = DirectoryContent(url)
        monitorURLOf(directoryContent.currentURL)
    }

    func reload() {
        enter(newURL: directoryContent.currentURL)
    }

    private func monitorURLOf(_ currentURL: URL) {
        folderMonitor?.stopMonitoring()

        folderMonitor = FolderMonitor(url: currentURL) {
            DispatchQueue.main.async {
                self.directoryContent = DirectoryContent(currentURL)
            }
        }
        folderMonitor?.startMonitoring()
    }
}


fileprivate class FolderMonitor {
    // MARK: Properties

    /// A file descriptor for the monitored directory.
    private var monitoredFolderFileDescriptor: CInt = -1
    /// A dispatch queue used for sending file changes in the directory.
    private let folderMonitorQueue                  = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)
    /// A dispatch source to monitor a file descriptor created from the directory.
    private var folderMonitorSource:           DispatchSourceFileSystemObject?
    /// URL for the directory being monitored.
    let url: Foundation.URL

    var folderDidChange: (() -> Void)

    // MARK: Initializers
    init(url: Foundation.URL, callback: @escaping (() -> Void)) {
        self.url = url
        self.folderDidChange = callback
    }

    // MARK: Monitoring
    /// Listen for changes to the directory (if we are not already).
    func startMonitoring() {
        guard folderMonitorSource == nil && monitoredFolderFileDescriptor == -1 else {
            return

        }
        // Open the directory referenced by URL for monitoring only.
        monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)
        // Define a dispatch source monitoring the directory for additions, deletions, and renamings.
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor, eventMask: .write, queue: folderMonitorQueue)
        // Define the block to call when a file change is detected.
        folderMonitorSource?.setEventHandler { [weak self] in
            self?.folderDidChange()
        }
        // Define a cancel handler to ensure the directory is closed when the source is cancelled.
        folderMonitorSource?.setCancelHandler { [weak self] in
            guard let strongSelf = self else {
                return
            }
            close(strongSelf.monitoredFolderFileDescriptor)
            strongSelf.monitoredFolderFileDescriptor = -1
            strongSelf.folderMonitorSource = nil
        }
        // Start monitoring the directory via the source.
        folderMonitorSource?.resume()
    }

    /// Stop listening for changes to the directory, if the source has been created.
    func stopMonitoring() {
        folderMonitorSource?.cancel()
    }
}
