Gem::Specification.new do |s|
  s.name = "RightAPI"
  s.version = "0.4.16"
  s.date = "2013-01-16"
  s.authors = ["Robert Carr"]
  s.email = "robert@rightscale.com"
  s.summary = "Ruby wrapper around rightscales rest interface"
  s.homepage = "https://github.com/cheempz/RightAPI"
  s.files = ["lib/RightAPI.rb"]
  s.has_rdoc = false
  s.add_runtime_dependency "rest-client"
  s.description = "A generic API wrapper to interface with the RightScale Cloud Computing API."
end
