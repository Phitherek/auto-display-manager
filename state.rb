require 'yaml'
require 'fileutils'

module AutoDisplayManager
    class State
         def initialize(path, destroy_old = true)
            FileUtils.mkdir_p(path)
            @filepath = "#{path}/state.yml"
            if File.exists?(@filepath) && destroy_old
                FileUtils.rm(@filepath)
            end
            @state = {}
        end

        def self.load_from(path)
            s = State.new(path, false)
            s.reset
            s
        end

        def respond_to?(sym, include_private = false)
            handle?(sym)  || super(sym, include_private)
        end

        def method_missing(sym, *args, &block)
            return @state[sym] if handle?(sym)
            super(sym, *args, &block)
        end

        def set(name, state)
            name = name.to_sym
            state = state.to_sym
            unless [:connected, :disconnected].include?(state)
                state = :disconnected
            end
            @state[name] = state
        end

        def run
            @state[:process] = :running
        end

        def pause
            @state[:process] = :paused
        end

        def kill
            FileUtils.rm(@filepath)
        end

        def save
            @state[:last_update] = Time.now
            File.open(@filepath, "w") do |f|
                f << YAML.dump(@state)
            end
        end

        def reset
            if File.exists?(@filepath)
                @state = YAML.load_file(@filepath)
            end
            @state ||= {}
        end

        private

        def handle?(sym)
            @state[sym] != nil
        end
    end
end