Dir.glob('spec/**/*.rb').each do |file|
  require_relative file.sub(/\.rb$/, '')
end
