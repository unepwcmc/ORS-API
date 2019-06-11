module ApplicationHelper
  def is_ramsar_instance?
    Rails.root.to_s.include?('API')
  end
end
