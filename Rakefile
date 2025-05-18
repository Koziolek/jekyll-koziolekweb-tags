# frozen_string_literal: true
require "rubygems/tasks"
require "bundler/gem_tasks"
require "rake/testtask"

# Definiowanie zadania testowego
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_*.rb"]
  t.warning = true
end

desc "Stwórz gem, wygeneruj changelog, utwórz tag i wypchnij"
task :myrelease do
  # Sprawdzenie obecności pliku .gemspec
  gemspec_filename = Dir.glob("*.gemspec").first
  abort("Brak pliku .gemspec!") unless gemspec_filename

  # Pobierz dane gemspec (np. wersję)
  gemspec = Gem::Specification.load(gemspec_filename)
  gem_name = gemspec.name
  gem_version = gemspec.version.to_s

  # 1. Wygeneruj gem
  Rake::Task[:build_gem].invoke

  # 2. Wygeneruj changelog
  Rake::Task[:generate_changelog].invoke

  # 3. Utwórz tag gita
  Rake::Task[:create_git_tag].invoke

  # 4. Wypchnij tag na zdalny repozytorium
  Rake::Task[:push_git_tag].invoke

  # 5. Wypchnij gem na RubyGems
  Rake::Task[:push_gem].invoke

  # 6. Zwiększ wersję w pliku VERSION
  Rake::Task[:bump_version].invoke

  puts "Wersja #{gem_name} #{gem_version} została zbudowana i wydana!"
end

desc "Zbuduj gem"
task :build_gem do
  puts "Tworzenie gema..."
  sh "gem build #{Dir.glob("*.gemspec").first}"
end

desc "Wygeneruj changelog z git log"
task :generate_changelog do
  puts "Generowanie changelog..."
  changelog_content = `git log --pretty=format:"- %h [%ad] %s (%an)" --date=short`
  File.open("CHANGELOG.md", "a") do |file|
    file.puts "\n## #{Time.now.strftime('%Y-%m-%d')}\n"
    file.puts changelog_content
  end
  puts "Changelog został uaktualniony."
end

desc "Utwórz tag gita z odpowiednią wersją"
task :create_git_tag do
  gemspec_filename = Dir.glob("*.gemspec").first
  gemspec = Gem::Specification.load(gemspec_filename)
  version = gemspec.version.to_s

  sh "git tag -a v#{version} -m 'Release v#{version}'"
  puts "Utworzono tag v#{version}."
end

desc "Wypchnij tag na zdalny repozytorium"
task :push_git_tag do
  sh "git push origin --tags"
  puts "Tagi zostały wypchnięte."
end

desc "Wypchnij gem na RubyGems"
task :push_gem do
  gem_file = Dir.glob("*.gem").last
  abort("Brak pliku gema!") unless gem_file

  sh "gem push #{gem_file}"
  puts "#{gem_file} został wypchnięty na RubyGems."
end

desc "Zwiększ wersję w pliku VERSION"
task :bump_version do
  version_file = "VERSION"
  abort("Brak pliku VERSION!") unless File.exist?(version_file)

  current_version = File.read(version_file).strip
  major, minor, patch = current_version.split(".").map(&:to_i)
  new_version = "#{major}.#{minor}.#{patch + 1}"

  # Zapisz nową wersję do pliku
  File.open(version_file, "w") { |file| file.puts new_version }

  puts "Wersja została podniesiona do: #{new_version}"

  # Dodaj zmiany do gita
  sh "git add #{version_file}"
  sh "git commit -m 'Podniesiono wersję do #{new_version}'"
end

# Domyślne zadanie: uruchom testy
task default: :test

