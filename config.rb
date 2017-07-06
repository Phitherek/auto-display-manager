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
            @config[:profiles] ||= []
        end

        def respond_to?(sym, include_private = false)
            handle?(sym) || handle_str?(sym) || super(sym, include_private)
        end

        def method_missing(sym, *args, &block)
            return @config[sym] if handle?(sym)
            return @config[sym.to_s] if handle_str?(sym)
            super(sym, *args, &block)
        end

        def set_display(profile, name, string, options)
            profile ||= 'default'
            @config[profile] ||= {}
            name = name.to_sym
            @config[profile][name] ||= {}
            @config[profile][name][:str] = string
            @config[profile][name][:options] = options
            @config[:displays] << name
            @config[:displays].uniq!
            @config[:profiles] << profile
            @config[:profiles].uniq!
        end

        def switch_profile(profile)
            profile ||= 'default'
            @config[:selected_profile] = profile if @config[:profiles].include?(profile)
        end

        def next_profile!
            sorted_profiles = @config[:profiles].sort
            current_idx = sorted_profiles.find_index(@config[:selected_profile])
            current_idx ||= -1
            current_idx = current_idx + 1
            current_idx = 0 if current_idx >= sorted_profiles.count
            @config[:selected_profile] = sorted_profiles[current_idx]
        end

        def remove_profile(profile)
            if @config[:profiles].include?(profile)
                @config.delete(profile)
                @config[:profiles].delete(profile)
            end
            @config[:displays] = []
            @config[:profiles].each do |profile|
                @config[profile].each_key do |k|
                    @config[:displays] << k
                end
            end
            @config[:displays].uniq!
        end

        def remove_display(profile, name)
            profile ||= 'default'
            name = name.to_sym
            @config[profile].delete(name)
            @config[:displays] = []
            @config[:profiles].each do |profile|
                @config[profile].each_key do |k|
                    @config[:displays] << k
                end
            end
            @config[:displays].uniq!
        end

        def save
            keys = []
            @config.each_key do |k|
                keys << k
            end
            keys.delete(:displays)
            keys.delete(:profiles)
            keys.delete(:selected_profile)
            @config[:displays].each do |d|
                keys.delete(d)
            end
            @config[:profiles].each do |p|
                keys.delete(p)
            end
            keys.each do |k|
                @config.delete(k)
                @config[:profiles].each do |p|
                    @config[p].delete(k)
                end
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
            @config[:profiles] ||= []
            @config[:displays] = []
            @config[:profiles].each do |profile|
                @config[profile].each_key do |k|
                    @config[:displays] << k
                end
            end
            @config[:displays].uniq!
        end

        def display(profile)
            if profile != nil && profile != ''
                puts @config[profile].to_yaml
            else
                puts @config.to_yaml
            end
        end

        private

        def handle?(sym)
            sym == :displays || sym == :profiles || sym == :selected_profile || (@config[:profiles].include?(sym) && @config[sym] != nil)
        end
      
        def handle_str?(sym)
            str = sym.to_s
            str == 'displays' || str == 'profiles' || str == 'selected_profile' || (@config[:profiles].include?(str) && @config[str] != nil)
        end
    end
end