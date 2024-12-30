class DashboardLayoutService
  Result = Struct.new(:success?, :error)
  
  def initialize(user)
    @user = user
  end

  def update_layout(widget_positions)
    widget_ids = widget_positions.map { |wp| wp[:id] }
    widgets = Widget.where(id: widget_ids)
    
    return Result.new(false, 'Some widgets are not available for your role') unless widgets_available?(widgets)
    
    @user.update!(
      dashboard_layout: widget_positions.each_with_index.map do |wp, index|
        { id: wp[:id], position: wp[:position] || index }
      end
    )
    
    Result.new(true, nil)
  end

  def default_layout
    widgets = Widget.where(role_restricted: false)
    widgets.map.with_index { |w, i| { id: w.id, position: i } }
  end

  private

  def widgets_available?(widgets)
    widgets.all? { |widget| widget.available_for?(@user) }
  end
end
