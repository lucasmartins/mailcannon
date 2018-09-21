module MailCannon
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../templates/config", __dir__)

    def create_config_file
      config_yml = "mailcannon.yml"
      copy_file config_yml, "config/#{config_yml}"
    end
  end
end
