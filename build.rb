require "fileutils"

FileUtils.rm_rf "dist"
FileUtils.cp_r "src/.", "dist"
