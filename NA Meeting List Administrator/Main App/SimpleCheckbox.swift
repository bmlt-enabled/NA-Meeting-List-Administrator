//
//  SimpleCheckbox.swift
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

/* ###################################################################################################################################### */
/**
    This is a simple subclass of the standard UIButton class, where we provide custom images, and record a state as "checked" or "not checked."
    You should query the state of the "checked" property to determine the checkbox state.
*/
class SimpleCheckbox: UIButton {
    /** This holds the actual checked condition. If true, then the control is checked. This should not be accessed outside the class. */
    internal var _checked: Bool = false
    /** This is a flag we set to keep the checkbox from being caught in a loop, if the handler changes the value. */
    private var _actionItem: Bool = false
    /** We use this to associate any extra data we want with the instance. */
    var extraData: Any? = nil
    
    /* This is a functional interface to ensure that the control gets redrawn when the state changes. */
    var checked: Bool {
        get {
            return self._checked
        }
        set {
            if !self._actionItem {
                self._checked = newValue
                self._actionItem = true // This prevens us from looping forever.
                self.sendActions(for: UIControlEvents.valueChanged)
                self._actionItem = false
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
        super.layoutSubviews()
        if let testImage = UIImage(named: "Checkbox-unselected") {
            self.bounds.size = testImage.size
            if(self.checked) {
                self.setBackgroundImage(UIImage(named: "Checkbox-selected"), for: UIControlState())
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControlState.selected)
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControlState.highlighted)
                self.setBackgroundImage(UIImage(named: "Checkbox-selected-highlight"), for: UIControlState.disabled)
            }
            else {
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected"), for: UIControlState())
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControlState.selected)
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControlState.highlighted)
                self.setBackgroundImage(UIImage(named: "Checkbox-unselected-highlight"), for: UIControlState.disabled)
            }
        }
    }
    
    /* ################################################################## */
    /**
        We react to releases of a touch within the control by toggling the checked state.
    
        :param: touch The touch object.
        :param: event The event driving the touch.
    */
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if((nil != touch) && (nil != self.hitTest(touch!.location(in: self), with: event))) {
            self.checked = !self.checked
        }
    }
}
