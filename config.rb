require 'yaml'
require 'fileutils'

module AutoDisplayManager
    class Config
        def initialize(path)
            FileUtils.mkdir_p(path)
            @filepath = "#{path}/config.yml"
            if File.exists?(@filepath)
                @config = YAML.load_file(@filepath)
            end
            @config ||= {}
            @config[:displays] ||= []
        end

        def respond_to?(sym, include_private = false)
            handle?(sym)  || super(sym, include_private)
        end

        def method_missing(sym, *args, &block)
            return @config[sym] if handle?(sym)
            super(sym, *args, &block)
        end

        def set_display(name, string, options)
            name = name.to_sym
            @config[name] ||= {}
            @config[name][:str] = string
            @config[name][:options] = options
            @config[:displays] << name
            @config[:displays].uniq!
        end

        def remove_display(name)
            name = name.to_sym
            @config.delete(:name)
            @config[:displays].reject! {|i| i == name}
        end

        def save
            keys = []
            @config.each_key do |k|
                keys << k
            end
            keys.delete(:displays)
            @config[:displays].each do |d|
                keys.delete(d)
            end
            keys.each do |k|
                @config.delete(k)
            end
            File.open(@filepath, "w") do |f|
                f << YAML.dump(@config)
            end
        end

        def reset
            if File.exists?(@filepath)
                @config = YAML.load_file(@filepath)
            end
            @config ||= {}
            @config[:displays] ||= []
        end

        def display
            puts @config.to_yaml
        end

        private

        def handle?(sym)
            sym == :displays || (@config[:displays].include?(sym) && @config[sym] != nil)
        end
    end
end