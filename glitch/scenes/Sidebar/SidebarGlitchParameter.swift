//
//  SidebarGlitchParameter.swift
//  glitch
//
//  Created by Valentin Dufois on 20/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit
import Darwin

/// Represent a parameter in the sidebar and handles all interactions that come with it
///
/// - Note: This class is awaiting a massive refactor as the way it handles parameter values
/// is not very efficient and do not promote reusability
class SidebarGlitchParameter: NSTableCellView {
	// The effect object
	var _glitchEffect:GlitchEffect!

	// The parameter object
	var _glitchParameter:GlitchParameter!

	// /////////////////////
	// The parameter values

	/// The X/first value
	var _firstValue:GlitchParameterValue!

	/// The Y/second value
	var _secondValue:GlitchParameterValue!

	/// The Z/third
	var _thirdValue:GlitchParameterValue!

	// //////////////////////
	// MARK: - View bindings

	/// Outlet to the title field
	@IBOutlet var title: NSTextField!

	/// Outlet to the label of the first field
	@IBOutlet var firstInputLabel: NSTextField!

	/// Outlet to the first field
	@IBOutlet var firstInputField: NSTextField!

	/// Called when the first field value changes
	@IBAction func firstInputFieldChanged(_ sender: Any) {
		firstInputStepper.floatValue = Float(firstInputField.floatValue)
		firstInputField.floatValue = firstInputStepper.floatValue
		_firstValue.value = firstInputStepper.floatValue
	}

	/// Outlet to the first input stepper
	@IBOutlet var firstInputStepper: NSStepper!

	/// Called when the first stepper is clicked
	@IBAction func firstInputStepperClicked(_ sender: NSStepper) {
		firstInputField.floatValue = sender.floatValue
		_firstValue.value = firstInputStepper.floatValue
	}

	/// outlet to the first input unit label
	@IBOutlet var firstInputUnit: NSTextField!


	// /////////////////////////////////////////
	/// Outlet to the label of the second field
	@IBOutlet var secondInputLabel: NSTextField!

	/// Outlet to the second field
	@IBOutlet var secondInputField: NSTextField!

	/// Called when the second field value changes
	@IBAction func secondInputFieldChanged(_ sender: Any) {
		secondInputStepper.floatValue = Float(secondInputField.floatValue)
		secondInputField.floatValue = secondInputStepper.floatValue
		_secondValue.value = secondInputStepper.floatValue
	}

	/// Outlet to the second input stepper
	@IBOutlet var secondInputStepper: NSStepper!

	/// Called when the second stepper is clicked
	@IBAction func secondInputStepperClicked(_ sender: NSStepper) {
		secondInputField.floatValue = sender.floatValue
		_secondValue.value = secondInputStepper.floatValue
	}

	/// outlet to the second input unit label
	@IBOutlet var secondInputUnit: NSTextField!


	// ////////////////////////////////////////
	/// Outlet to the label of the third field
	@IBOutlet var thirdInputLabel: NSTextField!

	/// Outlet to the third field
	@IBOutlet var thirdInputField: NSTextField!

	/// Called when the third field value changes
	@IBAction func thirdInputFieldChanged(_ sender: Any) {
		thirdInputStepper.floatValue = Float(thirdInputField.floatValue)
		thirdInputField.floatValue = thirdInputStepper.floatValue
		_thirdValue.value = thirdInputStepper.floatValue
	}

	/// Outlet to the third input stepper
	@IBOutlet var thirdInputStepper: NSStepper!

	/// Called when the third stepper is clicked
	@IBAction func thirdInputStepperClicked(_ sender: NSStepper) {
		thirdInputField.floatValue = sender.floatValue
		_thirdValue.value = thirdInputStepper.floatValue
	}

	/// outlet to the third input unit label
	@IBOutlet var thirdInputUnit: NSTextField!

}

// MARK: - Initialization
extension SidebarGlitchParameter {
	/// Set the glitch effect and parameter this view refers to.
	///
	/// - Parameters:
	///   - effect: The effect
	///   - parameter: The parameter of the given effect
	func set(effect: GlitchEffect, parameter: GlitchParameter) {
		_glitchEffect = effect
		_glitchParameter = parameter

		// Set up the interface based on the parameter
		switch _glitchParameter.type {
		case .float, .int:
			// Store value object
			_firstValue = _glitchParameter.x

			setupForSingleValue()
		case .position2D:
			// Store values objects
			_firstValue = _glitchParameter.x
			_secondValue = _glitchParameter.y

			setupForDoubleValue()
		case .position3D:
			// Store values objects
			_firstValue = _glitchParameter.x
			_secondValue = _glitchParameter.y
			_thirdValue = _glitchParameter.z

			setupForDoubleValue()
		}

		// Add observers
		NotificationCenter.default.addObserver(self, selector: #selector(onWindowResize), name: Notifications.windowResized.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onScroll), name: Notifications.userScrolled.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onMagnify), name: Notifications.userMagnified.name, object: nil)
	}

	/// Set up the viewto use only the first value
	private func setupForSingleValue() {
		// Hide unessecary elements
		title.removeFromSuperview()
		hideSecondField()
		hideThirdField()

		// Set up labels
		firstInputLabel.stringValue = _firstValue.label ?? _glitchParameter.name
		firstInputLabel.font = title.font

		// Set up the field and the stepper
		setupFirstField()
	}

	/// Set up the view to use only the two first values
	private func setupForDoubleValue() {
		// Hide unessecary elements
		hideThirdField()

		// Set up labels
		title.stringValue = _glitchParameter.name

		// Set up the field and the stepper
		setupFirstField()
		setupSecondField()
	}

	/// Set up the view to use only the three first values
	private func setupForTripleValue() {
		// Set up labels
		title.stringValue = _glitchParameter.name

		// Set up the field and the stepper
		setupFirstField()
		setupSecondField()
		setupThirdField()
	}

	/// Convenient setup method for the first field
	private func setupFirstField() {
		setup(field: firstInputField, stepper: firstInputStepper, unit: firstInputUnit, label: firstInputLabel, with: _firstValue)
	}

	/// Convenient setup method for the second field
	private func setupSecondField() {
		setup(field: secondInputField, stepper: secondInputStepper, unit: secondInputUnit, label: secondInputLabel, with: _secondValue)
	}

	/// Convenient setup method for the third field
	private func setupThirdField() {
		setup(field: thirdInputField, stepper: thirdInputStepper, unit: thirdInputUnit, label: thirdInputLabel, with: _thirdValue)
	}

	/// Set up the given views with the given value
	///
	/// - Parameters:
	///   - field: The field
	///   - stepper: The stepper
	///   - unit: The unit label
	///   - label: The field label
	///   - value: The GlitchValue
	private func setup(field: NSTextField, stepper: NSStepper, unit: NSTextField, label: NSTextField, with value:GlitchParameterValue) {
		let formatter = field.formatter! as! NumberFormatter
		formatter.minimumFractionDigits = value.precision
		formatter.maximumFractionDigits = value.precision

		stepper.minValue = value.min == nil ? .leastNormalMagnitude : Double(value.min!)
		stepper.maxValue = value.max == nil ? .greatestFiniteMagnitude : Double(value.max!)
		stepper.increment = Double(value.step)
		stepper.floatValue = value.startValue ?? 0.0

		field.floatValue = stepper.floatValue

		if(value.label != nil) {
			label.stringValue = value.label!
		}

		if let unitValue = value.unit {
			unit.stringValue = unitValue
		} else {
			unit.stringValue = ""
		}
		unit.sizeToFit()

		field.isEnabled = true
	}

	/// Completely removes the second field from the view
	private func hideSecondField() {
		secondInputField.removeFromSuperview()
		secondInputLabel.removeFromSuperview()
		secondInputStepper.removeFromSuperview()
		secondInputUnit.removeFromSuperview()
	}

	/// Completely removes the third field from the view
	private func hideThirdField() {
		thirdInputField.removeFromSuperview()
		thirdInputLabel.removeFromSuperview()
		thirdInputStepper.removeFromSuperview()
		thirdInputUnit.removeFromSuperview()
	}
}


// MARK: - Field updates
extension SidebarGlitchParameter {
	/// Convenient method to update the first field
	///
	/// - Parameter value: New value for the field
	func updateFirstFieldWith(value: Float) {
		update(field: firstInputField, stepper: firstInputStepper, value: _firstValue, with: value)
	}

	/// Convenient method to update the second field
	///
	/// - Parameter value: New value for the field
	func updateSecondFieldWith(value: Float) {
		update(field: secondInputField, stepper: secondInputStepper, value: _secondValue, with: value)
	}

	/// Convenient method to update the third field
	///
	/// - Parameter value: New value for the field
	func updateThirdFieldWith(value: Float) {
		update(field: thirdInputField, stepper: thirdInputStepper, value: _thirdValue, with: value)
	}

	/// Update the value and its associated view with the given new value
	///
	/// - Parameters:
	///   - field: The field to update
	///   - stepper: The stepper to update
	///   - value: The GlitchValue to update
	///   - newValue: The new value
	func update(field: NSTextField, stepper: NSStepper, value: GlitchParameterValue, with newValue: Float) {
		stepper.floatValue = newValue
		field.floatValue = stepper.floatValue
		value.value = stepper.floatValue
	}
}


// MARK: - Events
extension SidebarGlitchParameter {
	/// Called when the window resize, this update the fields values.
	@objc
	func onWindowResize() {
		if let firstValue = _firstValue {
			refresh(field: firstInputField, stepper: firstInputStepper, with: firstValue)
		}

		if let secondValue = _secondValue {
			refresh(field: secondInputField, stepper: secondInputStepper, with: secondValue)
		}

		if let thirdValue = _thirdValue {
			refresh(field: thirdInputField, stepper: thirdInputStepper, with: thirdValue)
		}
	}

	/// Refresh the given field and stepper with the given GlitchValue
	///
	/// - Parameters:
	///   - field: The field to refresh
	///   - stepper: The stepper to refresh
	///   - value: The source value
	private func refresh(field: NSTextField, stepper: NSStepper, with value:GlitchParameterValue) {
		let currentValuePercent = stepper.floatValue / Float(stepper.maxValue)

		stepper.minValue = value.min == nil ? .leastNormalMagnitude : Double(value.min!)
		stepper.maxValue = value.max == nil ? .greatestFiniteMagnitude : Double(value.max!)

		update(field: field, stepper: stepper, value: value, with: currentValuePercent * Float(stepper.maxValue))
	}

	/// Called when the user scrolls on the view, triggers the appropriate updates on the values
	///
	/// - Parameter obj: The scroll notification
	@objc
	func onScroll(_ obj: NSNotification) {
		guard _glitchEffect.isSelected else { return }

		let event = obj.object as! NSEvent

		let scrollAmountX = Float(event.scrollingDeltaX) * 0.75
		let scrollAmountY = Float(event.scrollingDeltaY) * 0.75

		switch(_glitchParameter.interaction) {
		case .scrollX:
			updateFirstFieldWith(value: firstInputStepper.floatValue + scrollAmountX * _firstValue.step)
		case .scrollY:
			updateFirstFieldWith(value: firstInputStepper.floatValue + scrollAmountY * _firstValue.step)
		case .scroll2D:
			updateFirstFieldWith(value: firstInputStepper.floatValue + scrollAmountX * _firstValue.step)
			updateSecondFieldWith(value: secondInputStepper.floatValue + scrollAmountY * _secondValue.step)
		default: return
		}
	}

	/// Called when the user magnifies on the view, triggers the appropriate updates on the values
	///
	/// - Parameter obj: The magnify update
	@objc
	func onMagnify(_ obj: NSNotification) {
		guard _glitchEffect.isSelected else { return }

		let event = obj.object as! NSEvent

		let scrollAmountZ = Float(event.deltaZ) / 2.0

		switch(_glitchParameter.interaction) {
		case .magnify:
			updateFirstFieldWith(value: firstInputStepper.floatValue + scrollAmountZ)
		default: return
		}
	}
}
