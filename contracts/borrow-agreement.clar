;; Manages active borrowing agreements
(define-constant ERR_BOOK_BORROWED u104)
(define-constant ERR_AGREEMENT_EXISTS u105)
(define-constant ERR_NOT_BORROWED u106)

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
      (listing (unwrap! (contract-call? .lending-pool.get-listing book-id) ERR_NOT_LISTED))
      (max-duration (get max-duration listing))
      (daily-rate (get rate listing))
      (lender (get lender listing))
    )
    (asserts! (is-none (map-get? agreements {book-id: book-id})) ERR_BOOK_BORROWED)
    (asserts! (<= duration max-duration) u107) ;; ERR_DURATION_EXCEEDED

    (map-set agreements {book-id: book-id}
      {
        borrower: tx-sender,
        start-height: block-height,
        end-height: (+ block-height duration),
        daily-rate: daily-rate
      })
    (contract-call? .book-nft.transfer book-id lender tx-sender)
    (ok true)
  )
)

;; Return book
(define-public (return-book (book-id uint))
  (let (
      (agreement (unwrap! (map-get? agreements {book-id: book-id}) ERR_NOT_BORROWED))
      (borrower (get borrower agreement))
    )
    (asserts! (is-eq tx-sender borrower) err-unauthorized)
    (contract-call? .book-nft.transfer book-id tx-sender (get lender (contract-call? .lending-pool.get-listing book-id)))
    (map-delete agreements {book-id: book-id})
    (contract-call? .reputation.update-reputation borrower (<= block-height (get end-height agreement)))
    (ok true)
  )
)