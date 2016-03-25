notification :terminal_notifier
ignore %r{.*/flycheck_.*}

rspec_options = {
  cmd: 'bundle exec rspec',
  title: 'RemoteResource Rspec',
  run_all: {
    cmd: 'COVERAGE=true bundle exec rspec -f progress',
    message: 'To view coverage: open coverage/index.html'
  }
}
guard :rspec, rspec_options do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})          { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { 'spec' }
  watch(%r{^spec/support/(.+)\.rb$}) { 'spec' }
end
