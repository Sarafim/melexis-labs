# Test 011
#
# Tests overflow limits.
#
# Commands tested:
#   add, addi, addu, sub, subu, lui, sw, beq, mfc0, mtc0, eret, j, nop
#
# Expected Behavior:
# If successful, it should write the value 0x00000006 to address 4
#

				j			main							# jump to main code
				nop											# jump delay slot
				j			except						# jump to exception handler
				nop											# jump delay slot
				


except: mfc0  $8, $13           # get the cause register
				add		$7, $0, $8 	 		  # $7 = $8 save cause register value 
				
        andi  $8, 0x04          # check overflow (bit 2)
				beq		$8, $0, illegal_exception
				nop 										# branch delay slot
				
        addi  $5, $5, 1         # $3++
        j     exit       				# jump to exit
        nop 										# branch delay slot
				
illegal_exception:              # do if another exception occurs
				andi  $7, 0x01          # check external interrupt (bit 0)
        bne		$7, $0, exit_int	# if external interrupt occurs, then don't change exception address
				nop 										# branch delay slot
				
exit:		mfc0  $7, $14           # get the exception address
				addi  $7, $7, 4         # choose next intsruction
				mtc0	$7, $14						# change exception address
exit_int:				
        eret                    # Return from exception


main:   addi  $5, $0, 0					# start overflow count at 0
				lui   $2, 0x8000        # $2 = 0x80000000 (largest negative number)
        addi  $3, $0, -1        # $3 = -1 = 0xffffffff
				lui   $1, 0x7FFF				# (setting up operands)
				addi  $1, $1, 0x7FFF		# 
				addi  $1, $1, 0x7FFF		# 
				addi  $1, $1, 1					# $1 = 0x7FFFFFFF (largest positive number)
				addi  $9, $0, 1			 		# $9 = 1
				# done setting up operands 

				# test addi
        addi  $4, $2, -1        # $4 = 0x80000000 - 1 (cause overflow exception)
                                # exceptions = 1
				addi  $4, $1, 1         # $4 = 0x7FFFFFFF + 1 (cause overflow exception)
                                # exceptions = 2
				addi  $4, $3, 1	  			# $4 = -1 + 1 = 0 (ok)

				# test add
				add   $4, $2, $3				# $4 = 0x80000000 - 1 (cause overflow exception)
                                # exceptions = 3
				add   $4, $1, $9				# $4 = 0x7FFFFFFF + 1 (cause overflow exception)
  				# exceptions = 4
				add   $4, $3, $9  			# $4 = -1 + 1 = 0 (ok)

				# test sub
				sub   $4, $2, $9				# $4 = 0x80000000 - 1 (cause overflow exception)
				# exceptions = 5
				sub   $4, $1, $3				# $4 = 0x7FFFFFFF -(-1) (cause overflow exception)
				# exceptions = 6
				sub   $4, $3, $9				# $4 = -1 - 1 (ok)

				# test addu
				addu  $4, $3, $9				# $4 = 0xFFFFFFFF + 1 (ok)
				# test subu
				subu  $4, $0, $1				# $4 = 0 - 0xFFFFFFFF (ok)
				# test addiu
				addiu $4, $3, 1					# $4 = 0xFFFFFFFF + 1 (ok)

        sw    $5, 4($0)         # should write #overflows (6) to address 0x4 (result for tb)
        addi  $1, $0, 1					# initialize $1 = 1
				sw	  $1, 0($0)					# should write 1 to address 0 (finish for tb)
end:   nop
nop
nop
nop
nop
