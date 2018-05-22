# coding: utf-8
require_relative './lib/class_generator.rb'
require 'json'
require 'fileutils'
require 'set'

class String
  def to_camel
    self.split(/_/).map(&:capitalize).join
    # or
    #self.split(/_/).map{ |w| w[0] = w[0].upcase; w }.join
  end

  def to_snake
    self.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase
  end
end

# main関数
def main
  file_name = "api_guildbattle_instant_card_entry"
  class_name = file_name.to_camel
  generator = ClassGenerator.new(class_name, file_name)
  code = generator.get_header_class_code
  write_code('/Users/a13916/applibot/joker-client/chaos-ios/chaos/Classes/network/guild_battle/instant_card/' + file_name + '.h', code);

  code = generator.get_implement_class_code
  write_code('/Users/a13916/applibot/joker-client/chaos-ios/chaos/Classes/network/guild_battle/instant_card/' + file_name + '.cpp', code);
end

def write_code(file_path, code)
  FileUtils.mkdir_p(File.dirname(file_path))
  # path_str = file_path["/Users/a13916/ruby/generate_api/".length+1..-1]
  if File.exist?(file_path)
    if code != File.open(file_path, "r:bom|utf-8").read
        puts "update #{file_path}"
    end
  else
    puts "create #{file_path}"
  end
  bom = "   "
  bom.setbyte(0,0xEF)
  bom.setbyte(1,0xBB)
  bom.setbyte(2,0xBF)
  code = bom + code
  File.open(file_path, "w") {|f| f.write(code)}
end

main
