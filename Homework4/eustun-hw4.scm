(define twoOperatorCalculator (lambda (e)
(cond
    ((number? e) e)
    ((not (list? e)) e)
    ((= (length e) 1) (car e))
    ((= (length e) 3)
    (cond  
         ((equal? '+ (car (cdr e)))
            (+ (twoOperatorCalculator (car e)) (twoOperatorCalculator (car (cdr (cdr e))))))
         ((equal? '- (car (cdr e)))
            (- (twoOperatorCalculator (car e)) (twoOperatorCalculator (car (cdr (cdr e))))))
    ))

    ((equal? '+ (car (cdr e)))
    (twoOperatorCalculator (cons (+ (car e) (car (cdr (cdr e)))) (cdr (cdr (cdr e))))))
    ((equal? '- (car (cdr e)))
    (twoOperatorCalculator (cons (- (car e) (car (cdr (cdr e)))) (cdr (cdr (cdr e))))))
 
)))


(define (add-to-end item lst)
   (if (null? lst)
      (list item)
      (cons (car lst) (add-to-end item (cdr lst)))))




(define fourOperatorCalculator (lambda (e)
   (define equationList '())
   (letrec  ((recursion (lambda (lstEquation)
   
   (cond
      ((number? lstEquation) (list lstEquation))
      ((not (list? lstEquation)) lstEquation)
      ((= (length lstEquation) 1) equationList
      (set! equationList (add-to-end (car lstEquation) equationList)) equationList)
      ((equal? '- (car (cdr lstEquation)))
      (set! equationList (add-to-end (car lstEquation) equationList))
      (set! equationList (add-to-end (car (cdr lstEquation)) equationList))
      (recursion (cdr (cdr lstEquation))))
      ((equal? '+ (car (cdr lstEquation)))
      (set! equationList (add-to-end (car lstEquation) equationList))
      (set! equationList (add-to-end (car (cdr lstEquation)) equationList))
      (recursion (cdr (cdr lstEquation))))
      ((equal? '* (car (cdr lstEquation)))
      (recursion (cons (* (car lstEquation) (car (cdr (cdr lstEquation)))) (cdr (cdr (cdr lstEquation))))))
      ;(set! equationList (add-to-end (* (car lstEquation) (car (cdr (cdr lstEquation)))) equationList)))
      ((equal? '/ (car (cdr lstEquation)))
      (recursion (cons (/ (car lstEquation) (car (cdr (cdr lstEquation)))) (cdr (cdr (cdr lstEquation))))))
      ;(set! equationList (add-to-end (/ (car lstEquation) (car (cdr (cdr lstEquation)))) equationList)))

      (else lstEquation)
   )
   
   
   ))) (recursion e))
   
))






(define calculatorNested (lambda (e)
   (define equationList '())
   (letrec ((nestedList '()) (recursion (lambda (lstEquation)
   
   (cond
      ((null? lstEquation) equationList)
      
      ((= (length lstEquation) 1) 
      (set! equationList (add-to-end (twoOperatorCalculator (fourOperatorCalculator(car lstEquation))) equationList)) equationList)
      
      ((not (list? (car lstEquation))) 
      (set! equationList (add-to-end (car lstEquation) equationList))
      (set! equationList (add-to-end (car (cdr lstEquation)) equationList))
      (recursion (cdr (cdr lstEquation))))

      ((list? (car lstEquation))
      
      (set! equationList (add-to-end (twoOperatorCalculator (fourOperatorCalculator (car lstEquation))) equationList))
      (set! equationList (add-to-end (car (cdr lstEquation)) equationList))
      (recursion (cdr (cdr lstEquation))))
        
      (else lstEquation)
   )
))) (recursion e))
   equationList
))



(define checkOperators
  (lambda (e)
    (cond

      ;((and (number? e)) #f)

      ((or (not (list? e)) (null? e)) #f)

      ((and (= (length e) 1) (number? (car e))) #t)

      ((and (list? (car e)) (null? (cdr e)))
      (and (checkOperators (car e))))

      ((and (list? (car e)) (or (equal? '+ (car (cdr e))) (equal? '- (car (cdr e))) (equal? '* (car (cdr e))) (equal? '/ (car (cdr e)))))
       (and (checkOperators (car e)) (checkOperators (cdr (cdr e)))))

      ((and (number? (car e)) (or (equal? '+ (car (cdr e))) (equal? '- (car (cdr e))) (equal? '* (car (cdr e))) (equal? '/ (car (cdr e)))))
       (and (checkOperators (cdr (cdr e)))))


      
       
      (else #f)
    )
  )
)




(define calculator (lambda (e)

   (cond
      
      ((equal? #f (checkOperators e)) #f)


      ((equal? #t (checkOperators e)) 
      (twoOperatorCalculator (fourOperatorCalculator (calculatorNested e)))
      )

      
   
   )

   
))