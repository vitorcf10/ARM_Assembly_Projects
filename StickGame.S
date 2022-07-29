//R0 - remaining matchsticks
  2|//R1 - used for writing messages
  3|//R2 - number to remove
  4|      MOV R3, #0
  5|      MOV R4, #0
  6|replay: MOV R1, #msg8
  7|      STR R1, .WriteString
  8|      MOV R1, #msg9
  9|      STR R1, .WriteString
 10|      STR R3, .WriteUnsignedNum
 11|      MOV R1, #msg10
 12|      STR R1, .WriteString
 13|      STR R4, .WriteUnsignedNum
 14|      MOV R1, #msg11
 15|      STR R1, .WriteString
 16|back: LDR R0, .Random
 17|      AND R0, R0, #31
 18|      CMP R0, #15
 19|      BLT back
 20|loop:
 21|      STR R0, .WriteUnsignedNum //Mostra palitos sobrando
 22|      MOV R1, #msg1
 23|      STR R1, .WriteString
 24|// Vez do Computador Jogar
 25|select: LDR R2, .Random
 26|      AND R2, R2, #3
 27|      CMP R2, #0
 28|      BEQ select
 29|      CMP R2, R0
 30|      BGT select
 31|      BEQ select
 32|cont:
 33|      STR R2, .WriteSignedNum
 34|      MOV R1, #msg4
 35|      STR R1, .WriteString
 36|      SUB R0, R0, R2
 37|      STR R0, .WriteUnsignedNum //Mostra palitos sobrando
 38|      MOV R1, #msg1
 39|      STR R1, .WriteString
 40|//Verifica se computador ganhou
 41|      CMP R0, #1
 42|      BEQ ComputadorVenceu
 43|//Vez do Jogador:
 44|      MOV R1, #msg2
 45|      STR R1, .WriteString
 46|      B input
 47|error: MOV R1, #msg6
 48|      STR R1, .WriteString
 49|input: LDR R2, .InputNum
 50|      CMP R2, #3
 51|      BGT error
 52|      CMP R2, #1
 53|      BLT error
 54|      CMP R2, R0
 55|      BGT error
 56|      SUB R0, R0, R2
 57|      CMP R0, #1
 58|      BEQ JogadorVenceu
 59|      b loop
 60|JogadorVenceu:
 61|      MOV R1,#msg3
 62|      STR R1, .WriteString
 63|      MOV R1, #msg7
 64|      STR R1, .WriteString
 65|      ADD R3, R3, #1
 66|      B replay
 67|ComputadorVenceu:
 68|      MOV R1,#msg5
 69|      STR R1, .WriteString
 70|      MOV R1, #msg7
 71|      STR R1, .WriteString
 72|      ADD R4, R4, #1
 73|      B replay
 74|msg1: .ASCIZ "Palitos sobrando \n"
 75|msg2: .ASCIZ "Quantos palitos você quer remover(1-3)? \n \n"
 76|msg3: .ASCIZ "Você Venceu!\n"
 77|msg4: .ASCIZ "Removidos pelo computador \n "
 78|msg5: .ASCIZ "Computador Venceu! \n"
 79|msg6: .ASCIZ "Digite um valor valido!\n"
 80|msg7: .ASCIZ "Vamos para proxima partida...\n"
 81|msg8: .ASCIZ "Placar:\n"
 82|msg9: .ASCIZ "Você:"
 83|msg10: .ASCIZ "\nComputador:"
 84|msg11: .ASCIZ "\n"
