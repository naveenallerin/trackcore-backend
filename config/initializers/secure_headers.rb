SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      strict: true
    }
  }

  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w(origin-when-cross-origin strict-origin-when-cross-origin)

  config.csp = {
    default_src: %w('none'),
    connect_src: %w('self'),
    script_src: %w('self'),
    img_src: %w('self'),
    style_src: %w('self'),
    base_uri: %w('self'),
    form_action: %w('self'),
    frame_ancestors: %w('none')
  }
end
