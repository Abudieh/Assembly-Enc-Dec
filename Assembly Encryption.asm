org 100h

.DATA
   AUTH_ERROR DB 0AH,0DH,"There is a problem with the entered username and/or password; please try again later.$" 
   WELCOME DB "WELCOME, PLEASE AUTHENTICATE TO GET ACCESS TO THE SERVICES$"
   ACCESS_GRANTED DB 0AH,0DH, "ACCESS GRANTED...$"
   WRONG_USER DB 0AH,0DH, "USER DOES NOT EXIST$"
   WRONG_PASS DB 0AH,0DH, "WRONG PASSWORD$"
   INVALID_USIZE DB 0AH,0DH, "INVALID USERNAME LENGTH$"
   INVALID_PSIZE DB 0AH,0DH, "INVALID PASSWORD LENGTH$"
   CHOICE DB 0AH,0DH,"IF YOU WANT TO ENCRYPT TYPE E, DECRYPT TYPE D : $"
   CHOICE_REP DB 0AH,0DH,"THIS IS AN ILLEGAL CHARACTER,PLEASE TRY AGAIN: $"
   KEY_INP DB 0AH,0DH,"ENTER THE ENCRYPTION KEY(A SINGLE DIGIT FROM 1 T0 9): $"
   PLAIN_TEXT DB 0AH,0DH,"INPUT A MESSAGE OF NO MORE THAN 20 CHARACTERS. WHEN DONE,PRESS <ENTER>: $"
   CIPHER_TEXT DB 0AH,0DH,"MESSAGE AFTER ENCRYPTION: $"
   AFTER_DECRYPTION DB 0AH,0DH,"MESSAGE AFTER DECRYPTION: $" 
   ENTER_USER DB 0AH,0DH,"ENTER USERNAME: $"
   ENTER_PASS DB 0AH,0DH,"ENTER PASSWORD: $"
   USER1 DB "YOUSIF",0
   USER2 DB "ISLAM",0
   USER3 DB "KHALED",0
   USER4 DB "AHMED",0
   USER5 DB "RASHED",0
   USER6 DB "AMER",0
   USER7 DB "AMMAR",0
   USER8 DB "IBRAHEEM",0
   USER9 DB "YAZAN",0
   USER10 DB "SAEED",0
   PASS1 DB "PASSWORD1",0
   PASS2 DB "PASSWORD2",0
   PASS3 DB "PASSWORD3",0
   PASS4 DB "PASSWORD4",0
   PASS5 DB "PASSWORD5",0
   PASS6 DB "PASSWORD6",0
   PASS7 DB "PASSWORD7",0
   PASS8 DB "PASSWORD8",0
   PASS9 DB "PASSWORD9",0
   PASS10 DB "PASSWORD10",0   
   INPUT DB 21,0,21 DUP(' ')
   ARRAYOFUSERS DW OFFSET USER1,OFFSET USER2,OFFSET USER3, OFFSET USER4,OFFSET USER5,OFFSET USER6,OFFSET USER7,OFFSET USER8,OFFSET USER9,OFFSET USER10
   ARRAYOFPASSWORDS DW OFFSET PASS1,OFFSET PASS2,OFFSET PASS3, OFFSET PASS4,OFFSET PASS5,OFFSET PASS6,OFFSET PASS7,OFFSET PASS8,OFFSET PASS9,OFFSET PASS10  
   

.CODE 
MOV AX,@DATA
MOV DS,AX 
 
MOV DX, OFFSET WELCOME
MOV AH,9                 ;Display Welcome message
INT 21H


CALL UAM
CALL DEM

        
UAM PROC   ;User authentication module
    
    MOV AH,9  
    MOV DX, OFFSET ENTER_USER     ;Ask user to enter username
    INT 21H

    MOV AH,0AH
    MOV DX,OFFSET INPUT           ;Stores user input in variable name input
    INT 21H  
    
    mov si,offset input + 2       ;si points at first byte
    mov cx,0  ;cx is a counter that will contain the length of the string entered

        
    cmp [si],0DH ;If the user presses enter key without typing any characters, the size is considered invalid and the program stops, otherwise we will start counting the number of characters entered
    jne increment 
    jmp invalidusize      
    increment: 
      inc cx
      inc si
      cmp [si],0DH     ;when we reach 0DH, this means the string finished, and CX contains the length of the string (NOT including 0DH (enter key))
      jne increment    ;keep counting until 0DH is encountered
  
     cmp cx,8   ;0DH is reached, which means cx contains the length
     ja invalidusize ;if cx > 8 jump to label invalidusize, which displays an error message and exits
 
          
    MOV BX,0 ;BX helps us get the offset of each user from ARRAYOFUSERS which is defined in DS 
    compare_users: 
        mov si,offset input + 2 ;si points at the first character entered by user.
        mov di, arrayofusers[BX] ;BX is added to the offset of arrayofusers, and the contents (which will be the offset of one of the users) is moved to di. when bx=0, di points at first byte of USER1
                                 ;When BX=2, di will point at the first byte of USER2, .... , When BX=18, di will point at the first byte of USER10 
        
        cmpr:
        inc si
        inc di
        MOV AL, [SI-1] 
        cmp al,[di-1] ;Compare first byte from user input with first byte from the user stored in memory
        je cmpr ;keep comparing until the bytes are not equal
        cmp [DI-1],0 ;When the bytes from both strings are not equal, check if DI reached 0, which means it finished the string.
        je checksi ;If so, check if SI reached 0DH, which means the string entered by user is also finished.
        jmp incrm  ;Otherwise, Add 2 to BX (Because we used DW in ARRAYOFUSERS, so we add 2 to get to the next element) and compare the string entered by user with the next username stored in memory
        checksi:
        cmp [si-1],0DH ;Check if the string entered by user is finished.
        je pw  ;if so, then the string entered by user and the username stored in memory match.
        ;so go to the label pw, which lets the user enter the password and checks if it is a match to the password in memory.
        ; (NOTE: BX will help us get to the password associated with the username that got a match with the string entered.) 
        
        jmp incrm ;Otherwise, the passwords don't fully match so add 2 to bx and check the next username in memory
    
    
        incrm:
        ADD BX,2 ;Add 2 to bx to make it help us get the offset of next username in memory by adding it to offset of ARRAYOFUSERS
        CMP BX,20
        JB compare_users ;compare the string entered with the next username in memory. 
        JMP WRONGUSER ;if BX reaches 20, this means we checked all of the usernames in memory and we didn't get a match, so display an error message and exit.
        


    PW:    


    MOV AH,9  
    MOV DX, OFFSET ENTER_PASS    ;Ask user to enter password.
    INT 21H

    MOV AH,0AH
    MOV DX,OFFSET INPUT          ;Let user enter a string, which will be stored in INPUT defined in DS
    INT 21H  
    
    mov si,offset input + 2      ;si points at first character in the string INPUT
    mov cx,0

        
    cmp [si],0DH
    jne increment2
    jmp invalidpsize
    increment2:
      inc cx                   ;Same idea of counting length of username above.
      inc si
      cmp [si],0DH
      jne increment2
  
     cmp cx,16
     ja invalidpsize
 
     
     
     mov si,offset input + 2           
     mov di, arrayofpasswords[BX]  ;BX is added to arrayofpasswords and the contents will be moved to di, the contents will be the offset of the password associated
     ;with the username in memory that got a match with the username entered by the user. 
     ;For example, if the loop that checked on the username stopped when BX was 4, this means that the user entered USER3, so here, BX is still 4, which means the password entered will only be compared with PASS3
     
     checkpassword:
     inc si
     inc di
     mov al,[si-1]
     cmp al,[di-1]  ;compare each character of the password entered with the password stored in memory
     je checkpassword  ;keep comparing until the bytes don't match.
     cmp [di-1],0 ;check if the password in memory finished
     je checksi2 ;if so, go to this lable which checks if the string entered is finished
     jmp wrongpass ;if not, go to this lable which displays an error message and exits.
     checksi2:
     cmp [si-1],0DH 
     je start  ;if the string entered is finished, go to this label which displays a message that says "ACCESS GRANTED"
     jmp wrongpass
 
     START:
        MOV DX,OFFSET ACCESS_GRANTED
        MOV AH,9
        INT 21H                                 ;Display "ACCESS GRANTED..." and return
        RET 
    
    
     EXIT:
       HLT
       RET
   
   
   
     wronguser:
      MOV DX, OFFSET WRONG_USER       ;Display error message for non existing username
      MOV AH,9
      INT 21H 
        
      MOV DX, OFFSET AUTH_ERROR
      MOV AH,9
      INT 21H  
      JMP EXIT 
 
    wrongpass:
      MOV DX, OFFSET WRONG_PASS
      MOV AH,9
      INT 21H                              ;Display error message for wrong password
      
      MOV DX, OFFSET AUTH_ERROR
      MOV AH,9
      INT 21H
      JMP EXIT

    invalidusize:
      MOV DX, OFFSET INVALID_USIZE
      MOV AH,9
      INT 21H                             ;Display error message for invalid username size
      
      MOV DX, OFFSET AUTH_ERROR
      MOV AH,9
      INT 21H
      JMP EXIT

    invalidpsize:
      MOV DX, OFFSET INVALID_PSIZE
      MOV AH,9
      INT 21H
                                              ;Display error message for invalid password size
      MOV DX, OFFSET AUTH_ERROR
      MOV AH,9
      INT 21H
      JMP EXIT     
 
 RET
 ENDP
 
 
  
 
 
 
 
  
 
 
  
DEM PROC     ;Data encryption module    
    
    MOV DX,OFFSET CHOICE
    MOV AH,9
    INT 21H            ;Asks the user to enter D or E
     
    ENTERCHOICE:  
    
    MOV AH,1
    INT 21H    ;read character from user and store in AL
    
    CMP AL,'E'
    JE ENTER_KEY
    CMP AL,'D'           ;Jump to label enter_key if the character entered is D or E
    JE ENTER_KEY 
    
    
    MOV DX,OFFSET CHOICE_REP
    MOV AH,9
    INT 21H                     ;Otherwise, display a message asking the user to enter another character until E or D is entered
    JMP ENTERCHOICE 
    
     
     
    
    ENTER_KEY:
    MOV [3100H],AL    ;store E or D in memory location 3100H  
    
    
    MOV DX,OFFSET KEY_INP  ;Ask the user to enter key                                  
    MOV AH,9
    INT 21H  
    
    MOV AH,1
    INT 21H         ;read key from user and store in AL
    
    SUB AL,30H      ;Subtract 30H to convert the number from ascii to the actual number
    MOV [3101H],AL   ;store key in memory location 3101H
    
    
    
    ENTER_TEXT:        
     MOV DX,OFFSET PLAIN_TEXT
     MOV AH,9                  ;ask user to enter text
     INT 21H
     
     MOV BX,0    ;BX here works as a counter and helps store caharacters in correct memory locations
     ENTERTEXT:
     MOV AH,1 ;read character from user and store in AL
     INT 21H
     
     CMP AL,0DH ;Check if it is the ENTER key
     JE E_D ;if so, go to E_D
     MOV [3102H + BX],AL ;Otherwise, store that character in location 3102H + BX, first character is stored in 3102H+0, 2nd is stored in 3102H+2 and so on
                         ;NOTE: 0DH will also be stored in its correct location when we jump to E_D
     
     INC BX
     CMP BX,20 ;Check if the user reached 20 characters
     JB ENTERTEXT ;If not, continue the loop
     E_D:  
     MOV [3102H + BX],0DH  ;If they reached 20 characters or they pressed the enter key, 0DH is stored in its correct location, right after the end of the characters.    
     
     CMP [3100H],'E' 
     JE ENCRYPT         ;Go to Encrypt ot Decrypt based on the choice entered by user earlier.
     JMP DECRYPT
   
   
   
   
   
   
   ENCRYPT: 
    
    MOV BX,0 ;BX helps us iterate through the characters
    ENC_LOOP:
    CMP [3102H+BX],0DH   ;Check if we reached 0DH (Enter key)
    JE AFTER_ENC         ;If so, go to label AFTER_ENC
    CMP [3102H+BX],'a'   ;Otherwise, check if the letter is small
    JAE ENCSMALL ;If so, go to the encsmall label which encrypts a small letter
    CMP [3102H+BX],'A' ;otherwise, check if it is capital
    JAE ENCCAP;If so, go to label ENCCAP which encrypts a capital letter 
    MOV AL,[3102H+BX] ;Otherwise, the encryption will be based on the ascii code only.
    ADD AL,[3101H]
    CMP AL,127 ;Compare the ascii after adding the key with 127, which is the max ascii code.
    JA SUBTRACT3 ;If it is greater than 127 go to this label. 
    MOV [3102H+BX],AL ;Otherwise, store the character after encryption to its location
    INC BX ;Helps us get to the next character later.
    JMP ENC_LOOP ;Repeat the loop  
    
    SUBTRACT3:
    SUB AL,128 ;Subtract 128 from the ascii to make it go back to the beginning of ascii codes.
    MOV [3102H+BX],AL  ;Store the encrypted character in its correct location.
    INC BX ;Helps us get to the next character later.
    JMP ENC_LOOP ;Repeat
    
    
    ENCCAP:
    MOV AL,[3102H+BX]
    SUB AL,65 ;Subtract 65 which is the ascii for 'A' from the ascii of the capital letter.
    ADD AL,[3101H] ;Add the key.
    CMP AL,25
    JA SUBTRACT2 ;if the number is greater than 25, go to this label
    ADD AL,65 ;otherwise, add 65 to go back to the correct ascii code of the encrypted character
    MOV [3102H+BX],AL ;store the ascii of the encrypted character in its location.
    INC BX  ;helps us get to the next character
    JMP ENC_LOOP  ;repeat
    
    SUBTRACT2:
    SUB AL,26  ;If the new number is greater than 25, this means that we have to go back to the beginning of the letters, so we subtract 26.
    ADD AL,65  ;Add 65 to get to the ascii of the correct encrypted character 
    MOV [3102H+BX],AL ;Store encrypted character in its correct location
    INC BX  ;helps us get to the next character
    JMP ENC_LOOP  ;repeat
    
    
    
    ENCSMALL:
    MOV AL,[3102H+BX]  
    SUB AL,97   ;Subtract the ascii of 'a'
    ADD AL,[3101H]  ;Add the key
    CMP AL,25  
    JA SUBTRACT   ;If the new number is greater than 25, jump to subtract label
    ADD AL,97    ;otherwise, add 97 to go to the correct ascii of the encrypted letter.
    MOV [3102H+BX],AL  ;store encypted letter in correct location
    INC BX ;same as earlier
    JMP ENC_LOOP ;repeat
    
    SUBTRACT:  ;Same as SUBTRACT2 but we add 97 instead of 65 because this is for small letters
    SUB AL,26  
    ADD AL,97
    MOV [3102H+BX],AL
    INC BX
    JMP ENC_LOOP
    
    
    
    AFTER_ENC:   
    MOV [3102H+BX],'$'    ;Store '$' instead of 0DH, in order to properly display the text.
    MOV DX, OFFSET CIPHER_TEXT        
    MOV AH,9
    INT 21H
    
    MOV DX, 3102H ;DX has the address of the first character
    MOV AH,9                 ;Display text and exit
    INT 21H
    JMP EXIT2  
    
    
    
    
    
    DECRYPT:
    
    MOV BX,0
    DEC_LOOP:
    CMP [3102H + BX],0DH
    JE AFTER_DEC
    CMP [3102H + BX], 'a'
    JAE DEC_SMALL
    CMP [3102H+BX],'A'                                        ;Same idea as encryption, but here we decrypt the characters by subtracting the key instead of adding it
    JAE DEC_CAP
    MOV AL,[3102H+BX]
    SUB AL,[3101H]
    MOV [3102H+BX],AL
    INC BX
    JMP DEC_LOOP
    
    
    
    
    
    DEC_CAP:
    MOV AL,[3102H+BX]
    SUB AL,[3101H] ;We subtract the key first                                     
    CMP AL,'A' ;We check if we have to go to the end of the letters.
    JB FIXLETTER ;If so, jump to label fixletter
    MOV [3102H+BX],AL ;Otherwise, move the decrypted character to its correct location
    
    INC BX     
    JMP DEC_LOOP
    
    
    
    DEC_SMALL:
    MOV AL,[3102H + BX]
    SUB AL,[3101H]
    CMP AL,'a'
    JB FIXLETTER              ;Same as DEC_CAP but we compare with the ascii of 'a'
    MOV [3102H+BX],AL
    INC BX
    JMP DEC_LOOP 
    
    
    FIXLETTER:
    ADD AL,26 ;Add 26 to fix the decrypted letter.
    MOV [3102H+BX],AL  ;Store in correct location
    INC BX
    JMP DEC_LOOP 
    
    
    AFTER_DEC:
    MOV [3102H+BX],'$'
    MOV DX,OFFSET AFTER_DECRYPTION
    MOV AH,9
    INT 21H
                                         ;Same idea as AFTER_ENC above
    MOV DX,3102H
    MOV AH,9
    INT 21H
    JMP EXIT2
    
     
   EXIT2:
   HLT
   RET 
    
    
RET
ENDP