.data
prompt_input:   .asciiz "Digite um número inteiro positivo (0 para terminar): " # Prompt para a entrada de números
newline:        .asciiz "\n"                                                    # Caractere de nova linha
open_bracket:   .asciiz "["                                                     # Colchete de abertura para imprimir array
close_bracket:  .asciiz "]"                                                     # Colchete de fechamento para imprimir array
comma_space:    .asciiz ", "                                                    # Separador entre elementos do array

                .align  2                                                       # Define um limite de alinhamento de 2*2 bytes
array:          .space  400                                                     # Reserva um espaço para 100 inteiros (100 * 4 bytes)
n:              .word   0                                                       # Guarda a quantidade de números lidos

.text
                .globl  main                                                    # Define o símbolo main como global, e ponto de entrada do programa

main:
	li      $t1,        0                                                          # Inicializa o contador de números lidos em 0

read_loop:
	# read_loop method
	#   Laço principal que solicita entrada do usuário.
	#   Lê inteiros via syscall, armazena no array.
	#   Encerra quando o usuário digita 0.
	#
	# Output:
	#   Array preenchido com os inteiros inseridos.
	#   Variável 'n' contém o número total de entradas.

	li      $v0,        4                                                          # Imprime o prompt de entrada
	la      $a0,        prompt_input                                               # Carrega o endereço de prompt_input
	syscall                                                                        # Chamada de sistema para imprimir string

	li      $v0,        5                                                          # Lê um inteiro do usuário
	syscall                                                                        # Chamada de sistema para ler inteiro
	move    $t2,        $v0                                                        # Move o valor lido para $t2, registrador temporário

	beq     $t2,        $zero,          end_input                                  # Se o valor lido for 0, sai do loop

	mul     $t3,        $t1,            4                                          # Calcula o deslocamento: t1 * 4 (tamanho de um inteiro)
	la      $t4,        array                                                      # Carrega o endereço base do array
	add     $t5,        $t3,            $t4                                        # Calcula o endereço do próximo elemento a ser escrito
	sw      $t2,        0($t5)                                                     # Armazena o valor lido no array na posição calculada

	addi    $t1,        $t1,            1                                          # Incrementa em 1 o contador de elementos lidos
	j       read_loop                                                              # Volta para o início do loop

end_input:
	# end_input method
	#   Finaliza a leitura de números inteiros.
	#   Armazena a quantidade total de números lidos na variável 'n'.

	sw      $t1,        n                                                          # Armazena o total de números lidos na variável 'n'

	# Chamada do algoritmo de ordenação quicksort(array, 0, n-1)
	la      $a0,        array                                                      # Carrega endereço base do array
	li      $a1,        0                                                          # Índice inicial = 0
	lw      $a2,        n                                                          # Índice final = n - 1
	addi    $a2,        $a2, -1
	jal     quicksort                                                              # Chamada da função quicksort

	jal     print_array                                                            # Chamada para imprimir o array ordenado

	li      $v0,        10                                                         # Encerra o programa
	syscall

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

# print_array method
# ---------------------------------------------------
#   Imprime o conteúdo do array ordenado no formato:
#   [1, 2, 3, ..., n]
# ---------------------------------------------------
print_array:
	la      $t0, array                                                      # Endereço base do array
	lw      $t1, n                                                          # Tamanho do array
	li      $t2, 0                                                          # Índice = 0

	li      $v0, 4
	la      $a0, open_bracket                                               # Imprime "["
	syscall

print_loop:
	bge     $t2, $t1, print_done                                            # Fim do array

	mul     $t3, $t2, 4
	add     $t4, $t0, $t3
	lw      $a0, 0($t4)
	li      $v0, 1
	syscall                                                                # Imprime número

	addi    $t2, $t2, 1
	beq     $t2, $t1, print_loop                                           # Último elemento? Não imprime vírgula

	li      $v0, 4
	la      $a0, comma_space
	syscall                                                                # Imprime ", "

	j       print_loop

print_done:
	li      $v0, 4
	la      $a0, close_bracket
	syscall

	li      $v0, 4
	la      $a0, newline
	syscall

	jr      $ra