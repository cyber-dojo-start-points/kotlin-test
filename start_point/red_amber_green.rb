
lambda { |stdout,stderr,status|
  output = stdout + stderr
  return :red   if /^Tests:   0 passed, 0 failed, 0 ignored/.match(output)
  return :red   if /^Tests:   (\d+) passed, [1-9][0-9]* failed, (\d+) ignored/.match(output)
  return :green if /^Tests:   (\d+) passed, 0 failed, (\d+) ignored/.match(output)
  return :amber
}
