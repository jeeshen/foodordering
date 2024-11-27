.model small
.stack 100

displayNumber8 macro value
    local a,b,skipPrintSpace
    cmp value,9
    jg skipPrintSpace
    mov dl,' '
    mov ah,02h
    int 21h

    skipPrintSpace:
    xor ah,ah
    mov al,value
    mov bx,10
    xor cx,cx
    a:
    xor dx,dx
    div bx
    push dx
    inc cx
    test ax,ax
    jnz a
    b:
    pop dx
    add dl,48
    mov ah,02h
    int 21h
    loop b
endm

displayDecimal8 macro value
    local a,b,printZero,end,canPrintZero
    xor ah,ah
    mov al,value
    mov bx,10
    xor cx,cx
    a:
    xor dx,dx
    div bx
    push dx
    inc cx
    test ax,ax
    jnz a
    mov bh,0
    b:
    pop dx
    mov bl,dl
    add dl,48
    mov ah,02h
    int 21h
    inc bh
    loop b
    cmp bh,1
    je canPrintZero
    jmp end
    
    canPrintZero: 
    cmp bl,0
    je printZero
    jmp end
    
    printZero:
    mov dl,'0'
    mov ah,02h
    int 21h
    
    end:
endm


displayNumber macro value
    local a,b
    mov ax,value
    mov bx,10
    xor cx,cx
    a:
    xor dx,dx
    div bx
    push dx
    inc cx
    test ax,ax
    jnz a
    b:
    pop dx
    add dl,48
    mov ah,02h
    int 21h
    loop b
endm

displayDecimal macro value
    local a, b, printZero, end
    mov ax, value
    mov bx, 10
    xor cx, cx
    a:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz a
    
    cmp cx, 1
    jne b

    mov dl, '0'
    mov ah, 02h
    int 21h
    
    b:
    pop dx
    add dl, 48
    mov ah, 02h
    int 21h
    loop b
    
    end:
endm

calculateTotal macro foodPrice,foodCentPrice
    local moreThan100,end
    mov ax,foodSelect
    xor bx,bx
    mov bl, 2
    div bl
    mov si,ax
    mov al,foodPrice[si]
    mov bx,tempCount
    mul bx
    add totalPayment,ax
    
    xor ah,ah
    mov al,foodCentPrice[si]
    mov bx,tempCount
    mul bx
    
    add totalPaymentCent,ax
    cmp totalPaymentCent,100
    jge moreThan100
    jmp end
    
    moreThan100:
    mov ax,totalPaymentCent
    mov bl,100
    div bl
    mov bl,ah
    xor ah,ah
    add totalPayment, ax

    xor ah,ah
    mov al,bl 
    mov totalPaymentCent,ax
    end:
endm

calculateTotalCart macro count, price, priceCent
    local moreThan100,end
    xor ax,ax
    xor dx,dx
    xor bx,bx
    mov al,price
    mov bx,count
    mul bx
    add totalPayment,ax
    
    xor ah,ah
    mov al,priceCent
    mov bx,count
    mul bx
    
    add totalPaymentCent,ax
    cmp totalPaymentCent,100
    jge moreThan100
    jmp end
    
    moreThan100:
    mov ax,totalPaymentCent
    mov bl,100
    div bl
    mov bl,ah
    xor ah,ah
    add totalPayment, ax

    xor ah,ah
    mov al,bl 
    mov totalPaymentCent,ax
    end:
endm

calculateSubtotal macro count, price, priceCent
    local moreThan100,end
    xor ax,ax
    xor dx,dx
    xor bx,bx
    mov al,price
    mov bx,count
    mul bx
    mov subtotal,ax
    
    xor ah,ah
    mov al,priceCent
    mov bx,count
    mul bx
    
    mov subtotalCent,ax
    cmp subtotalCent,100
    jge moreThan100
    jmp end
    
    moreThan100:
    mov ax,subtotalCent
    mov bl,100
    div bl
    mov bl,ah
    xor ah,ah
    add subtotal, ax

    xor ah,ah
    mov al,bl 
    mov subtotalCent,ax
    end:
endm

printCart macro count, nextLabel, name, price, priceCent, stock
    local jmpToAnotherCart, nextPrint,skipAddingSpace, skipAddingSpace2
    
    cmp count,0
    je jmpToAnotherCart
  
    inc totalCart

    lea dx,cart3
    mov ah,09h
    int 21h
    
    xor dh,dh
    displayNumber cartNumber
    mov dl,'.'
    int 21h
    mov dl,' '
    int 21h
    cmp cartNumber,9
    jg skipAddingSpace
    mov dl,' '
    int 21h
    skipAddingSpace:
    inc cartNumber
    
    lea dx,name
    mov ah,09h
    int 21h

    printSpace name, 28

    jmp nextPrint

    jmpToAnotherCart:
    jmp nextLabel

    nextPrint:
    lea dx,rm
    mov ah,09h   
    int 21h
    
    displayNumber8 price
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal8 priceCent
    
    lea dx,multiply
    mov ah,09h
    int 21h
    
    cmp count,9
    jg skipAddingSpace2
    mov dl,' '
    mov ah,02h
    int 21h
    skipAddingSpace2:
    displayNumber count
    
    lea dx,equal
    mov ah,09h
    int 21h
    
    printSpace2 subtotal
    displayNumber subtotal
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal subtotalCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    mov si,cartNumber
    sub si,2
    shl si,1
    
    lea bx, [count]
    mov orderLocation[si],bx
    
    lea bx, [stock]
    mov stockLocation[si],bx
endm

calculateServiceCharge macro
    local moreThan100, canAddOne, done
    xor dx,dx
    mov ax,totalPayment
    mov bx,10
    div bx

    mov serviceCharge,ax
    mov ax,dx
    mov bx,10
    mul bx
    mov serviceChargeCent, ax

    mov ax,totalPaymentCent
    mov bx,10
    div bx
    add serviceChargeCent,ax
    
    cmp serviceChargeCent,100
    jb done
    sub serviceChargeCent,100
    inc serviceCharge
    done:
    mov ax,serviceCharge
    add checkoutPayment,ax
    mov ax,serviceChargeCent
    add checkoutPaymentCent,ax
endm

calculateGST macro
    xor dx,dx
    mov ax,totalPayment
    mov bx,6
    mul bx

    mov bx,100
    div bx

    mov cx,dx
    mov gst,ax

    mov ax,dx
    mov bx,10
    mul bx
    mov gstCent,ax
    
    mov ax,totalPaymentCent
    mov bx,6
    mul bx
    
    mov bx,10
    div bx
    
    add gstCent,ax
    
    cmp gstCent,100
    jb done
    mov ax,gstCent
    mov bl,10
    div bl
    mov cl,ah
    xor ah,ah
    mov gstCent,ax
    cmp cl,5
    jb done
    inc gstCent
    done:
    mov ax,gst
    add checkoutPayment,ax
    mov ax,gstCent
    add checkoutPaymentCent,ax 
endm

rounding macro
    local skipRound, done
    mov ax,totalPayment
    add checkoutPayment,ax
    mov ax,totalPaymentCent
    add checkoutPaymentCent,ax

    mov ax,checkoutPaymentCent
    mov bl,10
    div bl
    xor bx,bx
    
    ;check if can round 
    mov bl,10
    sub bl,ah
    cmp bl,10
    je skipRound
    xor bh,bh
    mov roundUp,bx
    add checkoutPaymentCent,bx
    skipRound:
    cmp checkoutPaymentCent,100
    jb done
    mov ax,checkoutPaymentCent
    mov bl,100
    div bl
    xor cx,cx
    mov cl,al
    mov al,ah
    xor ah,ah
    mov checkoutPaymentCent,ax
    add checkoutPayment,cx
    done:
endm

resetCount macro count,sold
    local a
    mov cx,4
    lea si,count
    lea di,sold
    a:
    mov ax,[si]
    add word ptr[di],ax
    mov word ptr [si],0
    add si,2
    add di,2
    loop a    
endm

logOutResetCount macro count,stock
    local a
    mov cx,4
    lea si,count
    lea di,stock
    a:
    mov ax,[si]
    add word ptr[di],ax
    mov word ptr [si],0
    add si,2
    add di,2
    loop a    
endm

checkCent macro integer,cent
    local notOver100
    cmp cent,100
    jbe notOver100
    xor dx,dx
    mov ax,cent
    mov bx,100
    div bx
    add integer,ax
    mov cent,dx
    
    notOver100:
    displayNumber integer
    mov dl,'.'
    mov ah,02h
    int 21h
    displayDecimal cent
endm 

printSales macro sold,name,price,priceCent
    local moreThan100,end
    lea dx,cart3
    mov ah,09h
    int 21h
    
    lea dx,name
    int 21h
    
    lea dx,multiply
    int 21h
    
    displayNumber sold
    
    lea dx,equal
    mov ah,09h
    int 21h
        
    xor ax,ax
    xor dx,dx
    xor bx,bx
    mov al,price
    mov bx,sold
    mul bx
    mov tempEachSales,ax
    
    xor ah,ah 
    xor dx,dx
    mov al,priceCent
    mov bx,sold
    mul bx
    
    mov tempEachSalesCent,ax
    cmp tempEachSalesCent,100
    jge moreThan100
    jmp end
    
    moreThan100:
    mov ax,tempEachSalesCent
    mov bl,100
    div bl
    mov bl,ah
    xor ah,ah
    add tempEachSales, ax

    xor ah,ah
    mov al,bl 
    mov tempEachSalesCent,ax
    end:
    
    displayNumber tempEachSales
    mov dl,'.'
    mov ah,02h
    int 21h
    displayDecimal tempEachSalesCent 
    
    mov ax,tempEachSales
    add tempSales,ax
    mov ax,tempEachSalesCent
    add tempSalesCent,ax
    
    lea dx,new
    mov ah,09h
    int 21h      
endm

checkID macro toCheck, reference, nextLabel, errorLabel
    local CompareNameLoop
    lea si,toCheck + 2
    lea di,reference
    xor ch,ch
    mov cl,toCheck + 1
    CompareNameLoop: 
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne nextLabel
    inc si
    inc di
    loop CompareNameLoop 
    jmp errorLabel
endm

checkID2 macro toCheck, reference, nextLabel, errorLabel
    local CompareNameLoop
    cmp [toCheck + 2], '$'
    je nextLabel
    lea si,toCheck + 2
    lea di,reference + 2
    xor ch,ch
    mov cl,toCheck + 1
    CompareNameLoop: 
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne nextLabel
    inc si
    inc di
    loop CompareNameLoop 
    jmp errorLabel
endm

staffLoginCheck macro
    local compareNameLoop, compareStaff1, compareStaff2, pwError, pwError2, loginError, continueCheckStaff
    mov al, StaffLogin + 1
    mov bl, 3
    cmp al, bl
    jne CompareStaff1
    
    lea si, staffID
    lea di, StaffLogin + 2
    xor ch, ch
    mov cl, StaffLogin + 1
    CompareNameLoop1:
    mov al,[si]
    mov bl,[di]
    cmp al, bl
    jne CompareStaff1
    inc si
    inc di
    loop CompareNameLoop1
    jmp continueCheckStaff

    PwError:
    lea dx, login8
    mov ah, 09h
    int 21h
    jmp loginStaff

    continueCheckStaff:
    lea dx, login5
    mov ah, 09h
    int 21h
    
    xor cx,cx
    lea di,staffLoginPw

    enterStaffPW1:
    mov ah,00h
    int 16h

    cmp al,0Dh
    je doneEnterStaffPW1

    mov [di],al
    inc di
    inc cx

    mov ah,0Eh
    mov al,'*'
    int 10h

    cmp cx,50
    jne enterStaffPW1

    doneEnterStaffPW1:
    cmp cl,1
    jne continueCheckStaffPassword1
    mov dl,[staffLoginPW+0]
    cmp dl,'0'
    jne continueCheckStaffPassword1
    call login
    continueCheckStaffPassword1:
    lea si, staffPw
    lea di, staffLoginPw
    xor ch,ch
    cmp cl,3
    jne PwError
    ComparePwLoop1:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne PwError
    inc si
    inc di
    loop ComparePwLoop1
    jmp successLoginStaff
    
    CompareStaff1:
    mov al, StaffLogin + 1
    mov bl, newstaffId1 + 1
    cmp al, bl
    jne CompareStaff2
    
    lea si, newstaffId1 + 2
    lea di, StaffLogin + 2
    xor ch, ch
    mov cl, StaffLogin + 1
    
    CompareNameLoop2:
    mov al,[si]
    mov bl,[di]
    cmp al, bl
    jne CompareStaff2
    inc si
    inc di
    loop CompareNameLoop2
    
    lea dx, login5
    mov ah, 09h
    int 21h
    
    xor cx,cx
    lea di,staffLoginPw
    enterStaffPW2:
    mov ah,00h
    int 16h

    cmp al,0Dh
    je doneEnterStaffPW2

    mov [di],al
    inc di
    inc cx

    mov ah,0Eh
    mov al,'*'
    int 10h

    cmp cx,50
    jne enterStaffPW2

    doneEnterStaffPW2:
    cmp cl,1
    jne continueCheckStaffPassword2
    mov dl,[staffLoginPW+0]
    cmp dl,'0'
    jne continueCheckStaffPassword2
    call login
    continueCheckStaffPassword2:
    lea si, newStaffPw1 + 2
    lea di, staffLoginPw
    xor ch,ch
    mov dl, newStaffPw1 + 1
    cmp cl,dl
    jne PwError2
    ComparePwLoop2:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne PwError2
    inc si
    inc di
    loop ComparePwLoop2
    jmp SuccessLoginStaff

    PwError2:
    lea dx, login8
    mov ah, 09h
    int 21h
    jmp loginStaff

    CompareStaff2:
    mov al, staffLogin + 1
    mov bl, newStaffID2 + 1
    cmp al, bl
    jne LoginError
    
    lea si, newStaffID2 + 2
    lea di, staffLogin + 2
    xor ch, ch
    mov cl, staffLogin + 1
    CompareNameLoop3:
    mov al,[si]
    mov bl,[di]
    cmp al, bl
    jne LoginError
    inc si
    inc di
    loop CompareNameLoop3
    
    lea dx, login5
    mov ah, 09h
    int 21h
    
    xor cx,cx
    lea di,staffLoginPw
    enterStaffPW3:
    mov ah,00h
    int 16h

    cmp al,0Dh
    je doneEnterStaffPW3

    mov [di],al
    inc di
    inc cx

    mov ah,0Eh
    mov al,'*'
    int 10h

    cmp cx,50
    jne enterStaffPW3

    doneEnterStaffPW3:
    cmp cl,1
    jne continueCheckStaffPassword3
    mov dl,[staffLoginPW+0]
    cmp dl,'0'
    jne continueCheckStaffPassword3
    call login
    continueCheckStaffPassword3:
    lea si, newStaffPw2 + 2
    lea di, staffLoginPw
    xor ch,ch
    mov dl, newStaffPw2 + 1
    cmp cl,dl
    jne PwError2
    ComparePwLoop3:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne PwError2
    inc si
    inc di
    loop ComparePwLoop3
    jmp SuccessLoginStaff

    LoginError:
    lea dx, login7
    mov ah, 09h
    int 21h
    jmp loginStaff
endm

memberLoginCheck Macro
    local CompareNameLoop4, CompareMember1, CompareMember2, MemberPwError, MemberLoginError, continueCheckMember
    mov al, MemberLogin + 1
    mov bl, 3
    cmp al, bl
    jne CompareMember1
    
    lea si, memberID
    lea di, MemberLogin + 2
    xor ch, ch
    mov cl, MemberLogin + 1
    CompareNameLoop4:
    mov al,[si]
    mov bl,[di]
    cmp al, bl
    jne CompareMember1
    inc si
    inc di
    loop CompareNameLoop4
    jmp continueCheckMember

    MemberPwError:
    lea dx, login8
    mov ah, 09h
    int 21h
    jmp loginMember

    continueCheckMember:
    lea dx, login5
    mov ah, 09h
    int 21h
    
    xor cx,cx
    lea di,memberLoginPW

    enterMemberPw1:
    mov ah,00h
    int 16h

    cmp al,0Dh
    je doneEnterMemberPW1

    mov [di],al
    inc di
    inc cx

    mov ah,0Eh
    mov al,'*'
    int 10h

    cmp cx,50
    jne enterMemberPw1

    doneEnterMemberPW1:
    cmp cl,1
    jne continueCheckMemberPassword1
    mov dl,[memberLoginPw+0]
    cmp dl,'0'
    jne continueCheckMemberPassword1
    call login
    continueCheckMemberPassword1:
    lea si, memberPw
    lea di, memberLoginPw
    cmp cl,3
    jne MemberPwError
    ComparePwLoop4:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne MemberPwError
    inc si
    inc di
    loop ComparePwLoop4
    jmp SuccessLoginMember
    
    CompareMember1:
    mov al, memberLogin + 1
    mov bl, newUserID1 + 1
    cmp al, bl
    jne CompareMember2
    
    lea si, newUserID1 + 2
    lea di, memberLogin + 2
    xor ch, ch
    mov cl, memberLogin + 1

    CompareNameLoop5:
    mov al,[si]
    mov bl,[di]
    cmp al, bl
    jne CompareMember2
    inc si
    inc di
    loop CompareNameLoop5
    
    lea dx, login5
    mov ah, 09h
    int 21h
    
    xor cx,cx
    lea di,memberLoginPW
    enterMemberPw2:
    mov ah,00h
    int 16h

    cmp al,0Dh
    je doneEnterMemberPW2

    mov [di],al
    inc di
    inc cx

    mov ah,0Eh
    mov al,'*'
    int 10h

    cmp cx,50
    jne enterMemberPw2

    doneEnterMemberPW2:
    cmp cl,1
    jne continueCheckMemberPassword2
    mov dl,[memberLoginPw+0]
    cmp dl,'0'
    jne continueCheckMemberPassword2
    call login
    continueCheckMemberPassword2:
    lea si, newUserPw1 + 2
    lea di, memberLoginPw
    xor ch,ch
    mov dl, newUserPw1+1
    cmp cl,dl
    jne MemberPwError2
    ComparePwLoop5:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne MemberPwError2
    inc si
    inc di
    loop ComparePwLoop5
    jmp successLoginMember
    
    MemberPwError2:
    lea dx, login8
    mov ah, 09h
    int 21h
    jmp loginMember

    CompareMember2:
    mov al, memberLogin + 1
    mov bl, newUserID2 + 1
    cmp al, bl
    jne MemberLoginError
    
    lea si, newUserID2 + 2
    lea di, memberLogin + 2
    xor ch, ch
    mov cl, memberLogin + 1
    CompareNameLoop6:
    mov al,[si]
    mov bl,[di]
    cmp al, bl
    jne MemberLoginError
    inc si
    inc di
    loop CompareNameLoop6
    
    lea dx, login5
    mov ah, 09h
    int 21h
    
    xor cx,cx
    lea di,memberLoginPW
    enterMemberPw3:
    mov ah,00h
    int 16h

    cmp al,0Dh
    je doneEnterMemberPW3

    mov [di],al
    inc di
    inc cx

    mov ah,0Eh
    mov al,'*'
    int 10h

    cmp cx,50
    jne enterMemberPw3

    doneEnterMemberPW3:
    cmp cl,1
    jne continueCheckMemberPassword3
    mov dl,[memberLoginPw+0]
    cmp dl,'0'
    jne continueCheckMemberPassword3
    call login
    continueCheckMemberPassword3:
    lea si, newUserPw2 + 2
    lea di, memberLoginPw
    xor ch,ch
    mov dl, newUserPw2 + 1
    cmp cl,dl
    jne MemberPwError2
    ComparePwLoop6:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne MemberPwError2
    inc si
    inc di
    loop ComparePwLoop6
    jmp SuccessLoginMember

    MemberLoginError:
    lea dx, login7
    mov ah, 09h
    int 21h
    jmp loginMember
endm

printSpace macro string, number
    local loop1, countLoop,endCount
    lea si,string
    xor cx,cx
    countLoop:
    mov al,[si]
    cmp al,'$'
    je endCount

    inc si
    inc cx
    jmp countLoop

    endCount:
    mov ax,cx
    mov cx,number
    sub cx,ax
    loop1:
    mov dl,' '
    mov ah,02h
    int 21h
    loop loop1
endm

printSpace2 macro number
    local fivedigit,fourdigit,threedigit,twodigit,onedigit
    cmp number,10000
    jge fivedigit
    cmp number,1000
    jge fourdigit
    cmp number,100
    jge threedigit
    cmp number,10
    jge twodigit
    cmp number,0
    jge onedigit
    
    onedigit:
    mov dl,' '
    mov ah,02h
    int 21h
    twodigit:
    mov dl,' '
    mov ah,02h
    int 21h
    threedigit:
    mov dl,' '
    mov ah,02h
    int 21h
    fourdigit:
    mov dl,' '
    mov ah,02h
    int 21h
    fivedigit:
endm
clearscreen macro
    mov ax, 3
    int 10h
endm

.data
;predefined login details
staffID db 'tew$'
staffPw db '123$'
memberID db 'jee$'
memberPw db '123$'

;empty account for registration
newStaffID1 db 50 dup('$') 
newStaffPw1 db 50 dup('$')
newStaffID2 db 50 dup('$')
newStaffPw2 db 50 dup('$')

newUserID1 db 50 dup('$')
newUserPw1 db 50 dup('$')
newUserID2 db 50 dup('$')
newUserPw2 db 50 dup('$')

currentStaffSlot db 1
currentMemberSlot db 1 

authentication1 db 'mambo$'
authentication2 db 20 dup('$') 

;user input
staffLogin db 50 dup('$')
staffLoginPw db 50 dup('$')
memberLogin db 50 dup('$')
memberLoginPw db 50 dup('$')
choice db ?
foodSelect dw ?
foodSelectCart dw ?
orderLocation dw 20 dup(?)
stockLocation dw 20 dup(?)
foodString dw ?
foodStock dw ?
cartNumber dw 0

;cart input
voucherEnter db 20 dup('$')
memberEnter db 20 dup('$')
voucher db 'discount5$'
membershipid db '2306093$'

;place to store item ordered
burgerCount dw 4 dup(0)
pizzaCount dw 4 dup(0)
wrapCount dw 4 dup(0)
drinkCount dw 4 dup(0)
dessertCount dw 4 dup(0)

;item stock
burgerStock dw 100,4000,4000,4000
pizzaStock dw 4000,4000,4000,4000
wrapStock dw 4000,4000,4000,4000
drinkStock dw 4000,4000,4000,4000
dessertStock dw 4000,4000,4000,4000

;total item sold
burgerSold dw 4 dup(0)
pizzaSold dw 4 dup(0)
wrapSold dw 4 dup(0)
drinkSold dw 4 dup(0)
dessertSold dw 4 dup(0)

;cart details
tempCount dw 0
tempTotal dw 0
totalPayment dw 0
totalPaymentCent dw 0
subtotal dw 0
subtotalCent dw 0
totalCart dw 0 

;checkout details
serviceCharge dw 0
serviceChargeCent dw 0
roundUp dw 0
gst dw 0
gstCent dw 0
checkoutPayment dw 0
checkoutPaymentCent dw 0
voucherDiscount dw 0
memberDiscount dw 0
userPayment dw 0
userPaymentCent dw 0
balance dw 0
balanceCent dw 0

;variables to convert multidigit
firstAddress dw ?
lenNum dw ?
baseNumber dw ?
power dw ?
num1 db 10 dup(?)
tempNum dw ?

;salesreport
totalSales dw 0
totalSalesCent dw 0
totalService dw 0
totalServiceCent dw 0
totalRound dw 0
totalRoundCent dw 0
totalOrder dw 0
totalCategory dw 0
totalCategoryCent dw 0
totalItem dw 0
totalItemCent dw 0
totalVoucher dw 0
totalMember dw 0
tempEachSales dw 0
tempEachSalesCent dw 0
tempSales dw 0
tempSalesCent dw 0
totalGst dw 0
totalGstCent dw 0

;printing
new db 10,13,'$'
main1 db 10,13,'  ______               _____                    _     _ $'
main2 db 10,13,' |  ____|             |  __ \                  | |   | |$'
main3 db 10,13,' | |__ ___  _   _ _ __| |  | | ___  _ __   __ _| | __| |$'
main4 db 10,13,' |  __/ _ \| | | | ''__| |  | |/ _ \| ''_ \ / _` | |/ _` |$'
main5 db 10,13,' | | | (_) | |_| | |  | |__| | (_) | | | | (_| | | (_| |$'
main6 db 10,13,' |_|  \___/ \__,_|_|  |_____/ \___/|_| |_|\__,_|_|\__,_|$'
main7 db 10,13,10,13,'    Welcome to FOURDONALD! Please select your choice to proceed.',10,13,'$'
main8 db 10,13,10,13,' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
main9 db 10,13,'    Member Menu:$'
main10 db 10,13,'    1. Order Food$'
main11 db 10,13,'    2. Sales Report$'
main12 db 10,13,'    2. Log Out$'
main13 db 10,13,'    3. Exit Program$'
main14 db 10,13,'    Enter your selection: $'
main15 db 10,13,'    Are you sure (Y/N)? $'
main16 db 10,13,'    Exiting the program....$'
main17 db 10,13,'    Enter quantity (1-99)(0-Exit): $'
main18 db 10,13,'    You have added $'
main19 db ' to your cart! ($'
main20 db 10,13,'    You have total of $'
main21 db ' items in your cart!$'
main22 db 10,13,'    Your cart has RM$'
main23 db ' worth of items!$'
main24 db 10,13,'    Press any key to continue$'
main25 db 10,13,'    Enter amount you wish to deduct (0-Exit): $'
main26 db ' stock left)$'

reg1 db 10,13,'    1. Register Account$'
reg2 db 10,13,'    1. Register as Staff$'
reg3 db 10,13,'    Enter Authentication Code (0 - Exit): $'
reg4 db 10,13,'    2. Register as Member$'
reg5 db 10,13,'    Enter new username (0 - Exit): $'
reg6 db 10,13,'    Enter new password (0 - Exit): $'
reg7 db 10,13,10,13,'    You have successfully registered!$'
reg8 db 10,13,'    Your Option:$'
reg9 db 10,13,'    Login As:$'
reg10 db 10,13,'    Register As:$'
reg11 db 10,13,'    3. Back To Main Menu$'

register1 db 10,13,'  ____            _     _            $'
register2 db 10,13,' |  _ \ ___  __ _(_)___| |_ ___ _ __ $'
register3 db 10,13,' | |_) / _ \/ _` | / __| __/ _ \ ''__|$'
register4 db 10,13,' |  _ <  __/ (_| | \__ \ ||  __/ |   $'
register5 db 10,13,' |_| \_\___|\__, |_|___/\__\___|_|   $'
register6 db 10,13,'            |___/                    $'
                                                  
login1 db 10,13,'    2. Login Account$'
login2 db 10,13,'    1. Login as Staff$'
login3 db 10,13,'    2. Login as Member$'
login4 db 10,13,'    Enter your username (0 - Exit): $'
login5 db 10,13,'    Enter your password (0 - Exit): $'
login6 db 10,13,'    Successfully logged in!$'
login7 db 10,13,'    No such username!$'
login8 db 10,13,'    Incorrect password!$'
login9 db 10,13,'  _                _       $'
login10 db 10,13,' | |    ___   ____(_)____  $'
login11 db 10,13,' | |   / _ \ / _  | |  _  \ $'
login12 db 10,13,' | |__| (_) | (_| | | | | |$'
login13 db 10,13,' |_____\___/ \__, |_|_| |_|$'
login14 db 10,13,'             |___/         $'

error1 db 10,13,'    Incorrect name!$'    
error2 db 10,13,'    Incorrect password!$'
error3 db 10,13,'    No such selection! Please enter again!$'
error4 db 10,13,'    Invalid quantity!$'
error5 db 10,13,'    You can only order below 100 foods at one time!$'
error6 db 10,13,'    You can only enter digits!$'
error7 db 10,13,'    Please enter a quantity to proceed!$'
error8 db 10,13,'    Invalid amount to deduct!$'
error9 db 10,13,'    This item is currently out of stock! (Current stock: $'
error10 db 10,13,'    Please select an option to proceed!$'
error11 db 10,13,'    Please add items before proceed to checkout! (Press any key to continue) $'
error12 db 10,13,'    Invalid voucher code!$'
error13 db 10,13,'    Invalid member ID!$'
error14 db 10,13,'    Your payment is too large (Max 5 digits)!$'
error15 db 10,13,'    Please enter your payment amount to proceed!$'
error16 db 10,13,'    You do not have enough to pay, please enter again!$'
error17 db 10,13,'    The registration for staff is full!$'
error18 db 10,13,'    Invalid authenication code!$'
error19 db 10,13,'    Username has been taken!$'
error20 db 10,13,'    The registration for member is full!$'
error21 db 10,13,'    You cannot deduct more than 100 foods at one time!$'
error22 db 10,13,'    You must enter something!$'

category1 db 10,13,' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
category2 db 10,13, '    Food Menu:$'
category3 db 10,13, '    1. Burgers$'
category4 db 10,13, '    2. Pizzas$'
category5 db 10,13, '    3. Wraps$'
category6 db 10,13, '    4. Drinks$'
category7 db 10,13, '    5. Desserts$'
category8 db 10,13, '    6. View Cart$'
category9 db 10,13, '    7. Back To Member Menu$'

burger1 db 10, 13, ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
burger2 db 10,13, '    Burgers: $'
burger3 db 10,13, '    1. Chicken Burger - RM10.30$'
burger4 db 10,13, '    2. Lamb Burger    - RM14.50$'
burger5 db 10,13, '    3. Beef Burger    - RM10.30$'
burger6 db 10,13, '    4. Cheese Burger  - RM12.50$'
burger7 db 10,13, '    5. Back To Food Category $'

pizza1 db 10,13, ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
pizza2 db 10,13, '    Pizzas: $'
pizza3 db 10,13, '    1. Pepperoni Pizza   - RM14.50$'
pizza4 db 10,13, '    2. Hawaiian Pizza    - RM14.50$'
pizza5 db 10,13, '    3. BBQ Chicken Pizza - RM14.50$'
pizza6 db 10,13, '    4. Mexican Pizza     - RM14.50$'
pizza7 db 10,13, '    5. Back To Food Category $'

wrap1 db 10,13, ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
wrap2 db 10,13, '    Wraps: $'
wrap3 db 10,13, '    1. Chicken Caesar Wrap  - RM11.50$'
wrap4 db 10,13, '    2. Buffalo Chicken Wrap - RM16.70$'
wrap5 db 10,13, '    3. Avocado Shrimp Wrap  - RM12.30$'
wrap6 db 10,13, '    4. Cheesy Tortilla Wrap - RM14.70$'
wrap7 db 10,13, '    5. Back To Food Category $'

drink1 db 10,13, ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
drink2 db 10,13, '    Drinks: $'
drink3 db 10,13, '    1. Coca-Cola    - RM3.20$'
drink4 db 10,13, '    2. Sprite       - RM3.20$'
drink5 db 10,13, '    3. Orange Juice - RM3.20$'
drink6 db 10,13, '    4. 100 Plus     - RM3.20$'
drink7 db 10,13, '    5. Back To Food Category $'   

dessert1 db 10,13, ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
dessert2 db 10,13, '    Desserts: $'
dessert3 db 10,13, '    1. Ice-Cream - RM3.00 $'
dessert4 db 10,13, '    2. Cake      - RM13.10$'
dessert5 db 10,13, '    3. Waffle    - RM4.00 $'
dessert6 db 10,13, '    4. Pie       - RM6.50 $'
dessert7 db 10,13, '    5. Back To Food Category  $'

cart1 db 10,13, ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
cart2 db 10,13, '    Your Cart: $'
cart3 db '    $'
cart4 db '.  Checkout$'
cart5 db '.  Back to Food Category $'
cart6 db 10,13, '    Total in Cart: RM$'
cart7 db 10,13, '    Note: Select the number next to the food item to adjust the amount!$'
cart8 db 10,13,10,13,'    Other Option:$'
cart9 db 10,13,'    No food in cart! Go add them now!$'

checkout1 db 10,13, ' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
checkout2 db 10,13,'    Are you sure to proceed to checkout (Y/N)? $'
checkout3 db 10,13,'    Your Checkout List:$'
checkout4 db 10,13,'    $'
checkout5 db 10,13,'    1. Edit Cart$'
checkout6 db 10,13,'    2. Add More Item$'
checkout7 db 10,13,'    3. Confirm to Checkout$'
checkout8 db 10,13,'    Subtotal           :  RM$'
checkout9 db 10,13,'    10% Service Charge :  RM$'
checkout10 db 10,13,'    6% GST             :  RM$'
checkout11 db 10,13,'    Rounding Up        :  RM$'
checkout12 db 10,13,'    Total Payment      :  RM$'
checkout13 db '    $'
checkout14 db 10,13,'    Your Option:$'
checkout15 db 10,13,'    Do you wish to use voucher (Y/N)? $'
checkout16 db 10,13,'    Enter your voucher code (0-Cancel): $'
checkout17 db 10,13,'    Are you a member of FOURDONALD (Y/N)? $'
checkout18 db 10,13,'    Enter your member ID (0-Cancel): $'
checkout19 db 10,13,'    Enter your pay amount (RMXX.XX): RM$'
checkout20 db 10,13,'    Voucher Used       : -RM$'
checkout21 db 10,13,'    Member Discount    : -RM$'
checkout22 db 10,13,'    You have succesfully added RM5 discount voucher!$'
checkout23 db 10,13,'    You are qualified for member discount (RM3)!$'
checkout24 db 10,13,'    Final Payment      :  RM$'
checkout25 db 10,13,'    Paid Amount        :  RM$'
checkout26 db 10,13,'    Balance Amount     :  RM$'
checkout27 db 10,13,'    Thank you for supporting us!$'
checkout28 db 10,13,'    Press any key to continue next order$'
checkout29 db 10,13,'    Press any key to continue$'

salesReport1 db 10,13,' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
salesReport2 db 10,13,'    Total Sales: RM$'
salesReport3 db 10,13,'    Total Service Charged: RM$'
salesReport4 db 10,13,'    Total Rounding: RM$'
salesReport5 db 10,13,'    Total Discounted by Voucher: RM$'
salesReport6 db 10,13,'    Total Discounted by Membership: RM$'
salesReport7 db 10,13,'    Total Order Made: $'
salesReport8 db 10,13,'    Sales of Each Category:$'
salesReport9 db 10,13,'    1. Burgers$'
salesReport10 db 10,13,'    2. Pizzas$'
salesReport11 db 10,13,'    3. Wraps$'
salesReport12 db 10,13,'    4. Drinks$'
salesReport13 db 10,13,'    5. Desserts$'
salesReport14 db 10,13,'    Sales of Each Item:$'
salesReport15 db 10,13,'    Total Sales: RM$'
salesReport16 db 10,13,'    Sales Report Information:$'
salesReport17 db 10,13,'    6. Back to Staff Menu$'
salesReport18 db 10,13,'    Total GST Charged: RM$'

staffMenu1 db 10,13,'    Staff Menu:$'
staffMenu2 db 10,13,' * * * * * * * * * * * * * * * * * * * * * * * * * * * * *$'
staffMenu3 db 10,13,'    1. View Sales Report$'
staffMenu4 db 10,13,'    2. Log Out$'

burgern1 db 'Chicken Burger$'
burgern2 db 'Lamb Burger$'
burgern3 db 'Beef Burger$'
burgern4 db 'Cheese Burger$'

pizzan1 db  'Pepperoni Pizza$'
pizzan2 db  'Hawaiian Pizza$'
pizzan3 db  'BBQ Chicken Pizza$'
pizzan4 db  'Mexican Pizza$'

wrapn1 db  'Chicken Caesar Wrap$'
wrapn2 db  'Buffalo Shrimp Lettuce Wrap$'
wrapn3 db  'Avocado Shrimp Wrap$'
wrapn4 db  'Cheesy Tortilla Wrap$'

drinkn1 db  'Coca-Cola$'
drinkn2 db  'Sprite$'
drinkn3 db  'Orange Juice$'
drinkn4 db  '100 Plus$'

dessertn1 db  'Ice-Cream$'
dessertn2 db  'Cake$'
dessertn3 db  'Waffle$'
dessertn4 db  'Pie$'
       
multiply db ' x $'
rm db ' - RM$'
equal db ' = RM$'

;item price
burgerPrice db 10,14,10,12
pizzaPrice db 14,14,14,14
wrapPrice db 11,16,12,14
drinkPrice db 3,3,3,3
dessertPrice db 3,13,4,6

burgerCentPrice db 30,50,30,50
pizzaCentPrice db 50,50,50,50
wrapCentPrice db 50,70,30,70
drinkCentPrice db 20,20,20,20
dessertCentPrice db 0,10,0,50

.code
main proc
    mov ax, @data
    mov ds,ax    
    
    logo:
    clearscreen
    lea dx,main1
    mov ah,09h
    int 21h
    
    lea dx,main2
    int 21h
    
    lea dx,main3
    int 21h
    
    lea dx,main4
    int 21h
    
    lea dx,main5
    int 21h
    
    lea dx,main6
    int 21h
    
    lea dx,main7
    int 21h
    
    lea dx,reg8
    int 21h

    lea dx,reg1
    int 21h
    
    lea dx, login1
    int 21h
    
    lea dx, main13
    int 21h 
    
    lea dx, new
    int 21h 
    
    menuAsk:   
    lea dx, main14
    int 21h
    
    mov ah, 01h
    int 21h
    mov choice, al
    
    cmp choice, '1'
    je loginMenu_register
    cmp choice, '2'
    je loginMenu_login
    cmp choice, '3'
    je loginMenu_exit
    
    lea dx,error3
    mov ah, 09h
    int 21h    
    jmp menuAsk
    
    loginMenu_register:
    call register

    loginMenu_exit:
    call exit

    loginMenu_login:
    logOutResetCount burgerCount, burgerStock
    logOutResetCount pizzaCount, pizzaStock
    logOutResetCount wrapCount, wrapStock
    logOutResetCount drinkCount, drinkStock
    logOutResetCount dessertCount, dessertStock
    call login
main endp

register proc
    clearscreen
    lea dx,register1
    mov ah, 09h
    int 21h
    
    lea dx,register2
    int 21h
    
    lea dx,register3
    int 21h
    
    lea dx,register4
    int 21h
    
    lea dx,register5
    int 21h
    
    lea dx,register6
    int 21h

    lea dx,new
    int 21h
    
    lea dx,reg8
    int 21h

    lea dx, reg2
    int 21h
    
    lea dx, reg4
    int 21h
    
    lea dx, reg11
    int 21h
    
    lea dx, new
    int 21h
    
    registerAsk:    
    lea dx, main14
    mov ah,09h
    int 21h
    
    mov ah, 01h
    int 21h
    mov choice, al
    
    cmp choice, '1'
    je staffAuthentication
    cmp choice, '2'
    je register_memberRegister 
    cmp choice, '3'
    je register_logo

    lea dx, error18
    mov ah, 09h
    int 21h   
    jmp RegisterASK
    
    register_logo:
    jmp logo

    register_memberRegister:
    call memberRegister

    register_register:
    call register

    staffAuthentication:
    lea dx, reg3
    mov ah, 09h
    int 21h
    
    lea dx, authentication2
    mov ah, 0Ah
    int 21h
    
    mov dl,authentication2 + 1
    cmp dl,1
    jne continueAuthentication
    mov dl,[authentication2+2]
    cmp dl,'0'
    je register_register

    continueAuthentication:
    lea si, authentication1 
    lea di, authentication2 + 2
    mov cx, 5
    
    cmp authentication2 + 1, cl
    jne authFailed

    compareAuthenticationLoop:
    mov al, [si]       
    mov bl, [di]          
    cmp al, bl           
    jne authFailed             
    
    inc si              
    inc di           
    loop compareAuthenticationLoop
    jmp staffRegister    
    
    authFailed:
    lea dx, error18        
    mov ah, 09h
    int 21h
    jmp staffAuthentication            
            
    staffRegister:
    cmp currentStaffSlot, 1
    je registerNewStaff1
    cmp currentStaffSlot, 2
    je staffRegister_registerNewStaff2
    lea dx,error17
    mov ah,09h
    int 21h
    mov ah, 01h
    int 21h
    jmp logo
    
    staffRegister_registerNewStaff2:
    call registerNewStaff2

    registerNewStaff1:
    lea dx, reg5
    mov ah, 09h
    int 21h
    
    lea dx, newStaffID1
    mov ah, 0Ah           
    int 21h
    
    mov dl,newStaffID1 + 1
    cmp dl,1
    jne continueRegisterNewStaff1
    mov dl,[newStaffID1+2]
    cmp dl,'0'
    jne continueRegisterNewStaff1
    call register
    
    continueRegisterNewStaff1:
    checkid newStaffID1, staffID, q1, registerStaffError
    q1: 
    checkid newStaffID1, memberID, q2, registerStaffError
    q2:
    checkid2 newStaffID1, newUserID1, q3, registerStaffError
    q3:
    checkid2 newStaffID1, newUserID2, registerNewStaffPw1, registerStaffError
            
    registerNewStaffPw1:
    lea dx, reg6
    mov ah ,09h
    int 21h
        
    lea dx, newStaffPw1  
    mov ah, 0Ah          
    int 21h
    
    mov dl,newStaffPw1 + 1
    cmp dl,1
    jne continueEnterNewStaffPassword1
    mov dl,[newStaffPw1+2]
    cmp dl,'0'
    jne continueEnterNewStaffPassword1
    call register

    continueEnterNewStaffPassword1:
    inc currentStaffSlot
    jmp EndRegister
    
    registerStaffError:
    lea dx, error19
    mov ah, 09h
    int 21h
    jmp staffRegister
                
    endRegister:
    lea dx, reg7
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    jmp logo
register endp

memberRegister proc
    memberRegisterCompare:
    cmp currentMemberSlot, 1
    je registerNewMember1
    cmp currentMemberSlot, 2
    je memberRegister_registerNewMember2
    lea dx,error20
    mov ah,09h
    int 21h
    mov ah, 01h
    int 21h
    jmp logo

    memberRegister_registerNewMember2:
    call registerNewMember2

    registerNewMember1:
    lea dx, reg5
    mov ah, 09h
    int 21h
    
    lea dx, newUserID1
    mov ah, 0Ah           
    int 21h

    mov dl,newUserID1 + 1
    cmp dl,0
    jne skipPrintErrorMember
    lea dx, error22
    mov ah, 09h
    int 21h
    jmp memberRegister
    skipPrintErrorMember:
    cmp dl,1
    jne continueRegisterNewMember1
    mov dl,[newUserID1+2]
    cmp dl,'0'
    jne continueRegisterNewMember1
    call register
    
    continueRegisterNewMember1:
    checkid newUserID1, staffID, q8, RegisterMemberError
    q8:
    checkid newUserID1, memberID, q9, RegisterMemberError
    q9:
    checkid2 newUserID1, newStaffID1, q10, RegisterMemberError
    q10:
    checkid2 newUserID1, newStaffID2, registerNewMemberPw1, RegisterMemberError  

    registerNewMemberPw1:
    lea dx, reg6
    mov ah ,09h
    int 21h
        
    lea dx, newUserPw1  
    mov ah, 0Ah          
    int 21h
    
    mov dl,newUserPw1 + 1
    cmp dl,1
    jne continueEnterNewMemberPassword1
    mov dl,[newUserPw1+2]
    cmp dl,'0'
    jne continueEnterNewMemberPassword1
    call register

    continueEnterNewMemberPassword1:
    inc currentMemberSlot
    jmp endRegister

    registerMemberError:
    lea dx, error19
    mov ah, 09h
    int 21h
    jmp memberRegisterCompare
memberRegister endp

registerNewStaff2 proc
    lea dx, reg5
    mov ah, 09h
    int 21h
    
    lea dx, newStaffID2   
    mov ah, 0Ah           
    int 21h
    
    mov dl,newStaffID2 + 1
    cmp dl ,0
    jne skipPrintErrorStaff
    lea dx, error22
    mov ah, 09h
    int 21h
    jmp registerNewStaff2
    skipPrintErrorStaff:
    cmp dl,1
    jne continueRegisterNewStaff2
    mov dl,[newStaffID2+2]
    cmp dl,'0'
    jne continueRegisterNewStaff2
    call register
    
    continueRegisterNewStaff2:
    checkid newStaffID2, staffID, q4, registerStaffError
    q4: 
    checkid newStaffID2, memberID, q5, registerStaffError
    q5:
    checkid2 newStaffID2, newStaffID1, q6, registerStaffError
    q6:
    checkid2 newStaffID2, newUserID1, q7, registerStaffError
    q7:
    checkid2 newStaffID2, newUserID2, RegisterNewStaffPw2, registerStaffError
       
    registerNewStaffPw2:    
    lea dx, reg6
    mov ah ,09h
    int 21h
    
    lea dx, newStaffPw2  
    mov ah, 0Ah          
    int 21h
    
    mov dl,newStaffPw2 + 1
    cmp dl,1
    jne continueEnterNewStaffPassword2
    mov dl,[newStaffPw2+2]
    cmp dl,'0'
    jne continueEnterNewStaffPassword2
    call register

    continueEnterNewStaffPassword2:
    inc currentStaffSlot
    jmp EndRegister
registerNewStaff2 endp

registerNewMember2 proc
    lea dx, reg5
    mov ah, 09h
    int 21h
    
    lea dx, newUserID2
    mov ah, 0Ah           
    int 21h
    
    mov dl,newUserID2 + 1
    cmp dl,1
    jne continueRegisterNewMember2
    mov dl,[newUserID2+2]
    cmp dl,'0'
    jne continueRegisterNewMember2
    call register
    
    continueRegisterNewMember2:
    checkid newUserID2, staffID, q11, RegisterMemberError
    q11:
    checkid newUserID2, memberID, q12, RegisterMemberError
    q12:
    checkid2 newUserID2, newStaffID1, q13, RegisterMemberError
    q13:
    checkid2 newUserID2, newStaffID2, q14, RegisterMemberError
    q14:
    checkid2 newUserID2, newUserID1, registerNewMemberPw2, RegisterMemberError
    
    registerNewMemberPw2:
    lea dx, reg6
    mov ah ,09h
    int 21h
        
    lea dx, newUserPw2 
    mov ah, 0Ah          
    int 21h
    
    mov dl,newUserPw2 + 1
    cmp dl,1
    jne continueEnterNewMemberPassword2
    mov dl,[newUserPw2+2]
    cmp dl,'0'
    jne continueEnterNewMemberPassword2
    call register

    continueEnterNewMemberPassword2:
    inc currentMemberSlot
    jmp endRegister
registerNewMember2 endp

login proc
    clearscreen
    lea dx, login9
    mov ah, 09h
    int 21h
    
    lea dx, login10
    int 21h
    
    lea dx, login11
    int 21h
    
    lea dx, login12
    int 21h
    
    lea dx, login13
    int 21h
    
    lea dx, login14
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx, login2
    int 21h
    
    lea dx, login3
    int 21h
    
    lea dx, reg11
    int 21h
    
    lea dx, new
    int 21h
    
    loginAsk:  
    lea dx,main14
    int 21h
    
    mov ah, 01h
    int 21h
    mov choice, al
    
    cmp choice, '1'
    je loginStaff
    cmp choice, '2'
    je loginAsk_loginMember
    cmp choice, '3'
    je loginAsk_loginMenu
    
    lea dx, error3
    mov ah, 09h
    int 21h
    jmp loginAsk

    loginAsk_loginMenu:
    jmp logo

    loginAsk_loginMember:
    call loginMember

    loginStaff:
    lea dx, login4
    mov ah, 09h
    int 21h
    
    lea dx, staffLogin
    mov ah, 0ah
    int 21h

    mov dl,staffLogin+1
    cmp dl,1
    jne checkStaff
    mov dl,[staffLogin+2]
    cmp dl,'0'
    jne checkStaff
    call login

    checkStaff:  
    staffLoginCheck

    successLoginMember:
    lea dx, login6
    mov ah, 09h
    int 21h
    call mainMenu

    successLoginStaff:
    lea dx, login6
    mov ah, 09h
    int 21h
    call staffMenu
login endp

loginMember proc
    lea dx, login4
    mov ah, 09h
    int 21h
    
    lea dx, memberLogin
    mov ah, 0ah
    int 21h

    mov dl,memberLogin+1
    cmp dl,1
    jne checkMember
    mov dl,[memberLogin+2]
    cmp dl,'0'
    jne checkMember
    call login

    checkMember:  
    memberLoginCheck
loginMember endp

mainMenu proc
    clearscreen
    lea dx,main8
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,main9
    int 21h
    
    lea dx,main10
    int 21h
    
    lea dx,main12
    int 21h
    
    lea dx,main13
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,main8
    int 21h
    
    lea dx,new
    int 21h
    
    askMainMenu:
    lea dx,main14
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    je main_food
    cmp al,'2'
    je main_login
    cmp al,'3'
    je main_exit
    lea dx,error3
    mov ah,09h
    int 21h
    jmp askMainMenu
    
    main_food:
    call foodMenu
    
    main_sales:
    call salesReport
    
    main_login:
    jmp logo
    
    main_exit:
    call exit
mainMenu endp

foodMenu proc
    clearscreen
    lea dx,category1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,category2
    int 21h
    
    lea dx,category3
    int 21h
    
    lea dx,category4
    int 21h
    
    lea dx,category5
    int 21h
    
    lea dx,category6
    int 21h
    
    lea dx,category7
    int 21h
    
    lea dx,category8
    int 21h
    
    lea dx,category9
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,category1
    int 21h

    lea dx,new
    int 21h
    
    foodMenuAsk:
    lea dx,main14
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    je food_burger
    cmp al,'2'
    je food_pizza
    cmp al,'3'
    je food_wrap
    cmp al,'4'
    je food_drink 
    cmp al,'5'
    je food_dessert
    cmp al,'6'
    je food_cart
    cmp al,'7'
    je food_main

    lea dx,error3
    mov ah,09h
    int 21h
    jmp foodMenuAsk
    
    food_burger:
    call burger
    
    food_pizza:
    call pizza
    
    food_wrap:
    call wrap
    
    food_drink:
    call drink
    
    food_dessert:
    call dessert
    
    food_cart:
    call cart
    
    food_main:
    call mainMenu
    
foodMenu endp

burger proc
    clearscreen
 
    lea dx,burger1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,burger2
    int 21h
    
    lea dx,burger3
    int 21h
    
    lea dx,burger4
    int 21h
    
    lea dx,burger5
    int 21h
    
    lea dx,burger6
    int 21h
    
    lea dx,burger7
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,main22
    int 21h
    
    displayNumber totalPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal totalPaymentCent
    
    lea dx,main23
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,burger1
    int 21h

    lea dx,new
    int 21h
    
    cmp tempCount,0
    je burgerAsk
    
    call addToCartDetails
    
    burgerAsk:
    mov tempCount,0
    lea dx,main14
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    jb noChoiceBurger
    cmp al,'5'
    ja noChoiceBurger
    cmp al,'5'
    je burger_food
    
    xor ah,ah
    sub al,'1'
    shl al,1
    mov foodSelect,ax
    
    jmp burgerQty
    
    noChoiceBurger:
    lea dx,error3
    mov ah,09h
    int 21h
    jmp burgerAsk
    
    burgerQty:
    lea dx,main17
    mov ah,09h
    int 21h
    
    xor dx,dx
    lea si,num1
    call inputQtyBurger
    
    burgerConfirm:
    cmp [num1+0],0
    je burgerConfirmQty
    
    lea dx,main15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je burgerConfirmQty
    cmp al,'y'
    je burgerConfirmQty
    cmp al,'N'
    je burger_burger
    cmp al,'n'
    je burger_burger
    
    lea dx,error3
    int 21h
    jmp burgerConfirm
    
    burger_burger:
    call burger
    
    burger_food:
    call foodMenu
    
    burgerConfirmQty:
    lea si, num1
    call recombinerBurger
    
    calculateTotal burgerPrice,burgerCentPrice
    
    cmp foodSelect,0
    je burgerName1
    cmp foodSelect,2
    je burgerName2
    cmp foodSelect,4
    je burgerName3
    cmp foodSelect,6
    je burgerName4
    
    burgerName1:
    lea bx,[burgern1]
    mov [foodString],bx
    mov bx,burgerStock[0]
    mov foodStock,bx
    jmp burgerName5 
    
    burgerName2:
    lea bx,[burgern2]
    mov [foodString],bx
    mov bx,burgerStock[2]
    mov foodStock,bx
    jmp burgerName5
    
    burgerName3:
    lea bx,[burgern3]
    mov [foodString],bx
    mov bx,burgerStock[4]
    mov foodStock,bx
    jmp burgerName5
    
    burgerName4:
    lea bx,[burgern4]
    mov [foodString],bx
    mov bx,burgerStock[6]
    mov foodStock,bx
    
    burgerName5:
    jmp burgerEnd

    burgerEnd: 
    jmp burger

    burgerQtyWrong:
    lea dx,error5
    mov ah,09h
    int 21h
    jmp burgerQty
burger endp

powBurger proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroBurger
    powerLoopBurger:
    mul baseNumber
    loop powerLoopBurger
    jmp exitPowBurger
    powerZeroBurger:
    mov ax,1
    exitPowBurger:
    ret
powBurger endp

inputQtyBurger proc
    mov firstAddress,si
    mov cx,0
    
    loopEnterBurger:
    mov ah,01h
    int 21h
    cmp al,13
    je loopEndBurger
    inc cx
    cmp al,'0'
    jb invalidInputBurger
    cmp al,'9'
    ja invalidInputBurger
    cmp cx,2
    ja burgerQtyWrong
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterBurger
    
    loopEndBurger:
    cmp cx,0
    je burgerNoQty
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret

    burgerNoQty:
    lea dx,error7
    mov ah,09h
    int 21h
    jmp burgerQty

    invalidInputBurger:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp burgerQty

    noQtyBurger:
    lea dx,error4
    mov ah,09h
    int 21h
    jmp burgerQty
inputQtyBurger endp

recombinerBurger proc
    xor dx,dx    
    
    xor dx,dx
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberBurgerLoop:
    mov power,bx
    call powBurger
    mov power,0
    mov lenNum,0
    mov baseNumber,0
    mov firstAddress,0
    mov dl,[si]
    mov dh,0
    mul dx
    mov di,foodSelect
    add burgerCount[di],ax
    sub burgerStock[di],ax
    js negativeBurgerQty                        
    add tempCount, ax
    add tempTotal, ax
    dec bx
    inc si
    
    cmp bx,0
    jnl originalNumberBurgerLoop
    ret

    negativeBurgerQty:
    sub burgerCount[di],ax
    add burgerStock[di],ax
    lea dx,error9
    mov ah,09h
    int 21h
    displayNumber burgerStock[di]
    mov dl,')'
    mov ah,02h
    int 21h
    jmp burgerQty  
recombinerBurger endp

pizza proc
    clearscreen
 
    lea dx,pizza1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,pizza2
    int 21h
    
    lea dx,pizza3
    int 21h
    
    lea dx,pizza4
    int 21h
    
    lea dx,pizza5
    int 21h
    
    lea dx,pizza6
    int 21h
    
    lea dx,pizza7
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,main22
    int 21h
    
    displayNumber totalPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal totalPaymentCent
    
    lea dx,main23
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,pizza1
    int 21h

    lea dx,new
    int 21h
    
    cmp tempCount,0
    je pizzaAsk
    
    call addToCartDetails
    
    pizzaAsk:
    mov tempCount,0
    lea dx,main14
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    jb noChoicePizza
    cmp al,'5'
    ja noChoicePizza
    cmp al,'5'
    je pizza_food
    
    xor ah,ah
    sub al,'1'
    shl al,1
    mov foodSelect,ax
    jmp pizzaQty
    
    noChoicePizza:
    lea dx,error3
    mov ah,09h
    int 21h
    jmp pizzaAsk
    
    pizzaQty:
    lea dx,main17
    mov ah,09h
    int 21h
    
    xor dx,dx
    lea si,num1
    call inputQtyPizza
    
    pizzaConfirm:
    cmp [num1+0],0
    je pizzaConfirmQty
    
    lea dx,main15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je pizzaConfirmQty
    cmp al,'y'
    je pizzaConfirmQty
    cmp al,'N'
    je pizza_pizza
    cmp al,'n'
    je pizza_pizza
    
    lea dx,error3
    int 21h
    jmp pizzaConfirm
    
    pizza_pizza:
    call pizza
    
    pizza_food:
    call foodMenu
    
    pizzaConfirmQty:
    lea si, num1
    call recombinerPizza
    
    calculateTotal pizzaPrice,pizzaCentPrice
    
    cmp foodSelect,0
    je pizzaName1
    cmp foodSelect,2
    je pizzaName2
    cmp foodSelect,4
    je pizzaName3
    cmp foodSelect,6
    je pizzaName4
    
    pizzaName1:
    lea bx,[pizzan1]
    mov [foodString],bx
    mov bx,pizzaStock[0]
    mov foodStock,bx
    jmp pizzaName5 
    
    pizzaName2:
    lea bx,[pizzan2]
    mov [foodString],bx
    mov bx,pizzaStock[2]
    mov foodStock,bx
    jmp pizzaName5
    
    pizzaName3:
    lea bx,[pizzan3]
    mov [foodString],bx
    mov bx,pizzaStock[4]
    mov foodStock,bx
    jmp pizzaName5
    
    pizzaName4:
    lea bx,[pizzan4]
    mov [foodString],bx
    mov bx,pizzaStock[6]
    mov foodStock,bx
    
    pizzaName5:
    jmp pizzaEnd
    
    noQtyPizza:
    lea dx,error4
    mov ah,09h
    int 21h
    jmp pizzaQty
    
    pizzaEnd: 
    jmp pizza
    
    negativePizzaQty:
    sub pizzaCount[di],ax
    add pizzaStock[di],ax
    lea dx,error9
    mov ah,09h
    int 21h
    jmp pizzaQty    
pizza endp

recombinerPizza proc
    xor dx,dx    
    xor dx,dx
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberPizzaLoop:
    mov power,bx
    call powPizza
    mov power,0
    mov lenNum,0
    mov baseNumber,0
    mov firstAddress,0
    mov dl,[si]
    mov dh,0
    mul dx
    mov di,foodSelect
    add pizzaCount[di],ax
    sub pizzaStock[di],ax
    js negativePizzaQty                       
    add tempCount, ax
    add tempTotal, ax
    dec bx
    inc si
    
    cmp bx,0
    jnl originalNumberPizzaLoop
    ret

    pizzaQtyWrong:
    lea dx,error5
    mov ah,09h
    int 21h
    jmp pizzaQty
recombinerPizza endp

inputQtyPizza proc
    mov firstAddress,si
    mov cx,0
    
    loopEnterPizza:
    mov ah,01h
    int 21h
    cmp al,13
    je loopEndPizza
    inc cx
    cmp al,'0'
    jb invalidInputPizza
    cmp al,'9'
    ja invalidInputPizza
    cmp cx,2
    ja pizzaQtyWrong
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterPizza
    
    loopEndPizza:
    cmp cx,0
    je pizzaNoQty
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret

    invalidInputPizza:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp pizzaQty

    pizzaNoQty:
    lea dx,error7
    mov ah,09h
    int 21h
    jmp pizzaQty
inputQtyPizza endp

powPizza proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroPizza
    powerLoopPizza:
    mul baseNumber
    loop powerLoopPizza
    jmp exitPowPizza
    powerZeroPizza:
    mov ax,1
    exitPowPizza:
    ret
powPizza endp

wrap proc
    clearscreen
 
    lea dx,wrap1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,wrap2
    int 21h
    
    lea dx,wrap3
    int 21h
    
    lea dx,wrap4
    int 21h
    
    lea dx,wrap5
    int 21h
    
    lea dx,wrap6
    int 21h
    
    lea dx,wrap7
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,main22
    int 21h
    
    displayNumber totalPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal totalPaymentCent
    
    lea dx,main23
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,wrap1
    int 21h

    lea dx,new
    int 21h
    
    cmp tempCount,0
    je wrapAsk
    
    call addToCartDetails
    
    wrapAsk:
    mov tempCount,0
    lea dx,main14
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    jb noChoiceWrap
    cmp al,'5'
    ja noChoiceWrap
    cmp al,'5'
    je wrap_food
    
    xor ah,ah
    sub al,'1'
    shl al,1
    mov foodSelect,ax
    jmp wrapQty
    
    noChoiceWrap:
    lea dx,error3
    mov ah,09h
    int 21h
    jmp wrapAsk
    
    wrapQty:
    lea dx,main17
    mov ah,09h
    int 21h
    
    xor dx,dx
    lea si,num1
    call inputQtyWrap
    
    wrapConfirm:
    cmp [num1+0],0
    je wrapConfirmQty
    
    lea dx,main15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je wrapConfirmQty
    cmp al,'y'
    je wrapConfirmQty
    cmp al,'N'
    je wrap_wrap
    cmp al,'n'
    je wrap_wrap
    
    lea dx,error3
    int 21h
    jmp wrapConfirm
    
    wrap_wrap:
    call wrap
    
    wrap_food:
    call foodMenu
    
    wrapConfirmQty:
    lea si, num1
    call recombinerWrap
    
    calculateTotal wrapPrice,wrapCentPrice
    
    cmp foodSelect,0
    je wrapName1
    cmp foodSelect,2
    je wrapName2
    cmp foodSelect,4
    je wrapName3
    cmp foodSelect,6
    je wrapName4
    
    wrapName1:
    lea bx,[wrapn1]
    mov [foodString],bx
    mov bx,wrapStock[0]
    mov foodStock,bx
    jmp wrapName5 
    
    wrapName2:
    lea bx,[wrapn1]
    mov [foodString],bx
    mov bx,wrapStock[2]
    mov foodStock,bx
    jmp wrapName5
    
    wrapName3:
    lea bx,[wrapn1]
    mov [foodString],bx
    mov bx,wrapStock[4]
    mov foodStock,bx
    jmp wrapName5
    
    wrapName4:
    lea bx,[wrapn1]
    mov [foodString],bx
    mov bx,wrapStock[6]
    mov foodStock,bx
    
    wrapName5:
    jmp wrapEnd
    
    noQtyWrap:
    lea dx,error4
    mov ah,09h
    int 21h
    jmp wrapQty
    
    wrapQtyWrong:
    lea dx,error5
    mov ah,09h
    int 21h
    jmp wrapQty
    
    invalidInputWrap:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp wrapQty
    
    wrapNoQty:
    lea dx,error7
    mov ah,09h
    int 21h
    jmp wrapQty
    
    wrapEnd: 
    jmp wrap  
wrap endp

powWrap proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroWrap
    powerLoopWrap:
    mul baseNumber
    loop powerLoopWrap
    jmp exitPowWrap
    powerZeroWrap:
    mov ax,1
    exitPowWrap:
    ret
powWrap endp

inputQtyWrap proc
    mov firstAddress,si
    mov cx,0
    
    loopEnterWrap:
    mov ah,01h
    int 21h
    cmp al,13
    je loopEndWrap
    inc cx
    cmp al,'0'
    jb invalidInputWrap
    cmp al,'9'
    ja invalidInputWrap
    cmp cx,2
    ja wrapQtyWrong
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterWrap
    
    loopEndWrap:
    cmp cx,0
    je wrapNoQty
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret
inputQtyWrap endp

recombinerWrap proc
    xor dx,dx    
    xor dx,dx
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberWrapLoop:
    mov power,bx
    call powWrap
    mov power,0
    mov lenNum,0
    mov baseNumber,0
    mov firstAddress,0
    mov dl,[si]
    mov dh,0
    mul dx
    mov di,foodSelect
    add wrapCount[di], ax
    sub wrapStock[di],ax
    js negativeWrapQty                        
    add tempCount, ax
    add tempTotal, ax
    dec bx
    inc si
    
    cmp bx,0
    jnl originalNumberWrapLoop
    ret

    negativeWrapQty:
    sub wrapCount[di],ax
    add wrapStock[di],ax
    lea dx,error9
    mov ah,09h
    int 21h
    jmp wrapQty  
recombinerWrap endp

drink proc
    clearscreen
 
    lea dx,drink1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,drink2
    int 21h
    
    lea dx,drink3
    int 21h
    
    lea dx,drink4
    int 21h
    
    lea dx,drink5
    int 21h
    
    lea dx,drink6
    int 21h
    
    lea dx,drink7
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,main22
    int 21h
    
    displayNumber totalPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal totalPaymentCent
    
    lea dx,main23
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,drink1
    int 21h

    lea dx,new
    int 21h
    
    cmp tempCount,0
    je drinkAsk
    
    call addToCartDetails
    
    drinkAsk:
    mov tempCount,0
    lea dx,main14
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    jb noChoiceDrink
    cmp al,'5'
    ja noChoiceDrink
    cmp al,'5'
    je Drink_food
    
    xor ah,ah
    sub al,'1'
    shl al,1
    mov foodSelect,ax
    jmp drinkQty
    
    noChoiceDrink:
    lea dx,error3
    mov ah,09h
    int 21h
    jmp drinkAsk
    
    drinkQty:
    lea dx,main17
    mov ah,09h
    int 21h
    
    xor dx,dx
    lea si,num1
    call inputQtyDrink
    
    drinkConfirm:
    cmp [num1+0],0
    je drinkConfirmQty
    
    lea dx,main15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je drinkConfirmQty
    cmp al,'y'
    je drinkConfirmQty
    cmp al,'N'
    je drink_drink
    cmp al,'n'
    je drink_drink
    
    lea dx,error3
    int 21h
    jmp drinkConfirm
    
    drink_drink:
    call drink
    
    drink_food:
    call foodMenu
    
    drinkConfirmQty:
    lea si, num1
    call recombinerDrink
    
    calculateTotal drinkPrice,drinkCentPrice
    
    cmp foodSelect,0
    je drinkName1
    cmp foodSelect,2
    je drinkName2
    cmp foodSelect,4
    je drinkName3
    cmp foodSelect,6
    je drinkName4
    
    drinkName1:
    lea bx,[drinkn1]
    mov [foodString],bx
    mov bx,drinkStock[0]
    mov foodStock,bx
    jmp drinkName5 
    
    drinkName2:
    lea bx,[drinkn2]
    mov [foodString],bx
    mov bx,drinkStock[2]
    mov foodStock,bx
    jmp drinkName5
    
    drinkName3:
    lea bx,[drinkn3]
    mov [foodString],bx
    mov bx,drinkStock[4]
    mov foodStock,bx
    jmp drinkName5
    
    drinkName4:
    lea bx,[drinkn4]
    mov [foodString],bx
    mov bx,drinkStock[6]
    mov foodStock,bx
    
    drinkName5:
    jmp drinkEnd
    
    noQtyDrink:
    lea dx,error4
    mov ah,09h
    int 21h
    jmp drinkQty
    
    drinkQtyWrong:
    lea dx,error5
    mov ah,09h
    int 21h
    jmp drinkQty
    
    invalidInputDrink:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp drinkQty
    
    drinkNoQty:
    lea dx,error7
    mov ah,09h
    int 21h
    jmp drinkQty
    
    drinkEnd: 
    jmp drink  
drink endp

powDrink proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroDrink
    powerLoopDrink:
    mul baseNumber
    loop powerLoopDrink
    jmp exitPowDrink
    powerZeroDrink:
    mov ax,1
    exitPowDrink:
    ret
powDrink endp

inputQtyDrink proc
    mov firstAddress,si
    mov cx,0
    
    loopEnterDrink:
    mov ah,01h
    int 21h
    cmp al,13
    je loopEndDrink
    inc cx
    cmp al,'0'
    jb invalidInputDrink
    cmp al,'9'
    ja invalidInputDrink
    cmp cx,2
    ja drinkQtyWrong
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterDrink
    
    loopEndDrink:
    cmp cx,0
    je drinkNoQty
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret
inputQtyDrink endp

recombinerDrink proc
    xor dx,dx    
    
    xor dx,dx
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberDrinkLoop:
    mov power,bx
    call powDrink
    mov power,0
    mov lenNum,0
    mov baseNumber,0
    mov firstAddress,0
    mov dl,[si]
    mov dh,0
    mul dx
    mov di,foodSelect
    add drinkCount[di], ax
    sub drinkStock[di],ax
    js negativeDrinkQty                        
    add tempCount, ax
    add tempTotal, ax
    dec bx
    inc si
    
    cmp bx,0
    jnl originalNumberDrinkLoop
    ret

    negativeDrinkQty:
    sub drinkCount[di],ax
    add drinkStock[di],ax
    lea dx,error9
    mov ah,09h
    int 21h
    jmp drinkQty  
recombinerDrink endp

dessert proc
    clearscreen
 
    lea dx,dessert1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,dessert2
    int 21h
    
    lea dx,dessert3
    int 21h
    
    lea dx,dessert4
    int 21h
    
    lea dx,dessert5
    int 21h
    
    lea dx,dessert6
    int 21h
    
    lea dx,dessert7
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,main22
    int 21h
    
    displayNumber totalPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal totalPaymentCent
    
    lea dx,main23
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,dessert1
    int 21h

    lea dx,new
    int 21h
    
    cmp tempCount,0
    je dessertAsk
    
    call addToCartDetails
    
    dessertAsk:
    mov tempCount,0
    lea dx,main14
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    jb noChoiceDessert
    cmp al,'5'
    ja noChoiceDessert
    cmp al,'5'
    je Dessert_food
    
    xor ah,ah
    sub al,'1'
    shl al,1
    mov foodSelect,ax
    jmp dessertQty
    
    noChoiceDessert:
    lea dx,error3
    mov ah,09h
    int 21h
    jmp dessertAsk
    
    dessertQty:
    lea dx,main17
    mov ah,09h
    int 21h
    
    xor dx,dx
    lea si,num1
    call inputQtyDessert
    
    dessertConfirm:
    cmp [num1+0],0
    je dessertConfirmQty
    
    lea dx,main15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je dessertConfirmQty
    cmp al,'y'
    je dessertConfirmQty
    cmp al,'N'
    je dessert_dessert
    cmp al,'n'
    je dessert_dessert
    
    lea dx,error3
    int 21h
    jmp dessertConfirm
    
    dessert_dessert:
    call dessert
    
    dessert_food:
    call foodMenu
    
    dessertConfirmQty:
    lea si, num1
    call recombinerDessert
    
    calculateTotal dessertPrice,dessertCentPrice
    
    cmp foodSelect,0
    je dessertName1
    cmp foodSelect,2
    je dessertName2
    cmp foodSelect,4
    je dessertName3
    cmp foodSelect,6
    je dessertName4
    
    dessertName1:
    lea bx,[dessertn1]
    mov [foodString],bx
    mov bx,dessertStock[0]
    mov foodStock,bx
    jmp dessertName5 
    
    dessertName2:
    lea bx,[dessertn1]
    mov [foodString],bx
    mov bx,dessertStock[2]
    mov foodStock,bx
    jmp dessertName5
    
    dessertName3:
    lea bx,[dessertn1]
    mov [foodString],bx
    mov bx,dessertStock[4]
    mov foodStock,bx
    jmp dessertName5
    
    dessertName4:
    lea bx,[dessertn1]
    mov [foodString],bx
    mov bx,dessertStock[6]
    mov foodStock,bx
    
    dessertName5:
    jmp dessertEnd
    
    noQtyDessert:
    lea dx,error4
    mov ah,09h
    int 21h
    jmp dessertQty
    
    dessertQtyWrong:
    lea dx,error5
    mov ah,09h
    int 21h
    jmp dessertQty
    
    invalidInputDessert:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp dessertQty
    
    dessertNoQty:
    lea dx,error7
    mov ah,09h
    int 21h
    jmp dessertQty
 
    dessertEnd: 
    jmp dessert  
dessert endp

powDessert proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroDessert
    powerLoopDessert:
    mul baseNumber
    loop powerLoopDessert
    jmp exitPowDessert
    powerZeroDessert:
    mov ax,1
    exitPowDessert:
    ret
powDessert endp

inputQtyDessert proc
    mov firstAddress,si
    mov cx,0
    
    loopEnterDessert:
    mov ah,01h
    int 21h
    cmp al,13
    je loopEndDessert
    inc cx
    cmp al,'0'
    jb invalidInputDessert
    cmp al,'9'
    ja invalidInputDessert
    cmp cx,2
    ja dessertQtyWrong
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterDessert
    
    loopEndDessert:
    cmp cx,0
    je dessertNoQty
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret
inputQtyDessert endp

recombinerDessert proc
    xor dx,dx    
    
    xor dx,dx
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberDessertLoop:
    mov power,bx
    call powDessert
    mov power,0
    mov lenNum,0
    mov baseNumber,0
    mov firstAddress,0
    mov dl,[si]
    mov dh,0
    mul dx
    mov di,foodSelect
    add dessertCount[di], ax
    sub dessertStock[di],ax
    js negativeDessertQty                        
    add tempCount, ax
    add tempTotal, ax
    dec bx
    inc si
    
    cmp bx,0
    jnl originalNumberDessertLoop
    ret

    negativeDessertQty:
    sub dessertCount[di],ax
    add dessertStock[di],ax
    lea dx,error9
    mov ah,09h
    int 21h
    jmp dessertQty  
recombinerDessert endp

cart proc
    mov totalPayment, 0
    mov totalPaymentCent, 0
    mov cartNumber,1
    clearscreen
    
    lea dx,cart1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,cart2
    int 21h
    
    lea dx,new
    int 21h
    
    call burgerCart
    
    pizzaCartName:
    call pizzaCart
    
    wrapCartName:
    call wrapCart
    
    cmp totalCart,10
    jl drinkCartName
    mov ah,01h
    int 21h

    mov dl,08h
    mov ah,02h
    int 21h

    mov dl,08h
    mov ah,02h
    int 21h
    drinkCartName:
    call drinkCart
    
    dessertCartName:
    call dessertCart
    
    printCartEnd:
    cmp tempTotal,0
    jne printCartEnd2
    lea dx,cart9
    mov ah,09h
    int 21h

    printCartEnd2:
    lea dx,cart8
    mov ah,09h
    int 21h

    lea dx,new
    int 21h

    lea dx,cart3
    int 21h
    
    displayNumber cartNumber
    inc cartNumber
    
    lea dx,cart4
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,cart3
    int 21h
    
    displayNumber cartNumber
    
    lea dx,cart5
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,cart6
    int 21h
    
    displayNumber totalPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal totalPaymentCent
 
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,cart7
    int 21h

    lea dx,new
    int 21h

    lea dx,cart1
    int 21h
    
    lea dx,new
    int 21h
    
    cartInput:
    mov foodSelectCart,0
    lea dx,main14
    mov ah,09h
    int 21h
    
    xor dx,dx
    lea si,num1
    call inputSelectCart

    xor dx,dx
    lea si,num1
    call recombinerCart2
    jmp checkCartSelect

    cartNoSelect:
    lea dx,error3
    mov ah,09h
    int 21h
    jmp cartInput

    checkCartSelect:
    mov ax,foodSelectCart
    mov dx,cartNumber
    cmp al,dl
    ja cartNoSelect
    cmp al,0
    jb cartNoSelect
    cmp al,dl
    je cart_food
    dec dl
    cmp al,dl
    je cart_checkout
    
    dec ax
    shl ax,1
    mov foodSelectCart,ax
    jmp cartQty

    cartQty:
    lea dx,main25
    mov ah,09h
    int 21h
 
    xor dx,dx
    lea si,num1
    call inputQtyCart

    cartConfirm:
    cmp [num1+0],0
    je cartConfirmQty
    
    lea dx,main15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je cartConfirmQty
    cmp al,'y'
    je cartConfirmQty
    cmp al,'N'
    je cart_cart
    cmp al,'n'
    je cart_cart
    
    lea dx,error3
    mov ah,09h
    int 21h
    jmp cartConfirm
    
    cart_cart:
    call cart
    
    cart_checkout:
    call checkout
    
    cart_food:
    call foodMenu
    
    cartConfirmQty:
    lea si, num1
    call recombinerCart

    mov di,foodSelectCart
    mov bx,orderLocation[di]
    mov ax,tempNum
    sub word ptr [bx], ax
    js negativeCartQty
    
    mov bx,stockLocation[di]
    mov ax,tempNum
    add word ptr [bx], ax
    sub tempTotal, ax 
    mov tempNum,0
    jmp cart_cart
    
    negativeCartQty:
    mov di, foodSelectCart
    mov bx,orderLocation[di]
    mov ax,tempNum
    add word ptr [bx], ax
    lea dx,error8
    mov ah,09h
    int 21h
    mov tempNum,0
    jmp cartQty

    invalidInputCart:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp cart_cart

    cartQtyWrong:
    lea dx,error21
    mov ah,09h
    int 21h
    jmp cartQty   
cart endp

recombinerCart proc
    xor dx,dx    
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberCartLoop:
    mov power,bx
    call powCart
    mov power,0
    mov baseNumber,0
    mov firstAddress,0
    mov dl,[si]
    mov dh,0
    mul dx

    add tempNum,ax
    dec bx
    inc si
    cmp bx,0
    jnl originalNumberCartLoop
    ret
recombinerCart endp

inputQtyCart proc
    mov firstAddress, si
    mov cx,0
    
    loopEnterCart:
    mov ah,01h
    int 21h
    cmp al,13
    je loopEndCart
    inc cx
    cmp al,'0'
    jb invalidInputCart
    cmp al,'9'
    ja invalidInputCart
    cmp cx,2
    ja cartQtyWrong
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterCart
    
    loopEndCart:
    cmp cx,0
    je cartNoQty
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret

    cartNoQty:
    lea dx,error7
    mov ah,09h
    int 21h
    jmp cartQty
inputQtyCart endp

powCart proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroCart
    powerLoopCart:
    mul baseNumber
    loop powerLoopCart
    jmp exitPowCart
    powerZeroCart:
    mov ax,1
    exitPowCart:
    ret
powCart endp

recombinerCart2 proc
    xor dx,dx    
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberCartLoop2:
    mov power,bx
    call powCart2
    mov power,0
    mov baseNumber,0
    mov firstAddress,0
    mov dl,[si]
    mov dh,0
    mul dx

    add foodSelectCart,ax
    dec bx
    inc si
    cmp bx,0
    jnl originalNumberCartLoop2
    ret
recombinerCart2 endp

powCart2 proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroCart2
    powerLoopCart2:
    mul baseNumber
    loop powerLoopCart2
    jmp exitPowCart2
    powerZeroCart2:
    mov ax,1
    exitPowCart2:
    ret
powCart2 endp

inputSelectCart proc
    mov firstAddress, si
    mov cx,0
    
    loopEnterCart2:
    mov ah,01h
    int 21h
    cmp al,13
    je loopEndCart2
    inc cx
    cmp al,'0'
    jb invalidInputCart2
    cmp al,'9'
    ja invalidInputCart2
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterCart2
    
    loopEndCart2:
    cmp cx,0
    je cartNoSelect2
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret

    cartNoSelect2:
    lea dx,error3
    mov ah,09h
    int 21h
    jmp cartInput

    invalidInputCart2:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp cart_cart
inputSelectCart endp

burgerCart proc
    calculateSubtotal burgerCount[0],burgerPrice[0],burgerCentPrice[0]
    calculateTotalCart burgerCount[0],burgerPrice[0],burgerCentPrice[0]
    printCart burgerCount[0], burgerCart2, burgern1, burgerPrice[0], burgerCentPrice[0],burgerStock[0]
    
    burgerCart2:
    calculateSubtotal burgerCount[2],burgerPrice[1],burgerCentPrice[1] 
    calculateTotalCart burgerCount[2],burgerPrice[1],burgerCentPrice[1]
    printCart burgerCount[2], burgerCart3, burgern2, burgerPrice[1], burgerCentPrice[1],burgerStock[2]
    
    burgerCart3:
    calculateSubtotal burgerCount[4],burgerPrice[2],burgerCentPrice[2]
    calculateTotalCart burgerCount[4],burgerPrice[2],burgerCentPrice[2]
    printCart burgerCount[4], burgerCart4, burgern3, burgerPrice[2], burgerCentPrice[2],burgerStock[4]
    
    burgerCart4:
    calculateSubtotal burgerCount[6],burgerPrice[3],burgerCentPrice[3]
    calculateTotalCart burgerCount[6],burgerPrice[3],burgerCentPrice[3]
    printCart burgerCount[6], pizzaCartName, burgern4, burgerPrice[3], burgerCentPrice[3],burgerStock[6]
    ret    
burgerCart endp

pizzaCart proc
    pizzaCart1:
    calculateSubtotal pizzaCount[0],pizzaPrice[0],pizzaCentPrice[0]
    calculateTotalCart pizzaCount[0],pizzaPrice[0],pizzaCentPrice[0]
    printCart pizzaCount[0], pizzaCart2, pizzan1, pizzaPrice[0], pizzaCentPrice[0],pizzaStock[0]
    
    pizzaCart2:
    calculateSubtotal pizzaCount[2],pizzaPrice[1],pizzaCentPrice[1] 
    calculateTotalCart pizzaCount[2],pizzaPrice[1],pizzaCentPrice[1]
    printCart pizzaCount[2], pizzaCart3, pizzan2, pizzaPrice[1], pizzaCentPrice[1],pizzaStock[2]
    
    pizzaCart3:
    calculateSubtotal pizzaCount[4],pizzaPrice[2],pizzaCentPrice[2]
    calculateTotalCart pizzaCount[4],pizzaPrice[2],pizzaCentPrice[2]
    printCart pizzaCount[4], pizzaCart4, pizzan3, pizzaPrice[2], pizzaCentPrice[2],pizzaStock[4]
    
    pizzaCart4:
    calculateSubtotal pizzaCount[6],pizzaPrice[3],pizzaCentPrice[3]
    calculateTotalCart pizzaCount[6],pizzaPrice[3],pizzaCentPrice[3]
    printCart pizzaCount[6], wrapCartName, pizzan4, pizzaPrice[3], pizzaCentPrice[3],pizzaStock[6]
    ret
pizzaCart endp

wrapCart proc
    wrapCart1:
    calculateSubtotal wrapCount[0],wrapPrice[0],wrapCentPrice[0]
    calculateTotalCart wrapCount[0],wrapPrice[0],wrapCentPrice[0]
    printCart wrapCount[0], wrapCart2, wrapn1, wrapPrice[0], wrapCentPrice[0],wrapStock[0]
    
    wrapCart2:
    calculateSubtotal wrapCount[2],wrapPrice[1],wrapCentPrice[1] 
    calculateTotalCart wrapCount[2],wrapPrice[1],wrapCentPrice[1]
    printCart wrapCount[2], wrapCart3, wrapn2, wrapPrice[1], wrapCentPrice[1],wrapStock[2]
    
    wrapCart3:
    calculateSubtotal wrapCount[4],wrapPrice[2],wrapCentPrice[2]
    calculateTotalCart wrapCount[4],wrapPrice[2],wrapCentPrice[2]
    printCart wrapCount[4], wrapCart4, wrapn3, wrapPrice[2], wrapCentPrice[2],wrapStock[4]
    
    wrapCart4:
    calculateSubtotal wrapCount[6],wrapPrice[3],wrapCentPrice[3]
    calculateTotalCart wrapCount[6],wrapPrice[3],wrapCentPrice[3]
    printCart wrapCount[6], drinkCartName, wrapn4, wrapPrice[3], wrapCentPrice[3],wrapStock[6]
    ret
wrapCart endp
             
drinkCart proc
    drinkCart1:
    calculateSubtotal drinkCount[0],drinkPrice[0],drinkCentPrice[0]
    calculateTotalCart drinkCount[0],drinkPrice[0],drinkCentPrice[0]
    printCart drinkCount[0], drinkCart2, drinkn1, drinkPrice[0], drinkCentPrice[0],drinkStock[0]
    
    drinkCart2:
    calculateSubtotal drinkCount[2],drinkPrice[1],drinkCentPrice[1] 
    calculateTotalCart drinkCount[2],drinkPrice[1],drinkCentPrice[1]
    printCart drinkCount[2], drinkCart3, drinkn2, drinkPrice[1], drinkCentPrice[1],drinkStock[2]
    
    drinkCart3:
    calculateSubtotal drinkCount[4],drinkPrice[2],drinkCentPrice[2]
    calculateTotalCart drinkCount[4],drinkPrice[2],drinkCentPrice[2]
    printCart drinkCount[4], drinkCart4, drinkn3, drinkPrice[2], drinkCentPrice[2],drinkStock[4]
    
    drinkCart4:
    calculateSubtotal drinkCount[6],drinkPrice[3],drinkCentPrice[3]
    calculateTotalCart drinkCount[6],drinkPrice[3],drinkCentPrice[3]
    printCart drinkCount[6], dessertCartName, drinkn4, drinkPrice[3], drinkCentPrice[3],drinkStock[6]
    ret
drinkCart endp

dessertCart proc
    dessertCart1:
    calculateSubtotal dessertCount[0],dessertPrice[0],dessertCentPrice[0]
    calculateTotalCart dessertCount[0],dessertPrice[0],dessertCentPrice[0]
    printCart dessertCount[0], dessertCart2, dessertn1, dessertPrice[0], dessertCentPrice[0],dessertStock[0]
    
    dessertCart2:
    calculateSubtotal dessertCount[2],dessertPrice[1],dessertCentPrice[1] 
    calculateTotalCart dessertCount[2],dessertPrice[1],dessertCentPrice[1]
    printCart dessertCount[2], dessertCart3, dessertn2, dessertPrice[1], dessertCentPrice[1],dessertStock[2]
    
    dessertCart3:
    calculateSubtotal dessertCount[4],dessertPrice[2],dessertCentPrice[2]
    calculateTotalCart dessertCount[4],dessertPrice[2],dessertCentPrice[2]
    printCart dessertCount[4], dessertCart4, dessertn3, dessertPrice[2], dessertCentPrice[2],dessertStock[4]
    
    dessertCart4:
    calculateSubtotal dessertCount[6],dessertPrice[3],dessertCentPrice[3]
    calculateTotalCart dessertCount[6],dessertPrice[3],dessertCentPrice[3]
    printCart dessertCount[6], printCartEnd, dessertn4, dessertPrice[3], dessertCentPrice[3],dessertStock[6]
    ret
dessertCart endp

checkoutDetail proc
    mov totalPayment, 0
    mov totalPaymentCent, 0
    mov cartNumber,1
    clearscreen

    lea dx,checkout1
    mov ah,09h
    int 21h

    lea dx,new
    int 21h

    lea dx,checkout3
    int 21h

    lea dx,new
    int 21h

    calculateSubtotal burgerCount[0],burgerPrice[0],burgerCentPrice[0]
    calculateTotalCart burgerCount[0],burgerPrice[0],burgerCentPrice[0]
    printCart burgerCount[0], burgerCheckout2, burgern1, burgerPrice[0], burgerCentPrice[0],burgerStock[0]
    
    burgerCheckout2:
    calculateSubtotal burgerCount[2],burgerPrice[1],burgerCentPrice[1] 
    calculateTotalCart burgerCount[2],burgerPrice[1],burgerCentPrice[1]
    printCart burgerCount[2], burgerCheckout3, burgern2, burgerPrice[1], burgerCentPrice[1],burgerStock[2]
    
    burgerCheckout3:
    calculateSubtotal burgerCount[4],burgerPrice[2],burgerCentPrice[2]
    calculateTotalCart burgerCount[4],burgerPrice[2],burgerCentPrice[2]
    printCart burgerCount[4], burgerCheckout4, burgern3, burgerPrice[2], burgerCentPrice[2],burgerStock[4]
    
    burgerCheckout4:
    calculateSubtotal burgerCount[6],burgerPrice[3],burgerCentPrice[3]
    calculateTotalCart burgerCount[6],burgerPrice[3],burgerCentPrice[3]
    printCart burgerCount[6], pizzaCheckout1, burgern4, burgerPrice[3], burgerCentPrice[3],burgerStock[6]

    pizzaCheckout1:
    calculateSubtotal pizzaCount[0],pizzaPrice[0],pizzaCentPrice[0]
    calculateTotalCart pizzaCount[0],pizzaPrice[0],pizzaCentPrice[0]
    printCart pizzaCount[0], pizzaCheckout2, pizzan1, pizzaPrice[0], pizzaCentPrice[0],pizzaStock[0]
    
    pizzaCheckout2:
    calculateSubtotal pizzaCount[2],pizzaPrice[1],pizzaCentPrice[1] 
    calculateTotalCart pizzaCount[2],pizzaPrice[1],pizzaCentPrice[1]
    printCart pizzaCount[2], pizzaCheckout3, pizzan2, pizzaPrice[1], pizzaCentPrice[1],pizzaStock[2]
    
    pizzaCheckout3:
    calculateSubtotal pizzaCount[4],pizzaPrice[2],pizzaCentPrice[2]
    calculateTotalCart pizzaCount[4],pizzaPrice[2],pizzaCentPrice[2]
    printCart pizzaCount[4], pizzaCheckout4, pizzan3, pizzaPrice[2], pizzaCentPrice[2],pizzaStock[4]
    
    pizzaCheckout4:
    calculateSubtotal pizzaCount[6],pizzaPrice[3],pizzaCentPrice[3]
    calculateTotalCart pizzaCount[6],pizzaPrice[3],pizzaCentPrice[3]
    printCart pizzaCount[6], wrapCheckout1, pizzan4, pizzaPrice[3], pizzaCentPrice[3],pizzaStock[6]

    cmp totalCart,10
    jl wrapCheckout1
    mov ah,01h
    int 21h

    mov dl,08h
    mov ah,02h
    int 21h

    mov dl,08h
    mov ah,02h
    int 21h

    wrapCheckout1:
    calculateSubtotal wrapCount[0],wrapPrice[0],wrapCentPrice[0]
    calculateTotalCart wrapCount[0],wrapPrice[0],wrapCentPrice[0]
    printCart wrapCount[0], wrapCheckout2, wrapn1, wrapPrice[0], wrapCentPrice[0],wrapStock[0]
    
    wrapCheckout2:
    calculateSubtotal wrapCount[2],wrapPrice[1],wrapCentPrice[1] 
    calculateTotalCart wrapCount[2],wrapPrice[1],wrapCentPrice[1]
    printCart wrapCount[2], wrapCheckout3, wrapn2, wrapPrice[1], wrapCentPrice[1],wrapStock[2]
    
    wrapCheckout3:
    calculateSubtotal wrapCount[4],wrapPrice[2],wrapCentPrice[2]
    calculateTotalCart wrapCount[4],wrapPrice[2],wrapCentPrice[2]
    printCart wrapCount[4], wrapCheckout4, wrapn3, wrapPrice[2], wrapCentPrice[2],wrapStock[4]
    
    wrapCheckout4:
    calculateSubtotal wrapCount[6],wrapPrice[3],wrapCentPrice[3]
    calculateTotalCart wrapCount[6],wrapPrice[3],wrapCentPrice[3]
    printCart wrapCount[6], drinkCheckout1, wrapn4, wrapPrice[3], wrapCentPrice[3],wrapStock[6]
        
    drinkCheckout1:
    calculateSubtotal drinkCount[0],drinkPrice[0],drinkCentPrice[0]
    calculateTotalCart drinkCount[0],drinkPrice[0],drinkCentPrice[0]
    printCart drinkCount[0], drinkCheckout2, drinkn1, drinkPrice[0], drinkCentPrice[0],drinkStock[0]
    
    drinkCheckout2:
    calculateSubtotal drinkCount[2],drinkPrice[1],drinkCentPrice[1] 
    calculateTotalCart drinkCount[2],drinkPrice[1],drinkCentPrice[1]
    printCart drinkCount[2], drinkCheckout3, drinkn2, drinkPrice[1], drinkCentPrice[1],drinkStock[2]
    
    drinkCheckout3:
    calculateSubtotal drinkCount[4],drinkPrice[2],drinkCentPrice[2]
    calculateTotalCart drinkCount[4],drinkPrice[2],drinkCentPrice[2]
    printCart drinkCount[4], drinkCheckout4, drinkn3, drinkPrice[2], drinkCentPrice[2],drinkStock[4]
    
    drinkCheckout4:
    calculateSubtotal drinkCount[6],drinkPrice[3],drinkCentPrice[3]
    calculateTotalCart drinkCount[6],drinkPrice[3],drinkCentPrice[3]
    printCart drinkCount[6], dessertCheckout1, drinkn4, drinkPrice[3], drinkCentPrice[3],drinkStock[6]

    dessertCheckout1:
    calculateSubtotal dessertCount[0],dessertPrice[0],dessertCentPrice[0]
    calculateTotalCart dessertCount[0],dessertPrice[0],dessertCentPrice[0]
    printCart dessertCount[0], dessertCheckout2, dessertn1, dessertPrice[0], dessertCentPrice[0],dessertStock[0]
    
    dessertCheckout2:
    calculateSubtotal dessertCount[2],dessertPrice[1],dessertCentPrice[1] 
    calculateTotalCart dessertCount[2],dessertPrice[1],dessertCentPrice[1]
    printCart dessertCount[2], dessertCheckout3, dessertn2, dessertPrice[1], dessertCentPrice[1],dessertStock[2]
    
    dessertCheckout3:
    calculateSubtotal dessertCount[4],dessertPrice[2],dessertCentPrice[2]
    calculateTotalCart dessertCount[4],dessertPrice[2],dessertCentPrice[2]
    printCart dessertCount[4], dessertCheckout4, dessertn3, dessertPrice[2], dessertCentPrice[2],dessertStock[4]
    
    dessertCheckout4:
    calculateSubtotal dessertCount[6],dessertPrice[3],dessertCentPrice[3]
    calculateTotalCart dessertCount[6],dessertPrice[3],dessertCentPrice[3]
    printCart dessertCount[6], printCheckoutEnd, dessertn4, dessertPrice[3], dessertCentPrice[3],dessertStock[6]

    printCheckoutEnd:
    lea dx,new
    mov ah,09h
    int 21h

    lea dx,checkout8
    int 21h

    printSpace2 totalPayment
    displayNumber totalPayment

    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal totalPaymentCent

    lea dx,checkout9
    mov ah,09h
    int 21h

    calculateServiceCharge

    printSpace2 serviceCharge
    displayNumber serviceCharge

    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal serviceChargeCent

    lea dx,checkout10
    mov ah,09h
    int 21h

    calculateGST

    printSpace2 gst
    displayNumber gst

    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal gstCent

    rounding

    lea dx,checkout11
    mov ah,09h
    int 21h

    mov ax,0
    printSpace2 ax
    mov ax,0
    displayNumber ax

    mov dl,'.'
    mov ah,02h
    int 21h

    displayDecimal roundUp

    lea dx,new
    mov ah,09h
    int 21h

    lea dx,checkout12
    int 21h

    printSpace2 checkoutPayment
    displayNumber checkoutPayment

    mov dl,'.'
    mov ah,02h
    int 21h

    displayDecimal checkoutPaymentCent

    lea dx,new
    mov ah,09h
    int 21h
    ret
checkoutDetail endp

checkout proc
    cmp tempTotal,0
    jne checkoutYes
    lea dx,error11
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    call foodMenu

    checkoutYes:
    lea dx,checkout2
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h

    cmp al,'Y'
    je checkoutPrint
    cmp al,'y'
    je checkoutPrint
    cmp al,'N'
    je checkout_food
    cmp al,'n'
    je checkout_food

    lea dx,error3
    mov ah,09h
    int 21h
    jmp checkoutYes

    checkout_food:
    call foodMenu

    noItemInCheckout:
    lea dx,error11
    mov ah,09h
    int 21h
    mov ah,01h
    int 21h
    call foodMenu

    checkoutPrint:
    cmp tempTotal,0
    je noItemInCheckout

    mov checkoutPayment,0
    mov checkoutPaymentCent,0
    call checkoutDetail

    lea dx,checkout14
    int 21h

    lea dx,checkout5
    int 21h

    lea dx,checkout6
    int 21h

    lea dx,checkout7
    int 21h

    lea dx,new
    int 21h

    lea dx,checkout1
    int 21h

    lea dx,new
    int 21h

    checkoutSelect:
    lea dx,main14
    int 21h

    mov ah,01h
    int 21h

    cmp al,'1'
    je checkout_cart
    cmp al,'2'
    je checkout_food
    cmp al,'3'
    je checkout_checkout2

    lea dx,error3
    mov ah,09h
    int 21h
    jmp checkoutSelect

    checkout_cart:
    call cart

    checkout_checkout2:
    call checkoutProceed
checkout endp

checkoutProceed proc
    checkout2Confirm:
    lea dx,main15
    mov ah,09h
    int 21h

    mov ah,01h
    int 21h

    cmp al,'Y'
    je sureToCheckout
    cmp al,'y'
    je sureToCheckout
    cmp al,'N'
    je checkout2_checkout
    cmp al,'n'
    je checkout2_checkout

    lea dx,error3
    mov ah,09h
    int 21h
    jmp checkout2Confirm

    checkout2_checkout:
    call checkout

    sureToCheckout:
    mov checkoutPayment,0
    mov checkoutPaymentCent,0
    call checkoutDetail

    mov ax,totalPayment
    add totalSales,ax

    mov ax,totalPaymentCent
    add totalSalesCent,ax

    lea dx,checkout1
    mov ah,09h
    int 21h

    lea dx,new
    int 21h
    
    sureToCheckoutAsk:
    cmp checkoutPayment,8
    jb skipVoucher
    
    lea dx,checkout15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je enterVoucher
    cmp al,'y'
    je enterVoucher
    cmp al,'N'
    je skipVoucher
    cmp al,'n'
    je skipVoucher
               
    lea dx,error3
    mov ah,09h
    int 21h
    jmp sureToCheckoutAsk
    
    enterVoucher:
    lea dx,checkout16
    mov ah,09h
    int 21h
    
    mov dx,offset voucherEnter
    mov ah,0Ah
    int 21h
    
    lea si,voucher
    lea di,voucherEnter+2
    mov cx,0
    mov cl,[voucherEnter+1]
    cmp cl,1
    je cancelVoucher
    cmp cl,9
    je voucherVerify
     
    voucherError: 
    lea dx,error12
    mov ah,09h
    int 21h
    jmp enterVoucher
    
    cancelVoucher:
    mov bl,[di]
    cmp bl,'0'
    je sureToCheckoutAsk
    jmp voucherError
    
    voucherVerify:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne voucherError
    inc si
    inc di
    loop voucherVerify
    
    addVoucher:
    add voucherDiscount,5
    lea dx,checkout22
    mov ah,09h
    int 21h
     
    skipVoucher:
    cmp checkoutPayment,3
    jb skipMember
    
    lea dx,checkout17
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'Y'
    je enterMember
    cmp al,'y'
    je enterMember
    cmp al,'N'
    je skipMember
    cmp al,'n'
    je skipMember
               
    lea dx,error3
    mov ah,09h
    int 21h
    jmp skipVoucher
    
    enterMember:
    lea dx,checkout18
    mov ah,09h
    int 21h
    
    mov dx,offset memberEnter
    mov ah,0Ah
    int 21h
    
    lea si,membershipid
    lea di,memberEnter+2
    mov cx,0
    mov cl,[memberEnter+1]
    cmp cl,1
    je cancelMember
    cmp cl,7
    je addMember
    
    memberError:
    lea dx,error13
    mov ah,09h
    int 21h
    jmp enterMember
    
    cancelMember:
    mov bl,[di]
    cmp bl,'0'
    je skipVoucher
    jmp memberError
     
    memberVerify:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne memberError
    inc si
    inc di
    loop memberVerify
     
    addMember:
    add memberDiscount,3
    lea dx,checkout23
    mov ah,09h
    int 21h
    
    skipMember:
    lea dx,checkout29
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    clearscreen
    
    mov checkoutPayment,0
    mov checkoutPaymentCent,0
    mov balance,0
    mov balanceCent,0
    call checkoutDetail
    
    lea dx,checkout20
    int 21h
    
    printSpace2 voucherDiscount
    displayNumber voucherDiscount
    
    lea dx,checkout21
    mov ah,09h
    int 21h
    
    printSpace2 memberDiscount
    displayNumber memberDiscount
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,checkout24
    int 21h
    
    mov ax,voucherDiscount
    sub checkoutPayment,ax
    mov ax,memberDiscount
    sub checkoutPayment,ax
    
    printSpace2 checkoutPayment
    displayNumber checkoutPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal checkoutPaymentCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,checkout1
    int 21h
    
    lea dx,new
    int 21h
    
    inputPayment:
    mov userPayment,0
    mov userPaymentCent,0
    lea dx,checkout19
    mov ah,09h
    int 21h
    
    xor dx,dx
    lea si,num1
    call inputCheckoutPayment
    
    lea si, num1
    call recombinerCheckoutPayment
    jmp inputCheckoutPaymentCent
     
    inputCheckoutPaymentCent:   
    mov ah,01h
    int 21h
    
    cmp al,'0'
    jb invalidPaymentCent
    cmp al,'9'
    ja invalidPaymentCent
    
    xor ah,ah
    sub al,48
    mov bl,10
    mul bl
    add userPaymentCent,ax
    
    mov ah,01h
    int 21h
    
    cmp al,'0'
    jb invalidPaymentCent
    cmp al,'9'
    ja invalidPaymentCent
    
    xor ah,ah
    sub al,48
    add userPaymentCent,ax
    jmp calculateBalance
    
    invalidPaymentCent:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp inputPayment
    
    calculateBalance:
    mov bx,userPaymentCent
    mov cx,userPayment
    sub bx,checkoutPaymentCent
    js borrowFromCheckoutPayment
    jmp subtractCheckoutPayment
    
    borrowFromCheckoutPayment:
    dec cx
    add bx,100
    
    subtractCheckoutPayment:
    mov balanceCent,bx
    mov ax,checkoutPayment
    sub cx,ax
    js notEnoughPayment
    jmp checkoutProceed_invoice
    
    notEnoughPayment:
    lea dx,error16
    mov ah,09h
    int 21h
    jmp inputPayment
    
    checkoutProceed_invoice:
    mov balance,cx
    lea dx,checkout29
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    call invoice
checkoutProceed endp

powCheckout proc
    mov ax,1
    mov cx,power
    cmp cx,0
    je powerZeroCheckout
    powerLoopCheckout:
    mul baseNumber
    loop powerLoopCheckout
    jmp exitPowCheckout
    powerZeroCheckout:
    mov ax,1
    exitPowCheckout:
    ret
powCheckout endp

inputCheckoutPayment proc
    mov firstAddress,si
    mov cx,0
    
    loopEnterPayment:
    mov ah,01h
    int 21h
    cmp al,'.'
    je loopEndCheckout
    inc cx
    cmp al,'0'
    jb invalidInputCheckout
    cmp al,'9'
    ja invalidInputCheckout
    cmp cx,5
    ja paymentTooLarge
    sub al,48
    mov [si],al
    inc si
    jmp loopEnterPayment
    
    loopEndCheckout:
    cmp cx,0
    je noInputPayment
    sub si, firstAddress
    mov lenNum, si
    mov ax,lenNum
    ret
    
    invalidInputCheckout:
    lea dx,error6
    mov ah,09h
    int 21h
    jmp inputPayment

    noInputPayment:
    lea dx,error15
    mov ah,09h
    int 21h
    jmp inputPayment

    paymentTooLarge:
    lea dx,error14
    mov ah,09h
    int 21h
    jmp inputPayment
inputCheckoutPayment endp

recombinerCheckoutPayment proc
    xor dx,dx
    mov bx,lenNum
    dec bx
    mov ax,10
    mov baseNumber, ax
    originalNumberCheckoutLoop:
    mov power,bx
    call powCheckout
    mov dl,[si]
    mov dh,0
    mul dx
    add userPayment, ax
    dec bx
    inc si
    
    cmp bx,0
    jnl originalNumberCheckoutLoop
    ret
recombinerCheckoutPayment endp

invoice proc
    clearscreen
    
    mov checkoutPayment,0  
    mov checkoutPaymentCent,0
    
    call checkoutDetail
    
    lea dx,checkout20
    int 21h
    
    displayNumber voucherDiscount
    
    lea dx,checkout21
    mov ah,09h
    int 21h
    
    displayNumber memberDiscount
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,checkout24
    int 21h
    
    mov ax,voucherDiscount
    sub checkoutPayment,ax
    mov ax,memberDiscount
    sub checkoutPayment,ax

    printSpace2 checkoutPayment
    displayNumber checkoutPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal checkoutPaymentCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,checkout25
    int 21h
    
    printSpace2 userPayment
    displayNumber userPayment
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal userPaymentCent
    
    lea dx,checkout26
    mov ah,09h
    int 21h
    
    printSpace2 balance
    displayNumber balance
    
    mov dl,'.'
    mov ah,02h
    int 21h
    
    displayDecimal balanceCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,checkout27
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,checkout1
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,checkout28
    int 21h
    
    mov ah,01h
    int 21h
    
    resetCount burgerCount, burgerSold
    resetCount pizzaCount, pizzaSold
    resetCount wrapCount, wrapSold
    resetCount drinkCount, drinkSold
    resetCount dessertCount, dessertSold
    
    mov ax,serviceCharge
    add totalService,ax
    
    mov ax,serviceChargeCent
    add totalServiceCent,ax
    
    mov ax,roundUp
    add totalRoundCent,ax
    
    inc totalOrder
    
    mov ax,voucherDiscount
    add totalVoucher,ax
    
    mov ax,memberDiscount
    add totalMember,ax 
   
    mov ax,gst
    add totalGst,ax

    mov ax,gstCent
    add totalGstCent,ax

    mov tempTotal,0
    mov serviceCharge,0
    mov serviceChargeCent,0
    mov roundUp,0
    mov gst,0
    mov gstCent,0
    mov checkoutPayment,0
    mov checkoutPaymentCent,0
    mov voucherDiscount,0
    mov memberDiscount,0
    mov userPayment,0
    mov userPaymentCent,0
    mov balance,0
    mov balanceCent,0
    mov totalPayment,0
    mov totalPaymentCent,0
    
    call foodMenu    
invoice endp

salesReport proc
    clearscreen
    
    lea dx,salesReport1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,salesReport16
    int 21h
    
    lea dx,salesReport2
    int 21h
    
    checkCent totalSales,totalSalesCent
    
    lea dx,salesReport3
    mov ah,09h
    int 21h
    
    checkCent totalService,totalServiceCent
    
    lea dx,salesReport18
    mov ah,09h
    int 21h

    checkCent totalGst, totalGstCent

    lea dx,salesReport4
    mov ah,09h
    int 21h
    
    checkCent totalRound,totalRoundCent
    
    lea dx,salesReport5
    mov ah,09h
    int 21h
    
    displayNumber totalVoucher
    
    lea dx,salesReport6
    mov ah,09h
    int 21h
    
    displayNumber totalMember
    
    lea dx,salesReport7
    mov ah,09h
    int 21h
    
    displayNumber totalOrder
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,salesReport8
    int 21h
    
    lea dx,salesReport9
    int 21h
    
    lea dx,salesReport10
    int 21h
    
    lea dx,salesReport11
    int 21h
    
    lea dx,salesReport12
    int 21h
    
    lea dx,salesReport13
    int 21h
    
    lea dx,salesReport17
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,salesReport1
    int 21h
    
    lea dx,new
    int 21h
    
    salesReportAsk:
    lea dx,main14
    int 21h
    
    mov ah,01h
    int 21h
    
    cmp al,'1'
    je salesreport_burgerSalesReport
    cmp al,'2'
    je salesreport_pizzaSalesReport
    cmp al,'3'
    je salesreport_wrapSalesReport
    cmp al,'4'
    je salesreport_drinkSalesReport
    cmp al,'5'
    je salesreport_dessertSalesReport
    cmp al,'6'
    je salesReport_staffMenu

    lea dx,error3
    mov ah,09h
    int 21h
    jmp salesReportAsk
 
    salesreport_burgerSalesReport:
    call burgerSalesReport

    salesreport_pizzaSalesReport:
    call pizzaSalesReport

    salesreport_wrapSalesReport:
    call wrapSalesReport

    salesreport_drinkSalesReport:
    call drinkSalesReport

    salesreport_dessertSalesReport:
    call dessertSalesReport

    salesReport_staffMenu:
    call staffMenu
salesReport endp

burgerSalesReport proc
    clearscreen
    
    mov tempSales,0
    mov tempSalesCent,0
    
    lea dx,salesReport1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,salesReport14
    int 21h
    
    lea dx,new
    int 21h
    
    printSales burgerSold[0],burgern1,burgerPrice[0],burgerCentPrice[0]
    printSales burgerSold[2],burgern2,burgerPrice[1],burgerCentPrice[1]
    printSales burgerSold[4],burgern3,burgerPrice[2],burgerCentPrice[2]
    printSales burgerSold[6],burgern4,burgerPrice[3],burgerCentPrice[3]
    
    lea dx,salesReport15
    mov ah,09h
    int 21h
    
    checkCent tempSales,tempSalesCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,salesReport1
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,checkout29
    int 21h
    
    mov ah,01h
    int 21h
    call salesReport
burgerSalesReport endp

pizzaSalesReport proc
    clearscreen
    
    mov tempSales,0
    mov tempSalesCent,0
    
    lea dx,salesReport1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,salesReport14
    int 21h
    
    lea dx,new
    int 21h
    
    printSales pizzaSold[0],pizzan1,pizzaPrice[0],pizzaCentPrice[0]
    printSales pizzaSold[2],pizzan2,pizzaPrice[1],pizzaCentPrice[1]
    printSales pizzaSold[4],pizzan3,pizzaPrice[2],pizzaCentPrice[2]
    printSales pizzaSold[6],pizzan4,pizzaPrice[3],pizzaCentPrice[3]
    
    lea dx,salesReport15
    mov ah,09h
    int 21h
    
    checkCent tempSales,tempSalesCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,salesReport1
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,checkout29
    int 21h
    
    mov ah,01h
    int 21h
    call salesReport
pizzaSalesReport endp

wrapSalesReport proc
    clearscreen
    
    mov tempSales,0
    mov tempSalesCent,0
    
    lea dx,salesReport1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,salesReport14
    int 21h
    
    lea dx,new
    int 21h
    
    printSales wrapSold[0],wrapn1,wrapPrice[0],wrapCentPrice[0]
    printSales wrapSold[2],wrapn2,wrapPrice[1],wrapCentPrice[1]
    printSales wrapSold[4],wrapn3,wrapPrice[2],wrapCentPrice[2]
    printSales wrapSold[6],wrapn4,wrapPrice[3],wrapCentPrice[3]
    
    lea dx,salesReport15
    mov ah,09h
    int 21h
    
    checkCent tempSales,tempSalesCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,salesReport1
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,checkout29
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    call salesReport
wrapSalesReport endp

drinkSalesReport proc
    clearscreen
    
    mov tempSales,0
    mov tempSalesCent,0
    
    lea dx,salesReport1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,salesReport14
    int 21h
    
    lea dx,new
    int 21h
    
    printSales drinkSold[0],drinkn1,drinkPrice[0],drinkCentPrice[0]
    printSales drinkSold[2],drinkn2,drinkPrice[1],drinkCentPrice[1]
    printSales drinkSold[4],drinkn3,drinkPrice[2],drinkCentPrice[2]
    printSales drinkSold[6],drinkn4,drinkPrice[3],drinkCentPrice[3]
    
    lea dx,salesReport15
    mov ah,09h
    int 21h
    
    checkCent tempSales,tempSalesCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,salesReport1
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,checkout29
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    call salesReport
drinkSalesReport endp

dessertSalesReport proc
    clearscreen
    
    mov tempSales,0
    mov tempSalesCent,0
    
    lea dx,salesReport1
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,salesReport14
    int 21h
    
    lea dx,new
    int 21h
    
    printSales dessertSold[0],dessertn1,dessertPrice[0],dessertCentPrice[0]
    printSales dessertSold[2],dessertn2,dessertPrice[1],dessertCentPrice[1]
    printSales dessertSold[4],dessertn3,dessertPrice[2],dessertCentPrice[2]
    printSales dessertSold[6],dessertn4,dessertPrice[3],dessertCentPrice[3]
    
    lea dx,salesReport15
    mov ah,09h
    int 21h
    
    checkCent tempSales,tempSalesCent
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,salesReport1
    int 21h
    
    lea dx,new
    int 21h
    
    lea dx,checkout29
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    call salesReport  
dessertSalesReport endp

staffMenu proc
    clearscreen
    lea dx,staffMenu2
    mov ah,09h
    int 21h

    lea dx,new
    int 21h

    lea dx,staffMenu1
    int 21h

    lea dx,staffMenu3
    int 21h

    lea dx,staffMenu4
    int 21h

    lea dx,main13
    int 21h

    lea dx,new
    int 21h

    lea dx,staffMenu2
    int 21h

    lea dx,new
    int 21h

    staffMenuAsk:
    lea dx,main14
    int 21h

    mov ah,01h
    int 21h

    cmp al,'1'
    je staffMenu_salesReport
    cmp al,'2'
    je staffMenu_logo
    cmp al,'3'
    je staffMenu_exit
    lea dx,error3
    mov ah,09h
    int 21h
    jmp staffMenuAsk

    staffMenu_salesReport:
    call salesReport
    
    staffMenu_logo:
    jmp logo

    staffMenu_exit:
    call exit
staffMenu endp

addToCartDetails proc
    lea dx,main18
    mov ah,09h
    int 21h
    
    displayNumber tempCount
    
    lea dx,multiply
    mov ah,09h
    int 21h
    
    mov dx,foodString
    int 21h
    
    lea dx, main19
    int 21h
    
    displayNumber foodStock
    
    lea dx,main26
    mov ah,09h
    int 21h
    
    lea dx,main20
    int 21h

    displayNumber tempTotal
    
    lea dx,main21
    mov ah,09h
    int 21h
    
    lea dx,new
    int 21h
    
    RET
addToCartDetails endp

exit proc
    exitAgain:
    clearscreen
    lea dx,main1
    mov ah,09h
    int 21h
    
    lea dx,main2
    mov ah,09h
    int 21h
    
    lea dx,main3
    mov ah,09h
    int 21h
    
    lea dx,main4
    mov ah,09h
    int 21h
    
    lea dx,main5
    mov ah,09h
    int 21h
    
    lea dx,main6
    mov ah,09h
    int 21h

    lea dx,new
    mov ah,09h
    int 21h

    lea dx, main15
    mov ah,09h
    int 21h
    
    mov ah,01h
    int 21h
    cmp al,'Y'
    je exitProg
    cmp al,'y'
    je exitProg
    cmp al,'N'
    je returnProg
    cmp al,'n'
    je returnProg
    lea dx, error3
    int 21h
    jmp exitAgain
    
    returnProg:
    call mainMenu

    exitProg:
    clearscreen
    
    lea dx,main1
    mov ah,09h
    int 21h
    
    lea dx,main2
    mov ah,09h
    int 21h
    
    lea dx,main3
    mov ah,09h
    int 21h
    
    lea dx,main4
    mov ah,09h
    int 21h
    
    lea dx,main5
    mov ah,09h
    int 21h
    
    lea dx,main6
    mov ah,09h
    int 21h
    
    lea dx,new
    mov ah,09h
    int 21h
    
    lea dx,main16
    mov ah,09h
    int 21h
    
    mov ax, 4C00h
    int 21h
exit endp

end main