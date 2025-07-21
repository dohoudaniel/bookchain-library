;; Role-based access control
(define-constant ADMIN_ROLE (some 'admin))
(define-constant LENDER_ROLE (some 'lender))
(define-constant BORROWER_ROLE (some 'borrower))

(define-map roles principal (optional-as-max-len (string-ascii 20) 20))

;; Verify caller has required role
(define-read-only (has-role (requester principal) (role (string-ascii 20)))
  (is-eq (some role) (map-get? roles requester))
)

;; Grant role (admin only)
(define-public (grant-role (user principal) (role (string-ascii 20)))
  (begin
    (asserts! (has-role tx-sender "admin") err-unauthorized)
    (map-set roles user (some role))
    (ok true)
  )
)