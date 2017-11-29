require "json"

module Breadbin
  class PaletteConfig

    alias Config = Hash(String, Array(Int32))
    class ConfigNotFound < Exception; end
    @@config : Config?

    def self.config() : Config
      @@config ||= load_config
    end
    
    private def self.load_config() : Config
      palettes = JSON.parse(File.read(config_file))
      palettes.each_with_object(Config.new) do |palette, config|
        key = palette["name"].as_s
        val = palette["spec"].as_s.split(',').map { |c| c.to_i(16) }
        config[key] = val
      end
    end

    private def self.config_file() : String
      path = ENV.fetch("BREADBIN_CONFIG_PATH", "~/.config/breadbin")
      File.expand_path(File.join path, "palettes.json").tap do |path|
        raise ConfigNotFound.new(path) unless File.exists?(path)
      end
    end
  end
end
