# -*- encoding: utf-8 -*-
# stub: middleman-inline_svg 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "middleman-inline_svg".freeze
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Barber".freeze, "Tyson Gach".freeze]
  s.date = "2018-04-30"
  s.description = "Inline your SVG's and style them with CSS.".freeze
  s.email = ["github@danbarber.me".freeze, "tyson@thoughtbot.com".freeze]
  s.homepage = "https://github.com/thoughtbot/middleman-inline_svg".freeze
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Inline your SVG's".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<middleman-core>.freeze, [">= 3.4.1"])
  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.8"])
end
