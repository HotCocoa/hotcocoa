HotCocoa::Mappings.map tracking_area: NSTrackingArea do
  defaults rect: CGRectZero

  constant :options, {
    mouse_entered_and_exited: NSTrackingMouseEnteredAndExited,
    mouse_moved:              NSTrackingMouseMoved,
    cursor_update:            NSTrackingCursorUpdate,
    active_in_key_window:     NSTrackingActiveInKeyWindow,
    active_first_responder:   NSTrackingActiveWhenFirstResponder,
    active_in_active_app:     NSTrackingActiveInActiveApp,
    active_always:            NSTrackingActiveAlways,
    assume_inside:            NSTrackingAssumeInside,
    in_visible_rectangle:     NSTrackingInVisibleRect,
    enabled_during_drag:      NSTrackingEnabledDuringMouseDrag
  }
  
  def init_with_options tracking_area, options
    rect = options.delete(:rect)
    widget_options = options.delete(:options)
    if widget_options.nil?
      raise ArgumentError.new("Options must be set for NSTrackingArea, in particular the type of tracking area")
    end
    tracking_area.initWithRect rect,
                      options: widget_options,
                        owner: options.delete(:owner),
                     userInfo: nil
  end
end