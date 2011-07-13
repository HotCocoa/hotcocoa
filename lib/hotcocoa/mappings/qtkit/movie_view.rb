HotCocoa::Mappings.map movie_view: :QTMovieView, framework: :QTKit do

  defaults layout: {}, frame: CGRectZero

  def init_with_options movie_view, options
    movie_view.initWithFrame(options.delete(:frame))
  end

  alias_method :controller_visible=, 'setControllerVisible:'

  custom_methods do
    def controller_buttons= buttons
      setBackButtonVisible(buttons.include?(:back))
      setCustomButtonVisible(buttons.include?(:custom))
      setHotSpotButtonVisible(buttons.include?(:hot_spot))
      setStepButtonsVisible(buttons.include?(:step))
      setTranslateButtonVisible(buttons.include?(:translate))
      setVolumeButtonVisible(buttons.include?(:volume))
      setZoomButtonsVisible(buttons.include?(:zoom))
    end
  end

end
