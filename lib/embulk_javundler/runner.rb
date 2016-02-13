module EmbulkJavundler
  class Runner
    def initialize(java_plugins)
      @java_plugins = java_plugins
    end

    def preview(*args)
      Bundler.with_clean_env do
        system("embulk", "preview", *load_paths, *args)
      end
    end

    def run(*args)
      Bundler.with_clean_env do
        system("embulk", "run", *load_paths, *args)
      end
    end

    def guess(*args)
      Bundler.with_clean_env do
        system("embulk", "guess", *load_paths, *args)
      end
    end

    private

    def load_paths
      @java_plugins.flat_map { |plugin| ["-I", plugin.libdir.to_s] }
    end
  end
end
