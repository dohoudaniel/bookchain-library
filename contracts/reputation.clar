;; Manages user reputation scores
(define-map reputation-scores principal uint)
(define-constant REPUTATION_DELTA u10)
(define-constant INITIAL_REPUTATION u100)

;; Update user reputation
(define-public (update-reputation (user principal) (on-time bool))
  (let (
      (current (default-to INITIAL_REPUTATION (map-get? reputation-scores user)))
      (new-score (if on-time
                   (+ current REPUTATION_DELTA)
                   (- current REPUTATION_DELTA)))
    )
    (map-set reputation-scores user new-score)
    (ok new-score)
  )
)

;; Get current reputation
(define-read-only (get-reputation (user principal))
  (ok (default-to INITIAL_REPUTATION (map-get? reputation-scores user)))
)