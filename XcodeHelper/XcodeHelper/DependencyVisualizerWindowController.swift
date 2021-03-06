//
//  DependencyVisualizerWindowController.swift
//  XcodeHelper
//
//  Created by dhcdht on 2016/11/29.
//  Copyright © 2016年 XH. All rights reserved.
//

import Cocoa

class DependencyVisualizerWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    // MARK: - IBAction

    @IBAction func projectTypeRadioButtonTapped(sender: NSButton) -> Void {
        if let type = ProjectType(rawValue: sender.tag) {
            self.projectType = type
        }
    }

    @IBAction func outputPathSelectButtonTapped(sender: AnyObject) -> Void {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        if openPanel.runModal() == NSModalResponseOK {
            if let url = openPanel.directoryURL {
                self.outputPathField?.stringValue = url.path
            }
        }
    }

    @IBAction func generateButtonTapped(sender: AnyObject) -> Void {
        if let projectName = self.projectNameField?.stringValue, let outputPath = self.outputPathField?.stringValue {
            DependencyVisualizer.copyDependencyResources(toPath: outputPath, completion: { (output, error) in
                var type = DependencyVisualizer.ProjectType.ObjectiveC
                if self.projectType == ProjectType.Swift {
                    type = DependencyVisualizer.ProjectType.Swift
                }
                var target: String?
                if let targetName = self.targetNameField?.stringValue {
                    if !targetName.isEmpty {
                        target = targetName
                    }
                }
                DependencyVisualizer.generatDependencyJSFile(projectName: projectName, targetName: target, projectType: type, outputPath: outputPath.stringByAppendPathComponent("origin.js"), completion: { (output, error) in
                    if let _ = error {
                        guard let window = self.window, let output = output else {
                            // TODO: error
                            return
                        }
                        let alert = NSAlert()
                        alert.messageText = output
                        alert.beginSheetModal(for: window, completionHandler: nil)
                    } else {
                        let shell = Shell()
                        shell.executeCommand(command: "/bin/cp", arguments: [outputPath.stringByAppendPathComponent("origin.js"), outputPath.stringByAppendPathComponent("origin.js.bak")], completion: { (output, error) in
                            NSWorkspace.shared().openFile(outputPath.stringByAppendPathComponent("index.html"))
                        })
                    }
                })
            })
        }
    }

    @IBAction func filterButtonTapped(sender: AnyObject) -> Void {
        if let regex = self.filterRegexField?.stringValue {
            if !regex.isEmpty {
                if let outputPath = self.outputPathField?.stringValue {
                    DependencyVisualizer.filterDependencyJSFile(regex: regex, outputPath: outputPath, completion: { (output, error) in
                        if let _ = error {
                            guard let window = self.window, let output = output else {
                                // TODO: error
                                return
                            }
                            let alert = NSAlert()
                            alert.messageText = output
                            alert.beginSheetModal(for: window, completionHandler: nil)
                        } else {
                            NSWorkspace.shared().openFile(outputPath.stringByAppendPathComponent("index.html"))
                        }
                    })
                }
            }
        }
    }

    // MARK: - Private

    enum ProjectType : Int {
        case ObjectiveC = 0
        case Swift = 1
    }

    private var projectType = ProjectType.ObjectiveC

    @IBOutlet private var projectNameField: NSTextField?
    @IBOutlet private var targetNameField: NSTextField?
    @IBOutlet private var outputPathField: NSTextField?
    @IBOutlet private var filterRegexField: NSTextField?
}
