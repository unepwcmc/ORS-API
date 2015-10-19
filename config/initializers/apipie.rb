Apipie.configure do |config|
  config.app_name = "ORS API"
  config.app_info["v1"] = "Application Programming Interface (API) to support MEA reporting parties in access to data."
  config.api_base_url = "v1"
  config.doc_base_url = "/documentation"
  config.default_version = "v1"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/*.rb"
  config.layout = 'application'
  config.copyright = "&copy; #{Time.now.year} UNEP-WCMC"
end
