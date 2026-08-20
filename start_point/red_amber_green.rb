
lambda { |stdout,stderr,status|
  output = stdout + stderr
  found  = /^\[\s*(\d+) tests? found\s*\]/.match(output)
  failed = /^\[\s*(\d+) tests? failed\s*\]/.match(output)
  # No counts means the tests never ran; no tests means nothing was measured.
  return :amber if found.nil? || failed.nil?
  return :amber if found[1].to_i.zero?
  return :green if failed[1].to_i.zero?
  # A failed assertion is red. Any other exception is an error, so amber.
  thrown = output.scan(/^\s+=> (\S+)/).flatten
  assertions = thrown.all? { |t| t.start_with?('org.opentest4j.AssertionFailedError') }
  return :red if !thrown.empty? && assertions
  return :amber
}
