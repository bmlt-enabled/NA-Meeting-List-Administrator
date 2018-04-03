//  MapMarker.swift
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
    let sCoordinateObjectKey: String = "MapAnnotation_Coordinate"
    let sMeetingsObjectKey: String = "MapAnnotation_Meetings"

    @objc var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
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
    let sAnnotationObjectKey: String = "MapMarker_Annotation"
    let sRegularAnnotationOffsetUp: CGFloat     = 0; /**< This is how many display units to shift the annotation view up. */
    let sRegularAnnotationOffsetRight: CGFloat  = 0;  /**< This is how many display units to shift the annotation view right. */

    /* ################################################################## */
    // MARK: - Private Properties -
    /* ################################################################## */
    private var _currentFrame: Int = 0
    private var _animationTimer: Timer! = nil
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
            if self.dragState == MKAnnotationViewDragState.dragging {
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
        
        if self.dragState == MKAnnotationViewDragState.dragging {
            self.startTimer()
        }
    }
    
    /* ################################################################## */
    /**
     Sets the drag state for this marker.
     
     - parameter newDragState: The new state that should be set after this call.
     - parameter animated: True, if the state change is to be animated (ignored).
     */
    override func setDragState(_ newDragState: MKAnnotationViewDragState, animated: Bool) {
        var subsequentDragState = MKAnnotationViewDragState.none
        switch newDragState {
        case MKAnnotationViewDragState.starting:
            subsequentDragState = MKAnnotationViewDragState.dragging
            self._currentFrame = 0
            
        case MKAnnotationViewDragState.dragging:
            self.startTimer()
            subsequentDragState = MKAnnotationViewDragState.dragging
            
        default:
            self.stopTimer()
            subsequentDragState = MKAnnotationViewDragState.none
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
