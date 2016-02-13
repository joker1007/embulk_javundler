require 'embulk_javundler/java_plugin'

module EmbulkJavundler
  class Dsl
    attr_reader :java_plugins

    def initialize
      @java_plugins = []
    end

    def java_plugin(name, git: nil, github: nil, commit: "master", libdir: nil, classpathdir: nil)
      @java_plugins << JavaPlugin.new(
        name: name,
        install_dir: EmbulkJavundler.install_dir.join(name),
        git: git,
        github: github,
        commit: commit,
        libdir: libdir,
        classpathdir: classpathdir
      )
    end
  end
end
