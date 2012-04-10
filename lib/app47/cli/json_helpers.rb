require 'json'

# A helper shortcut for printing json strings
# @param [JSON] a parsed json object to display/print
# @return [void]
def print_json(json_obj)
  puts JSON.pretty_generate(json_obj)
end

