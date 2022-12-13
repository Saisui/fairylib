require 'base64'

def unicode i
	eval('"\u'+("%04x" % i)+'"')
end

def to7bin a # String -> String
	if a.is_a?(String)
		"%07b" % a.bytes[0]
	else # 整数！
		"%07b" % a
	end
end

def twotobase16384 a,b
	unicode(0x4e00 +
		(to7bin(a) + to7bin(b)).to_i(2))
end

def encodebase16384 s
	s << "\x00" if s.size.odd?
	a=[]
	s.bytes.each_with_index do |v,i|
		if i.even?
			a << [v]
		else
			a.last << v
		end
	end
	a	.map{|a| twotobase16384(a[0],a[1])}
		.join
end

def decodeb a
	a=a.bytes.map!{|a|a.to_s(2)}	# 转成 1110xxxx 10xxxxxx 10xxxxxx 的形式
	a=(a[0][4..]+a[1][2..]+a[2][2..]).to_i(2) # 取出 xxxx 的部分，变成 0bxxxx_xxxx_xxxx_xxxx
	a=a-0x4e00 # 减去4e00 变为 14位数二进制
	a=["%08b" % a[0..6],"%08b" % a[7..]]  # 还原
	(a[0].to_i(2).chr + a[1].to_i(2).chr).reverse
end

def decodebase16384 s
	s.split('').map{ |b|
		decodeb b
	}.join
end

def encode64_16384 s
	encodebase16384 Base64.encode64 s
end
def decode16384_64 s
	Base64.decode64 decodebase16384 s
end