;; Calculates late return penalties
(define-constant BASE_PENALTY_RATE u100)  ;; 1% per day
(define-constant ERR_NO_AGREEMENT u108)

(define-data-var penalty-rate uint BASE_PENALTY_RATE)

;; Convert block height to days (144 blocks/day)
(define-private (stx-block-height-to-days (blocks uint))
  (ok (/ blocks u144))
)

;; Calculate penalty amount
(define-read-only (calculate-penalty (book-id uint))
  (let ((agreement (unwrap! (contract-call? .borrow-agreement.get-agreement book-id) ERR_NO_AGREEMENT)))
    (if (> block-height (get end-height agreement))
      (let (
          (days-late (unwrap! (stx-block-height-to-days (- block-height (get end-height agreement))) u0))
          (base-amount (* (get daily-rate agreement) days-late))
        )
        (/ (* base-amount (var-get penalty-rate)) u100)
      )
      u0
    )
  )
)

;; Admin: Update penalty rate
(define-public (set-penalty-rate (new-rate uint))
  (begin
    (asserts! (contract-call? .access-control.has-role tx-sender "admin") err-unauthorized)
    (var-set penalty-rate new-rate)
    (ok true)
  )
)