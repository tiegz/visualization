require 'rubygems'
require 'png'

def graceful_exit
  puts "  *********************************"
  puts "  IP Color Square - by Tieg Zaharia"
  puts "  *********************************"
  puts "  This script will scan your logfile for ip addresses and map them in order (bottom/left to top/right)"
  puts "  to their corresponding pixel values, and save it as a png. For example by default it would"
  puts "  map 192.168.1.1 to RGBA value (192,168,1,1), which would be mapped as a yellowish pixel."
  puts
  puts "Usage: ruby ip_color_square.rb [LOGFILE] [1,2,3,4]"
  puts "  LOGFILE - the file that you want to grab IPv4 Addresses from"
  puts "  A,B,C,D - the mapping between the IPv4 octet values and RGBA, "
  puts "            for example, 4,3,2,1 would render the address '1.2.3.4' as Red=4, Green=3, Blue=2, Alpha=1"
  puts "            (NOTE: default is 1,2,3,4)"
  puts
  puts "  Example: ruby ip_colorsquare.rb access_log 2,1,3,4"
  puts "  Example: ruby ip_colorsquare.rb production.log 4,4,2,4"
  puts
  exit
end

begin
  throw Exception if ARGV[0].nil?
  logfile_name = ARGV[0]
  pngfile_name = "#{logfile_name}.png"
  rgba_map     = (ARGV[1] =~ /^[1234],[1234],[1234],[1234]$/ ? ARGV[1] : "1,2,3,4").split(',').map { |i| i.to_i - 1 }
  puts " => loading logfile"
  logfile      = File.open(logfile_name).read rescue graceful_exit
  puts " => parsing logfile '#{logfile_name}'"
  ip_addrs     = logfile.scan /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
  size         = Math.sqrt(ip_addrs.size).ceil
  puts " => #{ip_addrs.size} ip addresses found"
rescue => e
  puts e
  graceful_exit
end

print " => drawing #{size}x#{size} png with RGBA order #{rgba_map.join(',')}"
canvas = PNG::Canvas.new size, size, PNG::Color::White

ip_addrs.each_with_index do |ip_addr, index|
  x = index < size ? index : (index) % size
  y = (index / size)
  color = ip_addr.split('.').map { |ip| ip.to_i }
  canvas.point(x, y, PNG::Color.new(color[rgba_map[0]], color[rgba_map[1]], color[rgba_map[2]], color[rgba_map[3]]))
end

puts
puts " => saving to #{pngfile_name}"
png = PNG.new canvas
png.save(pngfile_name)
puts " => done!"