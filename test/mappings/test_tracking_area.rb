class TestTrackingAreaMappings < MiniTest::Unit::TestCase

  def test_given_a_name
    tracking_area = HotCocoa.tracking_area(rect: [0,0,10,10],
                                        options: [:mouse_entered_and_exited, :active_in_key_window],
                                          owner: self)
    assert_instance_of(NSTrackingArea, tracking_area)
    assert_equal NSMakeRect(0,0,10,10), tracking_area.rect
    assert_equal self, tracking_area.owner
    assert_equal NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow, tracking_area.options
  end

  def bench_create_tracking_area
    assert_performance_linear do |n|
      n.times { HotCocoa.tracking_area }
    end
  end
end
