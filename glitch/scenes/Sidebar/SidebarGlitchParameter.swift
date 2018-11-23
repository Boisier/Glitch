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

class SidebarGlitchParameter: NSTableCellView {
	// The effect object
	var _glitchEffect:GlitchEffect!

	// The parameter object
	var _glitchParameter:GlitchParameter!

	// The parameter values
	var _firstValue:GlitchParameterValue!
	var _secondValue:GlitchParameterValue!
	var _thirdValue:GlitchParameterValue!

	// MARK: - View bindings
	@IBOutlet var title: NSTextField!

	@IBOutlet var firstInputLabel: NSTextField!
	@IBOutlet var firstInputField: NSTextField!
	@IBAction func firstInputFieldChanged(_ sender: Any) {
		firstInputStepper.floatValue = Float(firstInputField.floatValue)
		firstInputField.floatValue = firstInputStepper.floatValue
		_firstValue.value = firstInputStepper.floatValue
	}
	@IBOutlet var firstInputStepper: NSStepper!
	@IBAction func firstInputStepperClicked(_ sender: NSStepper) {
		firstInputField.floatValue = sender.floatValue
		_firstValue.value = firstInputStepper.floatValue
	}
	@IBOutlet var firstInputUnit: NSTextField!

	@IBOutlet var secondInputLabel: NSTextField!
	@IBOutlet var secondInputField: NSTextField!
	@IBAction func secondInputFieldChanged(_ sender: Any) {
		secondInputStepper.floatValue = Float(secondInputField.floatValue)
		secondInputField.floatValue = secondInputStepper.floatValue
		_secondValue.value = secondInputStepper.floatValue
	}
	@IBOutlet var secondInputStepper: NSStepper!
	@IBAction func secondInputStepperClicked(_ sender: NSStepper) {
		secondInputField.floatValue = sender.floatValue
		_secondValue.value = secondInputStepper.floatValue
	}
	@IBOutlet var secondInputUnit: NSTextField!

	@IBOutlet var thirdInputLabel: NSTextField!
	@IBOutlet var thirdInputField: NSTextField!
	@IBAction func thirdInputFieldChanged(_ sender: Any) {
		thirdInputStepper.floatValue = Float(thirdInputField.floatValue)
		thirdInputField.floatValue = thirdInputStepper.floatValue
		_thirdValue.value = thirdInputStepper.floatValue
	}
	@IBOutlet var thirdInputStepper: NSStepper!
	@IBAction func thirdInputStepperClicked(_ sender: NSStepper) {
		thirdInputField.floatValue = sender.floatValue
		_thirdValue.value = thirdInputStepper.floatValue
	}
	@IBOutlet var thirdInputUnit: NSTextField!

}

// MARK: - Initialization
extension SidebarGlitchParameter {
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

			setupFor2DPosition()
		case .position3D:
			// Store values objects
			_firstValue = _glitchParameter.x
			_secondValue = _glitchParameter.y
			_thirdValue = _glitchParameter.z

			setupFor2DPosition()
		}

		// Add observers
		NotificationCenter.default.addObserver(self, selector: #selector(onWindowResize), name: NSNotification.Name("windowDidResized"), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onScroll), name: NSNotification.Name("userScrollGlitch"), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onMagnify), name: NSNotification.Name("userMagnifyGlitch"), object: nil)
	}

	func setupForSingleValue() {
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

	func setupFor2DPosition() {
		// Hide unessecary elements
		hideThirdField()

		// Set up labels
		title.stringValue = _glitchParameter.name

		// Set up the field and the stepper
		setupFirstField()
		setupSecondField()
	}

	func setupFor3DPosition() {
		// Set up labels
		title.stringValue = _glitchParameter.name

		// Set up the field and the stepper
		setupFirstField()
		setupSecondField()
		setupThirdField()
	}

	func setupFirstField() {
		setup(field: firstInputField, stepper: firstInputStepper, unit: firstInputUnit, label: firstInputLabel, with: _firstValue)
	}

	func setupSecondField() {
		setup(field: secondInputField, stepper: secondInputStepper, unit: secondInputUnit, label: secondInputLabel, with: _secondValue)
	}

	func setupThirdField() {
		setup(field: thirdInputField, stepper: thirdInputStepper, unit: thirdInputUnit, label: thirdInputLabel, with: _thirdValue)
	}

	func setup(field: NSTextField, stepper: NSStepper, unit: NSTextField, label: NSTextField, with value:GlitchParameterValue) {
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

	func hideSecondField() {
		secondInputField.removeFromSuperview()
		secondInputLabel.removeFromSuperview()
		secondInputStepper.removeFromSuperview()
		secondInputUnit.removeFromSuperview()
	}

	func hideThirdField() {
		thirdInputField.removeFromSuperview()
		thirdInputLabel.removeFromSuperview()
		thirdInputStepper.removeFromSuperview()
		thirdInputUnit.removeFromSuperview()
	}
}


// MARK: - Field updates
extension SidebarGlitchParameter {
	func updateFirstFieldWith(value: Float) {
		update(field: firstInputField, stepper: firstInputStepper, value: _firstValue, with: value)
	}

	func updateSecondFieldWith(value: Float) {
		update(field: secondInputField, stepper: secondInputStepper, value: _secondValue, with: value)
	}

	func updateThirdFieldWith(value: Float) {
		update(field: thirdInputField, stepper: thirdInputStepper, value: _thirdValue, with: value)
	}

	func update(field: NSTextField, stepper: NSStepper, value: GlitchParameterValue, with newValue: Float) {
		stepper.floatValue = newValue
		field.floatValue = stepper.floatValue
		value.value = stepper.floatValue
	}
}


// MARK: - Events
extension SidebarGlitchParameter {
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

	private func refresh(field: NSTextField, stepper: NSStepper, with value:GlitchParameterValue) {
		let currentValuePercent = stepper.floatValue / Float(stepper.maxValue)

		stepper.minValue = value.min == nil ? .leastNormalMagnitude : Double(value.min!)
		stepper.maxValue = value.max == nil ? .greatestFiniteMagnitude : Double(value.max!)

		update(field: field, stepper: stepper, value: value, with: currentValuePercent * Float(stepper.maxValue))
	}

	@objc
	func onScroll(_ obj: NSNotification) {
		guard _glitchEffect.isSelected else { return }

		let event = obj.object as! NSEvent

		let scrollAmountX = Float(event.scrollingDeltaX) * 0.75
		let scrollAmountY = Float(event.scrollingDeltaY) * 0.75

		switch(_glitchParameter.interaction) {
		case .scrollX:
			updateFirstFieldWith(value: firstInputStepper.floatValue + scrollAmountX)
		case .scrollY:
			updateFirstFieldWith(value: firstInputStepper.floatValue + scrollAmountY)
		case .scroll2D:
			updateFirstFieldWith(value: firstInputStepper.floatValue + scrollAmountX)
			updateSecondFieldWith(value: secondInputStepper.floatValue + scrollAmountY)
		default: return
		}
	}

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
