crumb :makes do |make|
  link "Make File"
  parent :test_case, make.test_case
end

crumb :makes_new do |test_case|
  link "Make File"
  parent :test_case, test_case
end
