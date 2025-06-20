
# quicksort(array, low, high)
# -----------------------------------------------
quicksort:
	addi    $sp, $sp, -16
	sw      $ra, 0($sp)
	sw      $a1, 4($sp)
	sw      $a2, 8($sp)
	sw      $a0, 12($sp)

	bge     $a1, $a2, quick_exit                                                   # Condição de parada: low >= high

	jal     partition                                                              # Particiona o array (pivot em $v0)
	move    $t0, $v0                                                               # Salva índice do pivot

	# quicksort(array, low, pivot-1)
	lw      $a0, 12($sp)
	lw      $a1, 4($sp)
	addi    $a2, $t0, -1
	jal     quicksort

	# quicksort(array, pivot+1, high)
	lw      $a0, 12($sp)
	addi    $a1, $t0, 1
	lw      $a2, 8($sp)
	jal     quicksort

quick_exit:
	lw      $ra, 0($sp)
	addi    $sp, $sp, 16
	jr      $ra

# partition(array, low, high)
# ---------------------------------------------------
#   Realiza a partição do array com base no pivot (último elemento).
#   Todos os menores ou iguais vão à esquerda do pivot.
#   Retorna o índice do pivot posicionado corretamente.
#
# Entrada:  $a0 = base do array
#           $a1 = low
#           $a2 = high
# Saída:    $v0 = índice final do pivot

partition:
	mul     $t0, $a2, 4
	add     $t0, $a0, $t0
	lw      $t7, 0($t0)               # pivot = array[high]

	addi    $t1, $a1, -1              # i = low - 1
	move    $t2, $a1                  # j = low

partition_loop:
	bge     $t2, $a2, partition_end   # Enquanto j < high

	mul     $t3, $t2, 4
	add     $t4, $a0, $t3
	lw      $t5, 0($t4)               # array[j]

	ble     $t5, $t7, swap_it
	j       skip_swap

swap_it:
	addi    $t1, $t1, 1
	mul     $t6, $t1, 4
	add     $t8, $a0, $t6

	lw      $t9, 0($t8)
	sw      $t5, 0($t8)
	sw      $t9, 0($t4)

skip_swap:
	addi    $t2, $t2, 1
	j       partition_loop

partition_end:
	addi    $t1, $t1, 1
	mul     $t3, $t1, 4
	add     $t4, $a0, $t3

	lw      $t5, 0($t4)
	sw      $t7, 0($t4)
	sw      $t5, 0($t0)

	move    $v0, $t1
	jr      $ra
