//  MapMarker.swift
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

/**
 This file contains a couple of classes that allow us to establish and manipulate markers in our map.
 */

import MapKit
import BMLTiOSLib

/* ###################################################################################################################################### */
// MARK: - Annotation Class -
/* ###################################################################################################################################### */
/**
 This handles the marker annotation.
 */
class MapAnnotation: NSObject, MKAnnotation, NSCoding {
    /// The Dictionary key for the coordinate object.
    let sCoordinateObjectKey: String = "MapAnnotation_Coordinate"
    /// The Dictionary key for the associated meetings.
    let sMeetingsObjectKey: String = "MapAnnotation_Meetings"

    /// The coordinate for this annotation.
    @objc var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    /// The meetings associated with this annotation.
    var locations: [BMLTiOSLibMeetingNode] = []
    
    /* ################################################################## */
    /**
     Default initializer.
     
     - parameter coordinate: the coordinate for this annotation display.
     - parameter locations: a list of locations to be assigned to this annotation.
     */
    init(coordinate: CLLocationCoordinate2D, locations: [BMLTiOSLibMeetingNode]) {
        self.coordinate = coordinate
        self.locations = locations
    }
    
    /* ################################################################## */
    // MARK: - NSCoding Protocol Methods -
    /* ################################################################## */
    /**
     This method will restore the locations and coordinate objects from the coder passed in.
     
     - parameter aDecoder: The coder that will contain the coordinates.
     */
    @objc required init?(coder aDecoder: NSCoder) {
        if let locations = aDecoder.decodeObject(forKey: self.sMeetingsObjectKey) as? [BMLTiOSLibMeetingNode] {
            self.locations = locations
            if let tempCoordinate = aDecoder.decodeObject(forKey: self.sCoordinateObjectKey) as? [NSNumber] {
                self.coordinate.longitude = tempCoordinate[0].doubleValue
                self.coordinate.latitude = tempCoordinate[1].doubleValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     This method saves the locations and coordinates as part of the serialization.
     
     - parameter aCoder: The coder that contains the coordinates.
     */
    @objc func encode(with aCoder: NSCoder) {
        let long: NSNumber = NSNumber(value: self.coordinate.longitude as Double)
        let lat: NSNumber = NSNumber(value: self.coordinate.latitude as Double)
        let values: [NSNumber] = [long, lat]
        
        aCoder.encode(values, forKey: self.sCoordinateObjectKey)
        aCoder.encode(self.locations, forKey: self.sMeetingsObjectKey)
    }
}

/* ###################################################################################################################################### */
// MARK: - Marker Class -
/* ###################################################################################################################################### */
/**
 This handles our map marker.
 */
class MapMarker: MKAnnotationView {
    /* ################################################################## */
    // MARK: - Constant Properties -
    /* ################################################################## */
    /// The Dictionary key for the annotation object.
    let sAnnotationObjectKey: String = "MapMarker_Annotation"
    /// The offset Y
    let sRegularAnnotationOffsetUp: CGFloat     = 0; /**< This is how many display units to shift the annotation view up. */
    /// The offset X
    let sRegularAnnotationOffsetRight: CGFloat  = 0;  /**< This is how many display units to shift the annotation view right. */

    /* ################################################################## */
    // MARK: - Private Properties -
    /* ################################################################## */
    /// The current frame index of the animating marker.
    private var _currentFrame: Int = 0
    /// The timer for each animation step.
    private var _animationTimer: Timer! = nil
    /// The images to be used as annotation frames.
    private var _animationFrames: [UIImage] = []
    
    /* ################################################################## */
    // MARK: - Computed Properties -
    /* ################################################################## */
    /**
     We override this, so we can be sure to refresh the need for a draw state when draggable is set (Meaning it's a black marker).
     */
    override var isDraggable: Bool {
        get {
            return super.isDraggable
        }
        
        set {
            super.isDraggable = newValue
            self.setNeedsDisplay()
        }
    }

    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation prpoerty.
     */
    var coordinate: CLLocationCoordinate2D {
        return (self.annotation?.coordinate)!
    }
    
    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation property.
     */
    var locations: [BMLTiOSLibMeetingNode] {
        if let locations = (self.annotation as? MapAnnotation)?.locations {
            return locations
        }
        
        return []
    }
    
    /* ################################################################## */
    /**
     Loads our array of animation frames from the resource file.
     */
    var animationFrames: [UIImage] {
        // First time through, we load up on our animation frames.
        if self._animationFrames.isEmpty && self.isDraggable {
            let baseNameFormat = "DragMarker/Frame%02d"
            var index = 1
            while let image = UIImage(named: String(format: baseNameFormat, index)) {
                self._animationFrames.append(image)
                index += 1
            }
            
            self._currentFrame = 0
        }
        
        return self._animationFrames
    }
    
    /* ################################################################## */
    // MARK: - Ininializer -
    /* ################################################################## */
    /**
     The default initializer.
     
     - parameter annotation: The annotation that represents this instance.
     - parameter draggable: If true, then this will be draggable (ignored if the annotation has more than one meeting).
     */
    init(annotation: MKAnnotation?, draggable: Bool, reuseID: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseID)
        self.isDraggable = draggable
        _ = self.animationFrames    // This pre-loads our animation, if necessary.
        
        self.backgroundColor = UIColor.clear
        self.image = self.selectImage(false)
        self.centerOffset = CGPoint(x: self.sRegularAnnotationOffsetRight, y: self.sRegularAnnotationOffsetUp)
    }
    
    /* ################################################################## */
    // MARK: - Instance Methods -
    /* ################################################################## */
    /**
     This selects the appropriate image for our display.
     
     - parameter inAnimated: If true, then the drag will be animated.
     
     - returns: an image to be displayed for the marker.
     */
    func selectImage(_ inAnimated: Bool) -> UIImage! {
        var image: UIImage! = nil
        if self.isDraggable {
            if self.dragState == MKAnnotationView.DragState.dragging {
                if inAnimated {
                    image = self._animationFrames[self._currentFrame]
                    self._currentFrame += 1
                    if self._currentFrame >= self._animationFrames.count {
                        self._currentFrame = 0
                    }
                }
            } else {
                image = UIImage(named: "BlackMarker", in: nil, compatibleWith: nil)
            }
        } else {
            if 1 < self.locations.count {
                image = UIImage(named: "RedMarker", in: nil, compatibleWith: nil)
            } else {
                image = UIImage(named: "BlueMarker", in: nil, compatibleWith: nil)
            }
        }
        
        return image
    }
    
    /* ################################################################## */
    /**
     Sets up the next timer.
     */
    func startTimer() {
        if #available(iOS 10.0, *) {
            self._animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_: Timer) in
                DispatchQueue.main.async(execute: { self.setNeedsDisplay() })
            })
        }
    }
    
    /* ################################################################## */
    /**
     Stops the timer.
     */
    func stopTimer() {
        if nil != self._animationTimer {
            self._animationTimer.invalidate()
            self._animationTimer = nil
        }
    }
    
    /* ################################################################## */
    // MARK: - Base Class Override Methods -
    /* ################################################################## */
    /**
     Draws the image for the marker.
     
     - parameter rect: The rectangle in which this is to be drawn.
     */
    override func draw(_ rect: CGRect) {
        self.stopTimer()
        let image = self.selectImage(0 < self._animationFrames.count)
        if nil != image {
            image!.draw(in: rect)
        }
        
        if self.dragState == MKAnnotationView.DragState.dragging {
            self.startTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Sets the drag state for this marker.
     
     - parameter newDragState: The new state that should be set after this call.
     - parameter animated: True, if the state change is to be animated (ignored).
     */
    override func setDragState(_ newDragState: MKAnnotationView.DragState, animated: Bool) {
        var subsequentDragState = MKAnnotationView.DragState.none
        switch newDragState {
        case MKAnnotationView.DragState.starting:
            subsequentDragState = MKAnnotationView.DragState.dragging
            self._currentFrame = 0
            
        case MKAnnotationView.DragState.dragging:
            self.startTimer()
            subsequentDragState = MKAnnotationView.DragState.dragging
            
        default:
            self.stopTimer()
            subsequentDragState = MKAnnotationView.DragState.none
        }
        
        super.dragState = subsequentDragState
        self.setNeedsDisplay()
    }
    
    /* ################################################################## */
    // MARK: - NSCoding Protocol Methods -
    /* ################################################################## */
    /**
     This class will restore its meeting object from the coder passed in.
     
     - parameter  aDecoder: The coder that will contain the meeting.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.annotation = aDecoder.decodeObject(forKey: self.sAnnotationObjectKey) as? MapAnnotation
    }
    
    /* ################################################################## */
    /**
     This method saves the locations and coordinates as part of the serialization.
     
     - parameter  aCoder: The coder that contains the coordinates.
     */
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.annotation, forKey: self.sAnnotationObjectKey)
        super.encode(with: aCoder)
    }
}
