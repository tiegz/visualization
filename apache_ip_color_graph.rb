require 'rubygems'
require 'png'

def graceful_exit
  puts "  *********************************"
  puts "  IP Apache Color Graph - by Tieg Zaharia"
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
  ip_addrs_by_time = {}
  puts " =_by_time> parsing logfile '#{logfile_name}'"
  logfile.strip.each_line do |line|
    if ip_addr = line.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
      t = line.scan(/\[(.*)\]/).flatten.first
      time = Time.local(t[7..10], t[3..5], t[0..1], t[12..13], t[15..16], t[18..19]).to_i
      ip_addrs_by_time[t] ||= []
      ip_addrs_by_time[t] << ip_addr
    end
  end
  height = ip_addrs_by_time.max_by { |a,b| a.size <=> b.size }[1].size
  width  = ip_addrs_by_time.keys.size
  # puts " => #{ip_addrs.size} ip addresses found"
rescue => e
  puts e
  graceful_exit
end

print " => drawing #{width}x#{height} png with RGBA order #{rgba_map.join(',')}"
canvas = PNG::Canvas.new width, height, PNG::Color::White

x, y = 0, 0
ip_addrs_by_time.sort.each do |time_and_ip_addrs|
  time, ip_addrs = time_and_ip_addrs[0], time_and_ip_addrs[1]
  next if time.empty? || ip_addrs.empty?
  ip_addrs.each do |ip_addr|
    next if ip_addr.empty?
    puts time + "..."
    puts ip_addr.inspect
    color = ip_addr[0].split('.').map { |ip| ip.to_i }
    canvas.point(x, y, PNG::Color.new(color[rgba_map[0]], color[rgba_map[1]], color[rgba_map[2]], color[rgba_map[3]]))
  end
  y = 0
  x += 1
end

puts
puts " => saving to #{pngfile_name}"
png = PNG.new canvas
png.save(pngfile_name)
puts " => done!"