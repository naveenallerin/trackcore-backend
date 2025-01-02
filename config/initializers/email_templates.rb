module EmailTemplates
  CATEGORIES = [
    'Notification',
    'Marketing',
    'System',
    'Compliance',
    'Customer Service'
  ].freeze
  
  DEPARTMENTS = [
    'Sales',
    'Marketing',
    'Support',
    'Legal',
    'Operations'
  ].freeze
  
  REQUIRED_FOOTER_TEXT = {
    'Marketing' => 'To unsubscribe, click here: {{unsubscribe_link}}',
    'Compliance' => 'This is an official communication from {{company_name}}'
  }.freeze
end
