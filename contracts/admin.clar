;; System administration and configuration
(use-trait access-control-trait .access-control.has-role)
(define-constant ERR_UNAUTHORIZED u100)

(define-data-var system-active bool true)
(define-data-var max-lending-duration uint u90) ;; Max 90 days

;; Toggle system activity
(define-public (set-system-active (active bool))
  (begin
    (asserts! (contract-call? .access-control.has-role tx-sender "admin") err-unauthorized)
    (var-set system-active active)
    (ok true)
  )
)