;; Manages book listings and lending parameters
(define-constant ERR_NOT_OWNER u101)
(define-constant ERR_NOT_LISTED u102)
(define-constant ERR_ALREADY_LISTED u103)

(define-map listed-books
  {book-id: uint}
  {lender: principal, rate: uint, max-duration: uint}
)

;; List book for lending
(define-public (list-book (book-id uint) (rate uint) (max-duration uint))
  (begin
    (asserts! (is-eq tx-sender (contract-call? .book-nft.get-owner book-id)) ERR_NOT_OWNER)
    (asserts! (is-none (map-get? listed-books {book-id: book-id})) ERR_ALREADY_LISTED)
    (map-set listed-books {book-id: book-id}
      {lender: tx-sender, rate: rate, max-duration: max-duration})
    (ok true)
  )
)

;; Remove book listing
(define-public (delist-book (book-id uint))
  (begin
    (asserts! (is-some (map-get? listed-books {book-id: book-id})) ERR_NOT_LISTED)
    (asserts! (is-eq tx-sender (get lender (unwrap! (map-get? listed-books {book-id: book-id}) none))) ERR_NOT_OWNER)
    (map-delete listed-books {book-id: book-id})
    (ok true)
  )
)

;; Get listing details
(define-read-only (get-listing (book-id uint))
  (map-get? listed-books {book-id: book-id})
)