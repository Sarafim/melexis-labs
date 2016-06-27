# Harvey Mudd College VLSI MIPS Project
# Carl Nygaard
# Spring, 2007
#
# Test 002
#
# Created: 12/28/06
#
#   Tests immediate instructions, hazards, negative numbers.  

.set noreorder

main:   addiu $2, $0, -10       # $2 = -10
        addiu $3, $0, 12        # $3 = 10
        addu  $2, $2, $3        # $2 = $2 + $3 = -10 + 10 = 0
        addiu $4, $2, 100       # $4 = $2 + 100 = 0 + 10 = 100
        addiu $5, $2, -100      # $5 = $2 + -100 = -100
        addu  $2, $2, $3        # $2 = $2 + $3 = 0 + 0 = 0
        lui   $4, 0x70f0        # $4 = 0x70f00000
        ori   $4, $4, 0xf000    # $4 = 0x70f00000 | 0x0000f000 = 0x70f0f000
        xori  $4, $4, 0xfff0    # $4 = 0x70f0f000 ^ 0x0000fff0 = 0x70f00ff0
        addu  $2, $2, $3        # $2 = $2 + $3 = 1 + 1 = 2
write:  sw   $2, 0($4)          # should write 2 to address 0x70f00ff0


