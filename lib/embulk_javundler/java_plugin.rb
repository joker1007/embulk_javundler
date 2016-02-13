require 'open3'

module EmbulkJavundler
  class JavaPlugin
    class GitError < StandardError; end
    class BuildFailure < StandardError; end

    attr_reader :name, :install_dir, :git, :github, :repo, :commit, :sha1, :libdir, :classpathdir

    def initialize(name:, install_dir:, git: nil, github: nil, commit: "master", libdir: nil, classpathdir: nil)
      @name = name
      @install_dir = install_dir
      @git = git
      @github = github
      @repo = if git
                git
              elsif github
                "https://github.com/#{github}.git"
              else
                raise ArgumentError, "Need git or github param"
              end
      @commit = commit
      @libdir = libdir ? install_dir.join(libdir) : install_dir.join("lib")
      @classpathdir = classpathdir ? install_dir.join(classpathdir) : install_dir.join("classpath")
    end

    def to_h
      {
        name: name,
        install_dir: install_dir,
        git: git,
        github: github,
        commit: sha1 || commit,
        libdir: libdir,
        classpathdir: classpathdir,
      }
    end

    def fetch
      if cloned?
        puts "Using #{name}"
      else
        print "Fetch #{name} from #{repo} ... "
        log, result_status = Open3.capture2e("git", "clone", repo, install_dir.to_s)
        unless result_status.success?
          puts log
          raise GitError
        end
        print "OK\n"
      end

      checkout
    end

    def checkout
      log, result_status = Open3.capture2e("git", "checkout", commit, chdir: install_dir.to_s)
      unless result_status.success?
        puts log
        raise GitError
      end

      sha1 = IO.popen(["git", "rev-parse", "HEAD", {chdir: install_dir.to_s}]) do |io|
        io.read.chomp
      end
      @sha1 = sha1
    end

    def update
      return fetch unless cloned?

      print "Update #{name} from #{repo} ... "
      log, result_status = Open3.capture2e("git", "pull", "origin", "--all", "--ff-only", chdir: install_dir.to_s)
      unless result_status.success?
        puts log
        raise GitError
      end
      print "OK\n"

      checkout
    end

    def build_gem
      Bundler.with_clean_env do
        puts "Build #{name}"
        log, result_status = Open3.capture2e("./gradlew", "gem", chdir: install_dir.to_s)
        puts log
        unless result_status.success?
          raise BuildFailure
        end
      end
    end

    private

    def cloned?
      if install_dir.directory?
        log, result_status = Open3.capture2e("git", "remote", "-v", chdir: install_dir.to_s)
        if result_status.success? && log =~ /origin\s+#{Regexp.escape(repo)}/
          return true
        end
      end

      false
    end
  end
end
