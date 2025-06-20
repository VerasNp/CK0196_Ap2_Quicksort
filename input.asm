.data                                                                           # Define um bloco de dados
prompt_input:   .asciiz "Digite um número inteiro positivo (0 para terminar): " # Prompt para a entrada de números
newline:        .asciiz "\n"                                                    # Caractere de nova linha

                .align  2                                                       # Define um limite de alinhamento de 2*2 bytes
array:          .space  400                                                     # Reserva um espaço para 100 inteiros (100 * 4 bytes)
n:              .word   0                                                       # Guarda a quantidade de números lidos

.text                                                                           # Define um bloco de instruções
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

	li      $v0,        4                                                          # Imprime uma nova linha
	la      $a0,        newline                                                    # Carrega o endereço de newline
	syscall                                                                        # Chamada de sistema para imprimir string

    # Imprime o total de números lidos (opcional)
	li      $v0,        1                                                          # Imprime o total de números lidos
	move    $a0,        $t1                                                        # Move o contador de números lidos para $a0
	syscall                                                                        # Chamada de sistema para imprimir inteiro

	li      $v0,        4                                                          # Imprime uma nova linha
	la      $a0,        newline                                                    # Carrega o endereço de newline
	syscall                                                                        # Chamada de sistema para imprimir string

	li      $v0,        10                                                         # Chamada de sistema para encerrar o programa
	syscall                                                                        # Chamada de sistema para encerrar
