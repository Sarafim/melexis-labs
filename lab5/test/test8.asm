# Test 008
#
# Overflow exception test.
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


				

except: mfc0  $4, $13           # get the cause register
				add		$5, $0, $4				# $5 = $4 save cause register value 
				
        andi  $4, 0x04          # check overflow (bit 2)
				beq		$4, $0, illegal_exception
				nop 										# branch delay slot
				
        addi  $1, $1, 1         # $1++
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
				
main:   addi	$1, $0, 0					# initialize $1 = 0 
				lui   $2, 0x8000        # $2 = 0x80000000 (largest negative number)
        lui   $3, 0x8000        # $3 = 0x80000000 (largest negative number)
        add   $2, $2, $3        # $2 = $2 + $3 = 0 (cause overflow exception)
                                # (jump to exception code)
        sw    $1, 4($0)         # should write 1 to address 0x4 (result for tb)
				addi  $1, $0, 1					# initialize $1 = 1
				sw	  $1, 0($0)					# should write 1 to address 0 (finish for tb)
        nop
        nop
        nop
        nop
