.data
    # Definição do array e seu tamanho
    array:          .word 10, 25, 5, 150, 99, 7, 42    # Nosso array de inteiros
    array_len:      .word 7                            # Tamanho do array (número de elementos)

    # Strings para formatação da saída
    open_bracket:   .asciiz "["
    close_bracket:  .asciiz "]"
    comma_space:    .asciiz ", "
    newline:        .asciiz "\n"

.text
.globl main
main:
    # --- Inicialização ---
    # Carrega o endereço base e o tamanho do array nos registradores
    la   $t0, array          # $t0 = endereço do início do array
    lw   $t1, array_len      # $t1 = tamanho do array (7)
    li   $t2, 0              # $t2 = nosso contador/índice (i = 0)

    # 1. Imprime o colchete de abertura "["
    li   $v0, 4              # syscall 4: print_string
    la   $a0, open_bracket   # carrega o endereço da string a ser impressa
    syscall

# --- Loop para percorrer o array ---
loop:
    # Condição de saída: se (índice >= tamanho), salta para o final
    bge  $t2, $t1, end_loop

    # Calcula o endereço do elemento atual: endereço_base + (índice * 4)
    mul  $t3, $t2, 4         # $t3 = índice * 4 (cada inteiro ocupa 4 bytes)
    add  $t3, $t0, $t3       # $t3 = endereço do elemento array[i]

    # Carrega e imprime o valor do elemento
    lw   $a0, 0($t3)         # $a0 = valor que está no endereço contido em $t3
    li   $v0, 1              # syscall 1: print_int
    syscall

    # Incrementa o índice para o próximo elemento
    addi $t2, $t2, 1

    # Verifica se este é o último elemento. Se for, não imprime a vírgula.
    beq  $t2, $t1, loop      # Se (novo_índice == tamanho), volta ao loop sem imprimir ","

    # Imprime a vírgula e o espaço ", "
    li   $v0, 4              # syscall 4: print_string
    la   $a0, comma_space    # carrega o endereço de ", "
    syscall

    # Volta para o início do loop
    j    loop

# --- Finalização ---
end_loop:
    # 2. Imprime o colchete de fechamento "]"
    li   $v0, 4              # syscall 4: print_string
    la   $a0, close_bracket  # carrega o endereço de "]"
    syscall

    # 3. Imprime uma nova linha para formatação
    li   $v0, 4              # syscall 4: print_string
    la   $a0, newline        # carrega o endereço do "\n"
    syscall

    # 4. Termina o programa
    li   $v0, 10             # syscall 10: exit
    syscall