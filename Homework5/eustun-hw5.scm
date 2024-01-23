(define get-operator (lambda (op-symbol env)
  (cond
    ((eq? op-symbol '+) +)
    ((eq? op-symbol '*) *)
    ((eq? op-symbol '-) -)
    ((eq? op-symbol '/) /)
    (else  (display "cs305: ERROR") (newline)(newline)(repl env)))))


(define get-value (lambda (var env)
    (cond 
        ((or (eq? var '+) (eq? var '-) (eq? var '/) (eq? var '*)) var)
       ((null? env) (display "cs305: ERROR") (newline) (newline) (repl env))
       ((eq? var (caar env)) (cdar env))
       ((eq? (is-found var env) #f) (display "cs305: ERROR") (newline) (newline) (repl env))
       (else (get-value var (cdr env))))))


(define is-found (lambda (var env)
    (cond 
       ( (null? env) #f)
       ( (eq? var (caar env)) (cdar env))
       ( else (is-found var (cdr env))))))

(define extend-env (lambda (var val old-env)
        (cons (cons var val) old-env)))

(define define-expr? (lambda (e)
         (and (list? e) (= (length e) 3) (eq? (car e) 'define) (symbol?(cadr e)))))


(define if-expr? (lambda (e)
        (and (list? e) (= (length e) 4) (eq? (car e) 'if) (or (symbol? (cadr e)) (number? (cadr e)) (lambda-expr? (cadr e))  (list? (cadr e))) (or (symbol? (caddr e)) (number? (caddr e)) (lambda-expr? (caddr e))  (list? (caddr e))) (or (symbol? (cadddr e)) (number? (cadddr e)) (lambda-expr? (cadddr e))  (list? (cadddr e))))))




(define let-env (lambda (ls old-env temp-env) ; ((x 1) (y x))
        (if (null? ls)
                (append temp-env old-env)
                (let-env (cdr ls) old-env (if (number? (cadar ls)) 
                                      (extend-env (caar ls) (cadar ls) temp-env)
                                       (extend-env (caar ls) (s6 (cadar ls) old-env) temp-env)
                                      )) 
        )

))




(define check-let-env (lambda (ls)
    (if (null? ls)
        #t
        (and (not (null? (car ls))) (not (memv (caar ls) (map car (cdr ls))))
             (check-let-env (cdr ls))))
))


(define goback (lambda (env)

        (display "cs305: ERROR")(newline)(newline) (repl env)
))


(define var-binding-list-check (lambda (e env)
    (if (null? e)
        #t
        (if (pair? (car e))
                (if (= (length (car e)) 2)
                        (if (not (null? (caar e)))
                                (if (symbol? (caar e)) 

                                        (if (or (symbol? (cadar e)) (number? (cadar e)) (list? (cadar e)))
                                                (var-binding-list-check (cdr e) env)
                                                (goback env) 
                                        )
                                        (goback env) 
                                )
                                (goback env) 
                        )
                        (goback env) 
                )
                (goback env) 
        )

)))



(define let-expr? (lambda (e env)
        
        (and (list? e) (= (length e) 3) (eq? (car e) 'let) (var-binding-list-check (cadr e) env)(check-let-env (cadr e)))
))

(define extend-temp-env
  (lambda (var val old-temp-env)
    (if (null? var)
        old-temp-env
        (extend-temp-env (cdr var) (cdr val)
                         (cons (cons (car var) (s6 (car val) old-temp-env)) old-temp-env)))))


(define lambda-expr? (lambda (e)
        
        (and (list? (car e))(eq? (caar e) 'lambda) (and (list? e) (>= (length e) 2) (eq? (caar e) 'lambda) (list? (cadar e)) (= (length (cadar e)) (length (cdr e))) (or (number? (cadr e)) (list? (cadr e)))) 
        )))



(define define-expr-for-lambda? (lambda (e)
         (and (list? e) (= (length e) 3) (eq? (car e) 'lambda) (list? (caddr e)) (list? (cadr e)))))


(define get-lambda-pairs (lambda (e)
        
        (extend-temp-env (cadar e) (cdr e) '())
        
        
))



(define calculate-if (lambda (e env)

        (if (not (eq? (s6 (cadr e) env) 0)) 

                (s6 (caddr e) env)
                (s6 (cadddr e) env)        
                
        )        
))

        


(define s6 (lambda (e env)
   (cond
      ( (number? e) e)
      ( (symbol? e) (get-value e env))
      ( (not (list? e)) (display "cs305: ERROR")(newline)(newline) (repl env))
      ((lambda-expr? e)
      (s6 (caddar e) (append (get-lambda-pairs e) env)))
      ((define-expr-for-lambda? e) e)
      ((if-expr? e) (calculate-if e env))
      ((let-expr? e env) (s6 (caddr e) (let-env (cadr e)  env '())))
      ( (not (> (length e) 1)) (display "cs305: ERROR")(newline)(newline) (repl env))
      ( else 
         (let (
                (operator (get-operator (car e) env))
                (operands (map s6 (cdr e) (make-list (length (cdr e) ) env )))
              )
              (apply operator operands))))
              
        ))

(define repl (lambda (env)
   (let* (
           (dummy1 (display "cs305> "))
           
           (expr (read))
           
           (new-env (if (define-expr? expr) 
                        (extend-env (cadr expr) (s6 (caddr expr) env) env)
                        env
                    ))
           (val ;(if (define-expr? expr)
                    ;(cadr expr)
                    ;(s6 expr env)
                    
                ;)
                (cond   
                        ((define-expr? expr) (cadr expr))
                        ((and (list? expr) (define-expr-for-lambda? (is-found (car expr) env))) 
                        (s6 (cons (get-value (car expr) env) (cdr expr)) env))
                        (else (s6 expr env))
                )
                
                )
           (dummy2 (display "cs305: "))
           (dummy3 (if (or (procedure? val)
                        (and (list? val) (eq? (car val) 'lambda))
                        (eq? val '+) (eq? val '-) (eq? val '*) (eq? val '/))
                    (display "[PROCEDURE]")
                    (display val)))
           (dummy4 (newline))
           (dummy5 (newline))
          )
          (repl new-env))))


(define cs305 (lambda () (repl '())))