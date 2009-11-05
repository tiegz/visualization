require 'rubygems'
require 'png'

def graceful_exit
  puts "Usage: coloraddress.rb [LOGFILE]"
  exit
end


# read logfile
begin
  logfile_name = ARGV[0]
  puts " => loading logfile"
  logfile      = File.open(logfile_name).read rescue graceful_exit
  puts " => parsing logfile '#{logfile_name}'"
  ip_addrs     = logfile.scan /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
  size         = Math.sqrt(ip_addrs.size).ceil
  puts " => #{ip_addrs.size} ip addresses found"
rescue => e
  graceful_exit
end

print " => drawing #{size}x#{size} png"
@canvas1 = PNG::Canvas.new size, size, PNG::Color::White
@canvas2 = PNG::Canvas.new size, size, PNG::Color::White
@canvas3 = PNG::Canvas.new size, size, PNG::Color::White
@canvas4 = PNG::Canvas.new size, size, PNG::Color::White

ip_addrs.each_with_index do |ip_addr, index|
  x = index < size ? index : (index) % size
  y = (index / size)
  color = ip_addr.split('.').map { |ip| ip.to_i }
  @canvas1.point(x, y, PNG::Color.new(color[0], color[1], color[2], color[3]))
  @canvas2.point(x, y, PNG::Color.new(color[1], color[2], color[3], color[0]))
  @canvas3.point(x, y, PNG::Color.new(color[2], color[3], color[1], color[0]))
  @canvas4.point(x, y, PNG::Color.new(color[3], color[0], color[1], color[2]))
end
puts
puts " => saving to z.png"
@png1 = PNG.new @canvas1
@png2 = PNG.new @canvas2
@png3 = PNG.new @canvas3
@png4 = PNG.new @canvas4
@png1.save('z1.png')
@png2.save('z2.png')
@png3.save('z3.png')
@png4.save('z4.png')
