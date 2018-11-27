//
//  AppDelegate.swiftWindowController
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Cocoa

@NSApplicationMain
/// Handle events comming from the window, keyboard shortcuts, the toolbar and the TouchBar
class AppDelegate: NSWindowController, NSApplicationDelegate {

	/// Called when the window is loaded, used to specify the window's properties
	override func windowDidLoad() {
		window!.titleVisibility = .hidden
	}
	
	/// Called when the user wants to browse to open a file
	///
	/// Sends a "openFile" notification wit the filename attached to it
	///
	/// - Parameter sender: Element sending the event
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

	/// Called when a file is opened from the "recently opened" interface.
	///
	/// Sends a "openFile" notification wit the filename attached to it
	///
	/// - Parameters:
	///   - sender: Element sending the evnt
	///   - filename: Path to the file to open
	/// - Returns: Returns true to confirm the file has been opened.
	func application(_ sender: NSApplication, openFile filename: String) -> Bool {
		NotificationCenter.default.post(name: Notifications.openFile.name, object: filename)

		return true;
	}

	/// Called when the user wants to save the current render.
	///
	/// Sends a "saveRender" notification
	///
	/// - Parameter sender: Element sending the event
	@IBAction func onSave(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.saveRender.name, object: nil)
	}


	/// Called when the user wants to close/open the siedebar
	///
	/// Sends a "toggleSidebar" notification
	///
	/// - Parameter sender: Element sending the event
	@IBAction func toggleSidebar(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.toggleSidebar.name, object: nil)
	}


	/// Called when the user wants to add a new effect.
	///
	/// Sends a "addEffect" notification
	///
	/// - Parameter sender: Element sending the event
	@IBAction func addEffect(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.addEffect.name, object: nil)
	}


	/// Outlet to the Play/Pause Button
	@IBOutlet var playPauseBtn: NSSegmentedControl!

	/// Called when the user wants to start/stop the render loop
	///
	/// Updates the Play/Pause btn and sends a "stopRenderLoop" or "startRenderLoop" notification
	///
	/// - Parameter sender: Element sending the event
	@IBAction func toggleRenderLoop(_ sender: Any) {
		if(MetalEngine.instance.hasRenderLoop) {
			// Stop the render loop
			NotificationCenter.default.post(name: Notifications.stopRenderLoop.name, object: false)
			playPauseBtn.setImage(NSImage(named: NSImage.touchBarPlayTemplateName), forSegment: 0)
			playPauseBtn.setLabel("Play", forSegment: 0)

			return
		}

		// End the render loop
		NotificationCenter.default.post(name: Notifications.startRenderLoop.name, object: false)
		playPauseBtn.setImage(NSImage(named: NSImage.touchBarPauseTemplateName), forSegment: 0)
		playPauseBtn.setLabel("Pause", forSegment: 0)
	}


	/// Called when the user wants to restart the render
	///
	/// Sends a resetRender notification
	///
	/// - Parameter sender: Element sending the event
	@IBAction func restartRender(_ sender: Any) {
		NotificationCenter.default.post(name: Notifications.resetRender.name, object: nil)
	}
}
