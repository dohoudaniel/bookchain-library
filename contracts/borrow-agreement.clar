;; Manages active borrowing agreements
(define-constant ERR_BOOK_BORROWED u104)
(define-constant ERR_AGREEMENT_EXISTS u105)
(define-constant ERR_NOT_BORROWED u106)
(define-constant ERR_NOT_LISTED u102)
(define-constant ERR_DURATION_EXCEEDED u107)
(define-constant ERR_UNAUTHORIZED u100)

(define-map agreements
  {book-id: uint}
  {
    borrower: principal,
    start-height: uint,
    end-height: uint,
    daily-rate: uint
  }
)

;; Borrow book
(define-public (borrow-book (book-id uint) (duration uint))
  (let (
      (listing (unwrap! (contract-call? .lending-pool get-listing book-id) (err ERR_NOT_LISTED)))
      (max-duration (get max-duration listing))
      (daily-rate (get rate listing))
      (lender (get lender listing))
    )
    (asserts! (is-none (map-get? agreements {book-id: book-id})) (err ERR_BOOK_BORROWED))
    (asserts! (<= duration max-duration) (err ERR_DURATION_EXCEEDED))

    (map-set agreements {book-id: book-id}
      {
        borrower: tx-sender,
        start-height: stacks-block-height,
        end-height: (+ stacks-block-height duration),
        daily-rate: daily-rate
      })
    (try! (contract-call? .book-nft transfer book-id lender tx-sender))
    (ok true)
  )
)

;; Return book
(define-public (return-book (book-id uint))
  (let (
      (agreement (unwrap! (map-get? agreements {book-id: book-id}) (err ERR_NOT_BORROWED)))
      (borrower (get borrower agreement))
      (listing (unwrap! (contract-call? .lending-pool get-listing book-id) (err ERR_NOT_LISTED)))
      (lender (get lender listing))
      (on-time (<= stacks-block-height (get end-height agreement)))
    )
    (asserts! (is-eq tx-sender borrower) (err ERR_UNAUTHORIZED))
    (try! (contract-call? .book-nft transfer book-id tx-sender lender))
    (map-delete agreements {book-id: book-id})
    ;; Update reputation (ignore result)
    (let ((reputation-result (contract-call? .reputation update-reputation borrower on-time)))
      (ok true)
    )
  )
)

;; Get agreement details
(define-read-only (get-agreement (book-id uint))
  (map-get? agreements {book-id: book-id})
)