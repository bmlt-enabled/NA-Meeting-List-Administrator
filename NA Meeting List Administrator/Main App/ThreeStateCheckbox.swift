//  ThreeStateCheckbox.swift
//  NA Meeting List Administrator
//
//  Created by MAGSHARE.
//
//  Created by BMLT-Enabled
//
//  https://bmlt.app/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 BMLT-Enabled
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import BMLTiOSLib

/* ###################################################################################################################################### */
/**
    This is a simple subclass of the standard UIButton class, where we provide custom images, and record 3 different states ("Clear", Selected" or "Deselected").
    It uses the states in the BMLTiOSLib file, so it will match the 3 states of the associated object.
*/
class ThreeStateCheckbox: UIButton {
    /** This will hold any extra data we want to associate with the checkbox. */
    var extraData: AnyObject?
    /** If this is true, then we can only have on and off. If false, then we have 3 states. Default is false. */
    var binaryState: Bool = false
    
    /** This holds the actual state condition. This should not be accessed outside the class. */
    internal var _selectionState: BMLTiOSLibSearchCriteria.SelectionState = BMLTiOSLibSearchCriteria.SelectionState.Clear
    /** This is a functional interface to ensure that the control gets redrawn when the state changes. */
    var selectionState: BMLTiOSLibSearchCriteria.SelectionState {
        get {
            return self._selectionState
        }
        set {
            var newVal: BMLTiOSLibSearchCriteria.SelectionState = .Clear
            
            // If we are in "binary" mode, then we can only be selected or clear.
            if self.binaryState && (.Deselected != newValue) {
                newVal = newValue
            }

            if self._selectionState != newVal {
                self._selectionState = newVal
                self.sendActions(for: UIControl.Event.valueChanged)
                self.setNeedsLayout()
            }
        }
    }
    
    /* ################################################################## */
    /**
        We deal with the displayed images as background images, and we
        select those images when our subviews are laid out.
    */
    override func layoutSubviews() {
        switch self.selectionState {
        case .Clear:
            self.setImage(UIImage(named: "checkbox-clear"), for: .normal)
        case .Selected:
            self.setImage(UIImage(named: "checkbox-selected"), for: .normal)
        case .Deselected:
            self.setImage(UIImage(named: "checkbox-unselected"), for: .normal)
        }
        super.layoutSubviews()
    }
    
    /* ################################################################## */
    /**
        We react to releases of a touch within the control by toggling the checked state.
    
        :param: touch The touch object.
        :param: event The event driving the touch.
    */
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if(nil != touch) && (nil != self.hitTest(touch!.location(in: self), with: event)) {
            switch self.selectionState {
            case .Clear:
                self.selectionState = .Selected
            case .Selected:
                self.selectionState = self.binaryState ? .Clear : .Deselected
            case .Deselected:
                self.selectionState = .Clear
            }
        }
    }
}
