# Test 010
#
# External interrupt test.
#
# Commands tested:
#   addi, sw, beq, mfc0, mtc0, eret, j, nop
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
				
        andi  $4, 0x01          # check external interrupt (bit 0)
				beq		$4, $0, illegal_exception
				nop 										# branch delay slot
				
        addi  $3, $3, 1         # $1++
        j     exit_int   				# jump to exit
        nop 										# branch delay slot
				
illegal_exception:              # do if another exception occurs
     		mfc0  $7, $14           # get the exception address
				addi  $7, $7, 4         # choose next intsruction
				mtc0	$7, $14						# change exception address
exit_int:				
        eret                    # Return from exception
main:   addi $3, $0, 0					# initialize $3 = 0 
				addi $2, $0, 20					# initialize $2 = 50 
				addi $8, $0, 0					# initialize $8 = 0 
				
				nop
				nop
				nop
				nop											# during this nops external interrupt will occurs
				nop											# (interrupt makes by test-bench)
				nop
				nop
				nop
				nop
				nop				
				
        sw    $3, 4($0)         # should write 0x00000004 to address 4 (result for tb)
				addi  $1, $0, 1					# initialize $1 = 1
				sw	  $1, 0($0)					# should write 1 to address 0 (finish for tb)
end:   nop	
nop
nop
nop
nop
