//  ThreeStateCheckbox.swift
//  NA Meeting List Administrator
//
//  Created by MAGSHARE.
//
//  Copyright 2017 MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NA Meeting List Administrator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.

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
    /* This is a functional interface to ensure that the control gets redrawn when the state changes. */
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
            self.setBackgroundImage(UIImage(named: "checkbox-clear"), for: UIControl.State())
            self.setBackgroundImage(UIImage(named: "checkbox-clear-highlight"), for: UIControl.State.selected)
            self.setBackgroundImage(UIImage(named: "checkbox-clear-highlight"), for: UIControl.State.highlighted)
            self.setBackgroundImage(UIImage(named: "checkbox-clear-highlight"), for: UIControl.State.disabled)
        case .Selected:
            self.setBackgroundImage(UIImage(named: "checkbox-selected"), for: UIControl.State())
            self.setBackgroundImage(UIImage(named: "checkbox-selected-highlight"), for: UIControl.State.selected)
            self.setBackgroundImage(UIImage(named: "checkbox-selected-highlight"), for: UIControl.State.highlighted)
            self.setBackgroundImage(UIImage(named: "checkbox-selected-highlight"), for: UIControl.State.disabled)
        case .Deselected:
            self.setBackgroundImage(UIImage(named: "checkbox-unselected"), for: UIControl.State())
            self.setBackgroundImage(UIImage(named: "checkbox-unselected-highlight"), for: UIControl.State.selected)
            self.setBackgroundImage(UIImage(named: "checkbox-unselected-highlight"), for: UIControl.State.highlighted)
            self.setBackgroundImage(UIImage(named: "checkbox-unselected-highlight"), for: UIControl.State.disabled)
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
