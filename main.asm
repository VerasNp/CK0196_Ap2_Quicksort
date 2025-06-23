# Programa que lê uma sequência de números inteiros positivos e faz a ordenação de forma crescente usando o algoritmo de Quicksort.
# A entrada termina quando o usuário digita 0.
# 
# Entrada:
#	Números inteiros positivos.
#
# Saída:
#	Array ordenado dos números inseridos de forma crescente.
.data
prompt_input:   .asciiz "Digite um número inteiro positivo (0 para terminar): " # String de entrada mostrada ao usuário
newline:        .asciiz "\n"                                                    # String de nova linha para quebra de linha
open_bracket:   .asciiz "["                                                     # Colchete de abertura para imprimir array
close_bracket:  .asciiz "]"                                                     # Colchete de fechamento para imprimir array
comma_space:    .asciiz ", "                                                    # Separador entre elementos do array

.align  2                   # Alinha os dados seguintes na memória para múltiplos de 4 bytes (bom para inteiros)
array:  .space  400         # Reserva 400 bytes para o array de inteiros (100 inteiros de 4 bytes)
n:      .word   0           # Reserva espaço para armazenar a quantidade de elementos lidos

.text
.globl  main                # Torna o símbolo 'main' visível ao linker como ponto de entrada

main:
    li $t1, 0               # Inicializa o contador de elementos lidos (n = 0)

read_loop:
    li $v0, 4               # syscall 4: imprimir string
    la $a0, prompt_input    # carrega o endereço da mensagem de entrada
    syscall                 # imprime a mensagem

    li $v0, 5               # syscall 5: ler inteiro
    syscall                 # realiza a leitura do número
    move $t2, $v0           # armazena o número lido em $t2

    beq $t2, $zero, end_input  # se o número for 0, sai do loop de leitura

    mul $t3, $t1, 4         # calcula o deslocamento no array (t1 * 4)
    la  $t4, array          # carrega o endereço base do array
    add $t5, $t3, $t4       # soma o offset ao endereço base
    sw  $t2, 0($t5)         # armazena o valor lido no array[t1]
    
    addi $t1, $t1, 1        # incrementa o contador de elementos
    j read_loop             # volta para o início do loop

end_input:
    sw $t1, n               # armazena o número total de elementos na variável 'n'

    la  $a0, array          # carrega o endereço do array em $a0
    li  $a1, 0              # $a1 = índice inicial (low)
    lw  $a2, n              # carrega o valor de n
    addi $a2, $a2, -1       # $a2 = high = n - 1
    jal quicksort           # chama a função quicksort(array, 0, n-1)

    jal print_array         # imprime o array ordenado

    li $v0, 10              # syscall 10: encerrar programa
    syscall

quicksort:
    addi $sp, $sp, -16      # aloca espaço na pilha para salvar registradores
    sw $ra, 0($sp)          # salva o endereço de retorno
    sw $a1, 4($sp)          # salva low
    sw $a2, 8($sp)          # salva high
    sw $a0, 12($sp)         # salva o endereço do array

    bge $a1, $a2, quick_exit  # se low >= high, termina a recursão

    jal partition            # chama a função de partição
    move $t0, $v0            # armazena índice do pivot

    lw $a0, 12($sp)          # restaura o array
    lw $a1, 4($sp)           # low permanece
    addi $a2, $t0, -1        # high = pivot - 1
    jal quicksort            # chamada recursiva

    lw $a0, 12($sp)          # restaura o array
    addi $a1, $t0, 1         # low = pivot + 1
    lw $a2, 8($sp)           # high permanece
    jal quicksort

quick_exit:
    lw $ra, 0($sp)           # restaura o endereço de retorno
    addi $sp, $sp, 16        # libera espaço da pilha
    jr $ra                   # retorna

partition:
    mul $t0, $a2, 4          # calcula o offset de high (high * 4)
    add $t0, $a0, $t0        # t0 = endereço de array[high]
    lw  $t7, 0($t0)          # t7 = pivot = array[high]

    addi $t1, $a1, -1        # i = low - 1
    move $t2, $a1            # j = low

partition_loop:
    bge $t2, $a2, partition_end   # se j >= high, termina loop

    mul $t3, $t2, 4               # calcula offset de j
    add $t4, $a0, $t3             # endereço de array[j]
    lw  $t5, 0($t4)               # carrega array[j]

    ble $t5, $t7, swap_it         # se array[j] <= pivot, faz a troca
    j skip_swap                   # senão, pula a troca

swap_it:
    addi $t1, $t1, 1              # i++
    mul $t6, $t1, 4               # offset de i
    add $t8, $a0, $t6             # endereço de array[i]

    lw  $t9, 0($t8)               # salva array[i] em t9
    sw  $t5, 0($t8)               # array[i] = array[j]
    sw  $t9, 0($t4)               # array[j] = valor antigo de array[i]

skip_swap:
    addi $t2, $t2, 1              # j++
    j partition_loop              # repete o loop

partition_end:
    addi $t1, $t1, 1              # i++
    mul  $t3, $t1, 4              # offset
    add  $t4, $a0, $t3            # endereço de array[i]

    lw  $t5, 0($t4)               # salva array[i]
    sw  $t7, 0($t4)               # array[i] = pivot
    sw  $t5, 0($t0)               # array[high] = array[i] original

    move $v0, $t1                 # retorna índice final do pivot
    jr   $ra

print_array:
    la $t0, array                 # carrega endereço base do array
    lw $t1, n                     # carrega quantidade de elementos
    li $t2, 0                     # índice = 0

    li $v0, 4
    la $a0, open_bracket          # imprime “[”
    syscall

print_loop:
    bge $t2, $t1, print_done      # se índice >= tamanho, sai

    mul $t3, $t2, 4               # calcula offset
    add $t4, $t0, $t3             # endereço de array[i]
    lw  $a0, 0($t4)               # carrega valor
    li  $v0, 1
    syscall                       # imprime o valor

    addi $t2, $t2, 1              # índice++

    beq $t2, $t1, print_loop      # se último elemento, pula vírgula

    li  $v0, 4
    la  $a0, comma_space          # imprime ", "
    syscall

    j print_loop                  # continua imprimindo

print_done:
    li $v0, 4
    la $a0, close_bracket         # imprime “]”
    syscall

    li $v0, 4
    la $a0, newline               # imprime nova linha
    syscall

    jr $ra                        # retorna
