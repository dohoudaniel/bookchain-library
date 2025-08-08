;; Role-based access control
(define-constant ADMIN_ROLE (some "admin"))
(define-constant LENDER_ROLE (some "lender"))
(define-constant BORROWER_ROLE (some "borrower"))

;; Error constants
(define-constant ERR_UNAUTHORIZED u100)

(define-map roles principal (optional (string-ascii 20)))

;; Verify caller has required role
(define-read-only (has-role (requester principal) (role (string-ascii 20)))
  (match (map-get? roles requester)
    user-role (match user-role
                stored-role (is-eq role stored-role)
                false)
    false
  )
)

;; Grant role (admin only)
(define-public (grant-role (user principal) (role (string-ascii 20)))
  (begin
    (asserts! (has-role tx-sender "admin") (err ERR_UNAUTHORIZED))
    (map-set roles user (some role))
    (ok true)
  )
)