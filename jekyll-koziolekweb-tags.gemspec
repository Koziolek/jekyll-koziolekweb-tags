# frozen_string_literal: true

require_relative "lib/jekyll/koziolekweb/tags/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-koziolekweb-tags"
  spec.version = Jekyll::Koziolekweb::Tags::VERSION
  spec.authors = ["Koziolek"]
  spec.email = ["bjkuczynski@gmail.com"]

  spec.summary = "Set of structural tags that helps to organise article."
  spec.description = "Here you will find a set of tags that allow you to create code listings with numbering, notes using the <aside> element and more."
  spec.homepage = "https://github.com/Koziolek/jekyll-koziolekweb-tags"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"
  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.metadata["source_code_uri"] = "https://github.com/Koziolek/jekyll-koziolekweb-tags"
  spec.metadata["changelog_uri"] = "https://github.com/Koziolek/jekyll-koziolekweb-tags/CHANGELOG.md"


  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
