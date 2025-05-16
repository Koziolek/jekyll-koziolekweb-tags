# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

# Definiowanie zadania testowego
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_*.rb"]
  t.warning = true
end

# Domyślne zadanie: uruchom testy
task default: :test

