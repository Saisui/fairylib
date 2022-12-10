class Integer
    def sbin8 = self.sbin 8
    def shex2 = self.shex 2
    def shex sz=1
        size=self.to_s(16).size
        sz = size + size % sz
        "%0#{sz}x" % self
    end
    def sbin sz=1, separation=0, sep_char='_'
        size=self.to_s(2).size
        sz = size + size % sz
        "%0#{sz}b" % self
    end
    def radix rx=10, sz=1, sepsz=0, sep_char='_', fill=0
        __ = self
        __ = __.to_s(rx)
        size = __.size
        __ = fill.to_s * ((sz - size % sz) % sz) + __
        __ = __.reverse.split('').each_with_index.to_a.map{|a| 
            (sepsz == 0) ? a[0] :
             (a[1] % sepsz == 0) ? sep_char + a[0] : a[0]}
        .join('').reverse
        sepsz == 0 ? __ : __[0..-(1+sep_char.size)]
    end

    def sep_per num=3,sepchr="_",radix=10, x: radix
        self.to_s(x).reverse.sep_per(3,sepchr).reverse
    end

end
class Symbol

end

class String
    def to_a
        self.split('')
    end
    def sep_per num, sepchr = " "
        self.split('').grp_per(num).map{|a|a.join('')}.join(sepchr)
    end
    def grp_per num
        self.split('').grp_per(num).map{|a|a.join}
    end
    def grp_chr_per num
        self.split('').grp_per(num)
    end
    def multi_sep xs,ys
    end

    def mulgrp_per nums,sepS=[" "], xs: nums, seps: sepS
        arr = self.split('').mulgrp_per *xs
        seps+=[" "]*(xs.size-seps.size)
        def inn elms, sp
            if elms.all?(String)
                elms.join(sp)
            elsif elms.all?(Array)
                elms.map{|a| inn(a, sp)}
            end
        end
        ret=arr
        (["",*seps]).each{|sp| ret=inn(ret,sp)}
        ret
    end

    # puts 1145141919816.to_s(2).*(4).mulgrp_per_rvrv([4,2,2,2,2],["_","-","::","  ","\n"])                                                          01000110_11111100"
    # => 1000  0101_0100-1111_1110::0011_1000-0000_0010
    #    0100_0100-0010_1010::0111_1111-0001_1100  0000_0001-0010_0010::0001_0101-0011_1111
    #    1000_1110-0000_0000::1001_0001-0000_1010  1001_1111-1100_0111::0000_0000-0100_1000
    def mulgrp_per_rvrv *a,**b
        self.reverse.mulgrp_per(*a,**b).reverse
    end
end

class Array
    def dimensions
        $dims = []
        def inn __, dim
            if __.is_a? Array
                $dims << dim+1
                __.each do |a|
                    inn(a,dim+1)
                end
            else
                $dims << dim
            end
        end
        inn(self,0)
        $dims
    end
    def dimension
        $dim=0
        $dimension_flag = false
        def inn a, dim
            unless $dimension_flag
                if a.is_a?(Array) and not a.empty?
                    if a.all?(Array)
                        a.each{|e| inn(e,dim+1)}
                    else
                        $dimension_flag = true
                        $dim=dim
                    end
                else
                    $dimension_flag = true
                    $dim=dim
                end
            end
        end
        inn self,$dim
        $dim
    end
    def depth
        self.dimensions.max
    end
    def grp_per num
        self.each_with_index.to_a
            .group_by{|v,k| k/num}.to_a
            .map{|a| a[1]}.map{|a| a.map{|a| a[0]}}
    end
    def mulgrp_per *nums
        ret = self
        nums.each{|n| ret = ret.grp_per(n)}
        ret
    end
    def deep2s *seps
        seps+=[" "]*(self.depth-seps.size-1)
        def inn elms, sp

            if elms.is_a?(Array)
                if elms.all?(String)
                    elms.join(sp)
                elsif elms.all?(Array)
                    elms.map{|a| inn(a, sp)}
                end
            else 
                elms
            end
        end
        ret=self
        (["",*seps]).each{|sp| ret=inn(ret,sp)}
        ret
    end
    def most
        self.counts.max
    end
    def least
        self.counts.min
    end
    def counts
        uniq = self.uniq
        uniq.map{|__| self.count __}
    end
    def e_count
        self.uniq.zip(self.counts)
    end
end

class Array
    alias each_vk each_with_index
end


class StackFn
    def initialize fn
        @fn = fn
    end
end
class StackVal
    def initialize val
        @val = val
    end
end
class AlterStack
    def initialize
        stack = []
    end
    def << val
    end
    def spell code
        
    end
end


###    数字代表值，希腊数英文 代表 相应参数数量函数
###    1 mono 2 du   #=> du(mono(1),2)
###    5 4 3 2 1 mono du tri qua    #=> qua(5,4,tri(4,3,du(2,mono(1))), ...1)
###    1 2 3 4 5 mono> 2 tri        #=> 1, 2, 3, (tri(4, 5, mono(2))
###    1 2 3 4 5 :mono              #=> 1,2,3,5.mono(4)
###    1 2 3 4 5 <tri               #=> 4,5,tri(1,2,3)
###    1 2 3 4 5 ^~tri              #=> 4,5,tri(3,2,1)
###    1 2 3 4 5 ~tri               #=> 1,2,tri(5,4,3)
###    1 2 3 4 5 tri>~ 6 7 8 9      #=> 1,2,tri(8,7,6)
###    1 2 3 4 5 tri^~ 6 7 8 9      #=> 1,2,tri(9,8,7)