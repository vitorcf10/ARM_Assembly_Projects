1|//Uso de registradores:
  2|// R0,R1,R2: reservado p/ uso temporário
  3|// Variáveis Globais:
  4|// R3 Posição da calda
  5|// R4 Posição da cabeça
  6|// R7 valor ASCII p/ última tecla pressionada
  7|// MOV R8, #0 // Número de maçãs comidas
  8|// R5 Frente da Fila (endereço da cauda da cobra)
  9|// R6 Fim da Fila (endereço da cabeça da cobra)
 10|// Constantes:
 11|      MOV R9, #0
 12|      MOV R10,#.PixelScreen
 13|      MOV R11, #.green  //Cor da cobra
 14|      MOV R12, #.red    //Cor da maçã
 15|//Configure as interrupções, mas não habilite ainda
 16|      MOV R0, #update
 17|      STR R0, .ClockISR
 18|      MOV R0, #0x50
 19|      STR R0,.ClockInterruptFrequency
 20|      MOV R0, #keyPress
 21|      STR R0, .KeyboardISR
 22|      MOV R0, #1
 23|      STR R0, .KeyboardMask
 24|//Inicializar jogo:
 25|      MOV R3, #1084     //Initializar calda
 26|      MOV R4, #1088     //Inicializar cabeça (4 bytes = 1 word = 1 pixel)
 27|      STR R11,[R10+R3]  //Desenhar cobra de dois segmentos
 28|      STR R11,[R10+R4]
 29|      MOV R5, #body     // Ponteiro para início da fila, initializado pelo primeiro endereço de memória da área reservada para isso
 30|      ADD R6,R5,#4      // // Ponteiro para endereço da cabeça da cobra (1 após a cauda da cobra)
 31|      STR R3, [R5]      //R3 aponta p/ o endereço da cauda
 32|      STR R4, [R6]      //R4 aponta p/ o endereço da cabeça
 33|      MOV R0, #1
 34|      BL createApple    // Gerar maçã
 35|      BL createApple    // Gerar maçã
 36|      BL createApple    // Gerar maçã
 37|      BL createApple    // Gerar maçã
 38|      BL createApple    // Gerar maçã
 39|      BL createBomb
 40|      BL createBomb
 41|      BL createBomb
 42|      BL createBomb
 43|      STR R0, .InterruptRegister //Habilitar interrupção agora
 44|mainLoop: b mainLoop    //Loop infinito, para manter processo rodando
 45|//Atualizações disparadas por interrupções:
 46|update:
 47|//Estrutura "case", de acordo c/ valor da última tecla
 48|      CMP R7,#87        //tecla W
 49|      BEQ up
 50|      CMP R7,#65        //tecla A
 51|      BEQ left
 52|      CMP R7,#83        //tecla  S
 53|      BEQ down
 54|// Default: tecla D (direita)
 55|right:ADD R4,R4,#4      //+4 (bytes) move 1 pixel p/ direita
 56|      AND R0,R4,#255
 57|      CMP R0,#0
 58|      BEQ gameOver
 59|      B reDraw
 60|down: ADD R4,R4,#256    //+64*4 move 1 linha p/ baixo
 61|      MOV R0, #12284    // One pixel a mais do que o válido
 62|      CMP R4,R0
 63|      BGT gameOver
 64|      B reDraw
 65|up:   SUB R4,R4,#256    //-64*4 move 1 linha p/ cima
 66|      CMP R4,#0
 67|      BLT gameOver
 68|      B reDraw
 69|left: SUB R4,R4,#4      //-4 move 1 pixel p/ esquerda
 70|      AND R0,r4,#255
 71|      CMP R0,#252
 72|      BEQ gameOver
 73|reDraw:
 74|//Primeiro verificar se a cobra está atravessado seu corpo:
 75|      LDR R0,[R10+R4]   // Ler conteúdo (cor) do pixel da tela
 76|      CMP R0,R11        //Se for da mesma cor da cobra...
 77|      BNE .+2
 78|      ADD R9, R9, #1
 79|      CMP R9, #3
 80|      BEQ gameOver
 81|      LDR R0,[R10+R4]   // Ler conteúdo (cor) do pixel da tela
 82|      CMP R0,#.black    //Se for da mesma cor da bomba...
 83|      BNE .+2
 84|      ADD R9, R9, #1
 85|      CMP R9, #3
 86|      BEQ gameOver
 87|      ADD R6,R6,#4      //Incrementa ponteiro da parte final da fila
 88|      CMP R6,#limit     //Verifique se o ponteiro ainda está dentro dos limites da fila circular
 89|      BLT .+2
 90|      MOV R6, #body     // Caso não, retorne o ponteiro para o início da área de memória
 91|      STR R4, [R6]      //Armazena o novo número de pixel da cabeça no final da fila
 92|      CMP R0, R12       //Verifica se pixel é da cor da maçã
 93|      BEQ eat
 94|      MOV R0, #.white
 95|      STR R0, [R10+R3]  // Pintar de branco pixel atual da cauda
 96|      ADD R5,R5,#4      //Incrementa ponteiro da parte inicial da fila
 97|      CMP R5,#limit     //Verifique se o ponteiro ainda está dentro dos limites da fila circular
 98|      BLT .+2
 99|      MOV R5, #body     //Caso não, retorne o ponteiro para o início da área de memória
100|      LDR R3,[R5]       // Recuperar nro do pixel da nova cauda
101|      B .+3             // Retornar
102|eat:  ADD R8,R8,#1      //Incrementar contagem
103|      BL createApple
104|      STR R11,[R10+R4]  //Desenhar nova cabeça
105|      RFE
106|//Chamada via interrupção de teclado
107|//Se tecla válida pressionada (W,A,S,D), transferir conteúdo p/ R7
108|keyPress: PUSH {R0}
109|      LDR R0,.LastKey   //Ler última tecla pressionada
110|      CMP R0,#87        //W key
111|      BEQ updateLastKey
112|      CMP R0,#65        //A key
113|      BEQ updateLastKey
114|      CMP R0,#83        //S key
115|      BEQ updateLastKey
116|      CMP R0,#68        //D key
117|      BEQ updateLastKey
118|      B .+2             //Se nova tecla não é válida, não mudar valor da última
119|updateLastKey:
120|      MOV R7, R0
121|      POP {R0}
122|      RFE
123|//Gera maça em local aleatório
124|createApple: push {R0,R1, LR}
125|newRandom: LDR R1,.Random // gera número aleatório de 32 bits
126|      MOV R0, #0x3ffc   // Limitar nro a 14 bits
127|      AND R1,R1,R0
128|      MOV R0, #12284    //Máximo nro do pixel
129|      CMP R1,R0
130|      BGT newRandom     // Gerar novamente
131|      LDR R0, [R10+R1]  //Obter pixel
132|      CMP R0,R11        //Compar cor do pixel com cor da cobra
133|      BEQ newRandom
134|      LDR R0, [R10+R1]  //Obter pixel
135|      CMP R0,R9
136|      BEQ newRandom
137|      STR R12, [R10+R1] //Desenhar maçã
138|      POP {R0,R1,LR}
139|      RET
140|createBomb: push {R0,R1,R9, LR}
141|      MOV R9, #.black
142|newRandom1: LDR R1,.Random // gera número aleatório de 32 bits
143|      MOV R0, #0x3ffc   // Limitar nro a 14 bits
144|      AND R1,R1,R0
145|      MOV R0, #12284    //Máximo nro do pixel
146|      CMP R1,R0
147|      BGT newRandom1    // Gerar novamente
148|      LDR R0, [R10+R1]  //Obter pixel
149|      CMP R0,R11        //Compar cor do pixel com cor da cobra
150|      BEQ newRandom
151|      LDR R0, [R10+R1]  //Obter pixel
152|      CMP R0,R10
153|      BEQ newRandom1
154|      STR R9, [R10+R1]  //Desenhar maçã
155|      POP {R0,R1,R9, LR}
156|      RET
157|gameOver: MOV R0, #over
158|      STR R0,.WriteString
159|      MOV R0, #score
160|      STR R0,.WriteString
161|      STR R8, .WriteSignedNum
162|      HALT              //para evitar execução do programa invadir área de dados
163|over: .ASCIZ " Game Over!"
164|score: .ASCIZ "Seus pontos: "
165|      .ALIGN 256
166|body: .BLOCK 3072       //A fila de segmentos do corpo começa a partir deste ponto da memória
167|limit:                  //1 past end of queue data