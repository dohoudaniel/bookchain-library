;; System administration and configuration
(define-constant ERR_UNAUTHORIZED u100)

(define-data-var system-active bool true)
(define-data-var max-lending-duration uint u90) ;; Max 90 days

;; Toggle system activity
(define-public (set-system-active (active bool))
  (begin
    (asserts! (contract-call? .access-control has-role tx-sender "admin") (err ERR_UNAUTHORIZED))
    (var-set system-active active)
    (ok true)
  )
)

;; Get system status
(define-read-only (is-system-active)
  (var-get system-active)
)

;; Get max lending duration
(define-read-only (get-max-lending-duration)
  (var-get max-lending-duration)
)

;; Set max lending duration (admin only)
(define-public (set-max-lending-duration (duration uint))
  (begin
    (asserts! (contract-call? .access-control has-role tx-sender "admin") (err ERR_UNAUTHORIZED))
    (var-set max-lending-duration duration)
    (ok true)
  )
)