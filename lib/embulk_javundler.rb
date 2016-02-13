require "embulk_javundler/version"

module EmbulkJavundler
  class << self
    def embulk_file_path
      @embulk_file_path
    end

    def embulk_file_path=(embulk_file_path)
      @embulk_file_path = embulk_file_path.absolute? ? embulk_file_path : embulk_file_path.expand_path
    end

    def root
      embulk_file_path.dirname
    end

    def install_dir
      root.join("plugins", "java")
    end

    def lock_file_path
      root.join("Embulkfile.lock")
    end
  end
end
