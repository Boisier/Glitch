//
//  AppDelegate.swiftWindowController
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSWindowController, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	override func windowDidLoad() {
		window!.titleVisibility = .hidden
	}
	
	@IBAction func onOpen(_ sender: Any) {
		let dialog = NSOpenPanel();

		dialog.title                   = "Sélectionner une image";
		dialog.showsResizeIndicator    = true;
		dialog.showsHiddenFiles        = false;
		dialog.canChooseDirectories    = false;
		dialog.canChooseFiles		   = true;
		dialog.canCreateDirectories    = true;
		dialog.allowsMultipleSelection = false;
		dialog.allowedFileTypes        = NSImage.imageTypes;

		if (dialog.runModal() == NSApplication.ModalResponse.OK) {
			let result = dialog.url // Pathname of the file

			guard let filepath = result?.path else { return }

			NotificationCenter.default.post(name: Notifications.openFile.name, object: filepath)

		} else {
			// User clicked on "Cancel"
			return
		}
	}

	func application(_ sender: NSApplication, openFile filename: String) -> Bool {
		NotificationCenter.default.post(name: Notifications.openFile.name, object: filename)

		return true;
	}

	@IBAction func onSave(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.saveRender.name, object: nil)
	}

	@IBAction func toggleSidebar(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.toggleSidebar.name, object: nil)
	}

	@IBAction func addEffect(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.addEffect.name, object: nil)
	}

	private var _renderLoopActive: Bool = true
	@IBOutlet var playPauseLabel: NSToolbarItem!
	@IBOutlet var playPauseBtn: NSSegmentedControl!

	@IBAction func toggleRenderLoop(_ sender: Any) {
		if(_renderLoopActive) {
			_renderLoopActive = false
			playPauseLabel.label = "Play"
			playPauseBtn.setImage(NSImage(named: NSImage.touchBarPlayTemplateName), forSegment: 0)
			NotificationCenter.default.post(name: Notifications.stopRenderLoop.name, object: false)

			return
		}

		_renderLoopActive = true
		playPauseLabel.label = "Pause"
		playPauseBtn.setImage(NSImage(named: NSImage.touchBarPauseTemplateName), forSegment: 0)
		NotificationCenter.default.post(name: Notifications.startRenderLoop.name, object: false)
	}

	@IBAction func restartRender(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.resetRender.name, object: nil)
	}
}
