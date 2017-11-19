cr equ 0dh                        ; carriage return
lf equ 0ah                        ; line feed
tab equ 09h                       ; tab


printstring macro x               ; for display a string
    mov ah,09h
    mov dx,offset x
    int 21h 
endm
 
 
endl macro                        ; for display a newline
    mov ah,09h
    mov dx,offset nl
    int 21h 
endm    

return macro x                    ; name says everything :p
    mov ax, 4ch 
    mov al, x
    int 21h
endm 

cin macro x                        ; cin equiv :D
    call readnum
    mov ax,num
    mov x,ax    
endm

cout macro x                       ; cout equiv :D
    mov ax,x
    mov num,ax
    call printnum
endm 


anykey macro                       ; For displaying any key to continue
    printstring anyk
    mov ah,08h
    int 21h
endm    

;;;;;:::;;;;;;****  Macros end Here    ****;;;;;;;;;;;;;;;;;;;;;;

_data segment
    num dw ?                          ; for readnum 
    tem1 db 80 dup("$")               ; for readnum
    tem2 db 80 dup("$")               ; for readstring
    tem3 db 80 dup("$")               ; for printnum
    nl db cr,lf,"$"                   ; for printing a newline
    
      
      
    ; editable data                                     
    name1 db "MR. Nishatul Majid$"    ; Name of the account holder      
    pin db "4372",cr                  ; pin of the account
    balance dw 12315                  ; current balance of the user
    
     
     
    ; Do not modify. 
    t dw 0
    inp dw ?
    amount dw ?
    anyk db "Press any button to continue....." ,cr,lf,cr,lf,cr,lf,cr,lf,"$" 
    msg1 db "Please insert your card and enter the pin code: $" 
    msg2 db "Your Card is locked.Contact your bank for further assistance.$"
    msg3 db "Wrong pin. Try again: $"  
    msg4 db "Welcome $"
    msg5 db ",$"
    msg6 db "Choose your options: ",cr,lf,cr,lf,"1. Withdraw",cr,lf,"2. Deposit",cr,lf,"3. Balance Check",cr,lf,"4. Balance Transfer",cr,lf,"5. Exit$"
    msg7 db cr,lf,cr,lf,"You have $"
    msg8 db " BDT in your account at the moment" ,cr,lf,cr,lf,"$"  
    msg9 db cr,lf,cr,lf,"Enter a multiple of 500: $"
    msg10 db cr,lf,cr,lf,"Sorry.You do not have $"
    msg11 db " BDT in your account at the moment",cr,lf,cr,lf,"$" 
    msg12 db cr,lf,cr,lf,"You did not enter a multiple of 500",cr,lf,cr,lf,"$" 
    msg13 db cr,lf,cr,lf,"Transaction Successful. Please take your money from the cash out box.",cr,lf,cr,lf,"$"  
    msg14 db cr,lf,cr,lf,"You Pressed a Wrong button",cr,lf,cr,lf,"$"  
    msg15 db cr,lf,cr,lf,"Enter a multiple of 500 and deposit the money : $"
    msg16 db cr,lf,cr,lf,"Transaction Successful.",cr,lf,cr,lf,"$"
    msg17 db cr,lf,cr,lf,"Do you want a receipt?",cr,lf,cr,lf,"1. Yes",cr,lf,"2. No$"
    msg18 db cr,lf,cr,lf,"Thank You.Have a nice day.",cr,lf,cr,lf,"$"
    msg19 db cr,lf,cr,lf,"Please take your receipt and Have a nice day.",cr,lf,cr,lf,"$"
    msg20 db cr,lf,cr,lf,"Press the corresponding button: $"
    msg21 db cr,lf,cr,lf,"Enter the amount you want to transfer: $"
    msg22 db cr,lf,cr,lf,"Enter 12 digit account number of the reciever: $"  
    msg23 db cr,lf,cr,lf,"You entered an invalid account number$"
    msg24 db cr,lf,cr,lf,"successfully transferred $"
    msg25 db " BDT to account number $"    
_data ends


 
_code segment 
    assume cs:_code , ds:_data
start:

    mov ax, _data
    mov ds, ax
    
;;;;;;;;;;;****  Main Code start    ****;;;;;;;;;;

    
    
    printstring msg1
    
    
    pincheck:                        ; Section for pin verification
        call readstring 
        endl    
        mov si,offset tem2
        mov di,offset pin
    pass:    
        mov al,[si]
        cmp al,[di]
        jne wrong
        inc si
        inc di
        cmp al,cr
        jne pass
        je options
             
    wrong:    
        inc t
        cmp t,3
        je locked
        endl
        printstring msg3
        jmp pincheck    
    
    
    locked:                         ; When the card is locked    
        endl
        printstring msg2
        return 0         
        
        
    options:                        ; After successfully entering the pin    
        endl
        printstring msg4 
        printstring name1
        printstring msg5
    
    rpt:
        printstring msg6
        printstring msg20      
        cin inp
        cmp inp,3
        je chkbalance
        cmp inp,1
        je withd
        cmp inp,2
        je dip
        cmp inp,4
        je btr
        cmp inp,5
        je last
        printstring msg14
        anykey
        jmp rpt
    
    chkbalance:                       ; For checking the balance
        printstring msg7
        cout balance
        printstring msg8
        anykey
        jmp rpt       
    
    withd:                            ; For withdraw options
        printstring msg9
        cin amount
        mov ax,amount
        cmp ax,balance
        jg withdsorry
        mov ax,amount
        mov dx,0
        mov bx,500
        div bx
        cmp dx,0
        je withdsuccess
        jne withdfail
    
        
    withdsorry:
        printstring msg10
        cout amount
        printstring msg11
        anykey
        jmp rpt    
    
    withdfail: 
        printstring msg12
        anykey
        jmp rpt
        
    withdsuccess:
        mov ax,balance
        sub ax,amount
        mov balance,ax
        printstring msg13
        anykey
        jmp rpt
                
   
   
   
   dip:                                 ; For deposit options
        printstring msg15
        cin amount
        mov dx,0
        mov bx,500
        div bx
        cmp dx,0
        je  dipsuccess
        jne withdfail 
    
    dipsuccess:
        mov ax,balance
        add ax,amount
        mov balance,ax
        printstring msg16
        anykey
        jmp rpt 
    
    btr:                                    ; Balance Transfer Options
        printstring msg21
        cin amount
        mov ax,amount
        cmp ax,balance
        jg withdsorry
        printstring msg22
        call len                             ; it will input a string and store its size in num
        endl
        cmp num,12
        jne btrfail
        printstring msg24
        cout amount
        printstring msg25
        printstring tem2 
        mov ax,balance
        sub ax,amount
        mov balance,ax
        endl
        endl
        anykey
        jmp rpt    
    
    btrfail:
        printstring msg23
        endl
        endl
        anykey
        jmp rpt
        
    last:                                   ; For Receipt
        printstring msg17
        printstring msg20
        cin inp
        cmp inp,2
        je last1
        printstring msg19
        return 0
    
    last1:
        printstring msg18                   
    return 0  
    
 
 
 

;;;;;;;;;;;;;;;****  Main Code ends    ****;;;;;;;;;;;;;;;;;;;




 

readnum proc near    ; The number will be saved in 'num' variable 
    
    pusha
    mov si, offset tem1  
    rdchar1:
        mov ah,01h
        int 21h  
        mov [si],al
        inc si
        cmp al,cr
        jne rdchar1
        dec si                 ; input a string
        mov [si],"$"
    
    mov num,0
    mov si,offset tem1
    mov ax,0 
     
    rdnxt:
        mov ah,0    
        mov al,[si]
        inc si
        cmp al,"$"
        je skip 
        
        push ax
        mov ax,num
        mov bx,0ah
        mul bx
        mov num,ax 
        pop ax
        sub ax,'0'
        add ax,num
        mov num,ax 
        
        jmp rdnxt
    
    skip:
        popa 
        ret  
readnum endp    


 
printnum proc near                 ; hex2asc equiv of Venugopal book.slightly modified
    
    pusha  
    
    mov si,offset tem3             ; It will print the number stored in num varialbe
    mov ax,num
    mov bx,10
    mov cx,0
    pnum1:
        mov dx,0
        div bx
        add dx,'0'
        push dx 
        inc cx
        cmp ax,0
        jz pnum2
        jmp pnum1
    pnum2:
        pop ax
        mov [si],al
        inc si
        loop pnum2
         
        mov [si],'$'
        printstring tem3              
            
    popa  
    ret
printnum endp 
 
 
readstring proc near              ; The string will be saved in tem2 variable
    pusha
    mov si, offset tem2  
    rdchar:
        mov ah,01h
        int 21h  
        mov [si],al
        inc si
        cmp al,cr
        jne rdchar                 ; input a string 
        mov [si],"$"
    popa               
    ret
readstring endp    

len proc near
    pusha
    call readstring 
    mov si,offset tem2
    mov cx,0
    len1:
        cmp [si],cr
        je len2
        inc cx
        inc si
        jmp len1
    len2:
        mov num,cx
    popa
    ret
len endp            
      
_code ends

end start 
    
    
 