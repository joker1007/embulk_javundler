require 'thor'
require 'pathname'
require 'yaml'

require 'embulk_javundler'
require 'embulk_javundler/dsl'
require 'embulk_javundler/runner'

module EmbulkJavundler
  class Cli < Thor
    desc "install", "install embulk java plugins"
    def install
      lookup_embulk_plugin_file

      java_plugins = parse_embulk_file(need_lock: false)
      java_plugins.each do |plugin|
        plugin.fetch
        plugin.build_gem
      end

      write_lock_file(java_plugins) unless EmbulkJavundler.lock_file_path.exist?
    end

    desc "update", "update embulk java plugins"
    def update
      lookup_embulk_plugin_file

      java_plugins = parse_embulk_file(use_lock: false, need_lock: false)
      java_plugins.each do |plugin|
        plugin.update
        plugin.build_gem
      end

      write_lock_file(java_plugins)
    end

    desc "exec", "execute embulk run with installed java plugins"
    def exec(*run_args)
      lookup_embulk_plugin_file

      java_plugins = parse_embulk_file
      Runner.new(java_plugins).run(*run_args)
    end

    desc "preview", "execute embulk preview with installed java plugins"
    def preview(*preview_args)
      lookup_embulk_plugin_file

      java_plugins = parse_embulk_file
      Runner.new(java_plugins).preview(*preview_args)
    end

    desc "guess", "execute embulk guess with installed java plugins"
    def guess(*guess_args)
      lookup_embulk_plugin_file

      java_plugins = parse_embulk_file
      Runner.new(java_plugins).guess(*guess_args)
    end

    private

    def lookup_embulk_plugin_file(dir = Pathname.pwd)
      embulk_file = dir.each_child.find { |path| path.basename.to_s == "Embulkfile" }
      if embulk_file
        EmbulkJavundler.embulk_file_path = embulk_file
        return embulk_file
      end

      raise "Embulkfile is not found" if dir.root?

      lookup_embulk_plugin_file(dir.parent)
    end

    def parse_embulk_file(use_lock: true, need_lock: true)
      exist_lock_file = EmbulkJavundler.lock_file_path.exist?
      raise "Embulkfile.lock is not found" if need_lock && !exist_lock_file

      if exist_lock_file && use_lock
        YAML.load_file(EmbulkJavundler.lock_file_path).map(&JavaPlugin.method(:new))
      else
        Dsl.new.tap { |context| context.instance_eval(File.read(EmbulkJavundler.embulk_file_path)) }.java_plugins
      end
    end

    def write_lock_file(java_plugins)
      YAML.dump(java_plugins.map(&:to_h), File.open(EmbulkJavundler.lock_file_path, "w"))
    end
  end
end
