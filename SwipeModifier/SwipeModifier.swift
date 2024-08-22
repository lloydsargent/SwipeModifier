///
/// @file       SwipeModifier
///
/// @brief      SwipeModifier is designed to <#Description#>
///
/// @discussion <#Discussion#>
///
/// Written by Lloyd Sargent
///
/// Created May 11, 2024
///
/// Copyright © 2024 Canna Software LLC. All rights reserved.
///
/// Licensed under MIT license.
///

import SwiftUI

extension View {
    ///
    ///    View modifier to handle mouse swipes.
    ///
    ///    This view modifier is designed to handle mouse swipes for macOS.
    ///    Assume that `yourView` is the view you want to detect swipes on.
    ///
    ///        yourView
    ///            .onSwipe{ event in
    ///                    switch event.direction {
    ///                        case .down:
    ///                            print("### down")
    ///                        case .up:
    ///                            print("### up")
    ///                        case .left:
    ///                            print("### left")
    ///                        case .right:
    ///                            print("### right")
    ///                        default:
    ///                            print("### everythingelse")
    ///                    }
    ///            }
    ///
    ///    Note that modifiers are also passed into the event. This allows swipes using
    ///
    ///       ⌃ - control key
    ///
    ///       ⌥ - option key
    ///
    ///       ⌘ - command key
    ///
    ///
    ///    - Parameters:
    ///        - action: closure to call with the SwipeEvent as the parameter
    ///        - returns: ContentView (some View)
    ///    #### ⚠️ Warning
    ///    Has not been throughly tested with other modifiers..
    ///    #### 🚫 Do Not Use
    ///    Will not work with iOS. This is a macOS solution. Use gestures with iOS.
    ///

    func onSwipe(perform action: @escaping (SwipeEvent) -> Void) -> some View {
        modifier(OnSwipe(action: action))
    }
}



///
///    Class containing information for when the user swipes on the magic mouse.
///
///    This contains more than enough variables to suit you.
///
///    >Note NSEvent is not used as it does not have enough information. Since it is more important to
///    know things like directionp.
///

class SwipeEvent {
    enum SwipeDirection {
        case none, up, down, left, right
    }
    
    enum Modifier {
        case none, shift, control, option, command
    }
    
    var direction: SwipeDirection = .none
    var directionValue: CGFloat = .zero
    var phase: NSEvent.Phase = .mayBegin
    var modifier: Modifier = .none

    var deltaX: CGFloat = .zero
    var deltaY: CGFloat = .zero
    var location: CGPoint = .zero
    var timestamp: TimeInterval = .nan
    var mouseLocation: CGPoint = .zero
    var scrollingDeltaX: CGFloat = .zero
    var scrollingDeltaY: CGFloat = .zero
    var modifierFlags: NSEvent.ModifierFlags = .shift
}



///
///    A ViewModifier for detecting swipe events.
///
///    The view modifier creates uses hover to determine if the event occurs in the view.
///
///    - Parameters:
///        - : action contains the closure
///
///    - returns: <#ReturnDescription#>
///    #### ❕Attention
///    This uses the `.onContinousHover` modifier to determine if we are in the view.
///    #### ⚠️ Warning
///    Do not remove the `.onDisappear` or you will leak memory.
///

struct OnSwipe: ViewModifier {
    //----- our action closure
    var action: (SwipeEvent) -> Void
    
    //----- are we inside the view?
    @State private var insideViewWindow = false
    
    //----- swipe event
    @State private var swipeEvent = SwipeEvent()
    
    //----- secret sauce to prevent memory leaks DO NOT REMOVE
    @State private var monitor: Any? = nil
    
    func body(content: Content) -> some View {
        return content
            //----- see if we are in the view
            .onContinuousHover { phase in
                switch phase {
                case .active:
                    insideViewWindow = true
                    
                case .ended:
                    insideViewWindow = false
                }
            }
        
            //----- view appear, add the monitor for scrollWheel events
            .onAppear {
                monitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { event in
                    
                    if insideViewWindow {
                        let scrollEvent = swipeDirection(event)
                        action(scrollEvent)
                    }
                    
                    return event
                }
            }
        
            //----- onDisappear, remove the monitor to prevent memory leaks.
            .onDisappear {
                NSEvent.removeMonitor(monitor!)
            }
    }
}



///
///    Used to determine swipe direction.
///
///    This copies information from the NSEvent to the SwipeEvent class instance.
///
///    - Parameters:
///        - nsevent: the event (NSEvent)
///
///    - returns: Infomation regarding the swipe event (SwipeEvent)
///

func swipeDirection(_ nsevent: NSEvent) -> SwipeEvent {
    let swipeEvent = SwipeEvent()
    
    if nsevent.scrollingDeltaX > 0.0 {
        swipeEvent.direction = .left
        swipeEvent.directionValue = abs(nsevent.scrollingDeltaX)
    }
    if nsevent.scrollingDeltaX < 0.0 {
        swipeEvent.direction = .right
        swipeEvent.directionValue = abs(nsevent.scrollingDeltaX)
    }
    if nsevent.scrollingDeltaY > 0.0 {
        swipeEvent.direction = .up
        swipeEvent.directionValue = abs(nsevent.scrollingDeltaY)
    }
    if nsevent.scrollingDeltaY < 0.0 {
        swipeEvent.direction = .down
        swipeEvent.directionValue = abs(nsevent.scrollingDeltaY)
    }
    
    switch nsevent.modifierFlags {
        case let modifier where modifier.contains(.shift):
            swipeEvent.modifier = .shift
        case let modifier where modifier.contains(.control):
            swipeEvent.modifier = .control
        case let modifier where modifier.contains(.option):
            swipeEvent.modifier = .option
        case let modifier where modifier.contains(.command):
            swipeEvent.modifier = .command
        default:
            swipeEvent.modifier = .none
    }
    
    //----- copy the nsevent data
    swipeEvent.scrollingDeltaX = nsevent.scrollingDeltaX
    swipeEvent.scrollingDeltaY = nsevent.scrollingDeltaY
    swipeEvent.phase = nsevent.phase
    swipeEvent.deltaX = nsevent.deltaX
    swipeEvent.deltaY = nsevent.deltaY
    swipeEvent.scrollingDeltaX = nsevent.scrollingDeltaX
    swipeEvent.scrollingDeltaY = nsevent.scrollingDeltaY
    swipeEvent.location = nsevent.locationInWindow
    swipeEvent.mouseLocation = nsevent.locationInWindow
    swipeEvent.location = nsevent.cgEvent!.location
    swipeEvent.timestamp = nsevent.timestamp

    return swipeEvent
}


