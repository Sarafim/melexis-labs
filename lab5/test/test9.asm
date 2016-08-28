# Test 009
#
# Invalid instruction exception test.
#
# Commands tested:
#   addi, add, lui, sw, beq, bne, mfc0, mtc0, eret, j, nop
#
# Expected Behavior:
# If successful, it should write the value 0x00000001 to address 4
#

				j			main							# jump to main code
				nop											# jump delay slot
				j			except						# jump to exception handler
				nop											# jump delay slot
				
										# branch delay slot

except: mfc0  $4, $13           # get the cause register
				add		$5, $0, $4				# $5 = $4 save cause register value 
				
        andi  $4, 0x02          # check invalid instruction exceptions (bit 1)
				beq		$4, $0, illegal_exception
				nop 										# branch delay slot
				
        addi  $3, $3, 1         # $1++
        j     exit       				# jump to exit
        nop 										# branch delay slot
				
illegal_exception:              # do if another exception occurs
				andi  $5, 0x01          # check external interrupt (bit 0)
        bne		$5, $0, exit_int	# if external interrupt occurs, then don't change exception address
				nop 										# branch delay slot
				
exit:		mfc0  $7, $14           # get the exception address
				addi  $7, $7, 4         # choose next intsruction
				mtc0	$7, $14						# change exception address
exit_int:				
        eret                    # Return from exception
main:   addi $3, $0, 0					# initialize $3 = 0 
				
				nop
				nop
				blez $0, end						# Branch on Less Than or Equal to Zero
				nop 										# inalid instruction exception occurs
				nop											# (no such instruction in this MIPS implementation)
				
        sw    $3, 4($0)         # should write 0x00000004 to address 4 (result for tb)
				addi  $1, $0, 1					# initialize $1 = 1
				sw	  $1, 0($0)					# should write 1 to address 0 (finish for tb)
end:   nop	
nop
nop
nop	
