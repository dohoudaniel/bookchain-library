;; SIP-009 NFT implementation for digital books
(define-constant CONTRACT_OWNER tx-sender)

;; Error constants
(define-constant ERR_NOT_OWNER u401)
(define-constant ERR_NOT_FOUND u404)

;; NFT storage
(define-non-fungible-token book-nft uint)
(define-data-var last-id uint u0)
(define-map metadata
  uint
  {
    title: (string-utf8 200),
    author: (string-utf8 100),
    isbn: (string-ascii 13)
  }
)

;; Mint new book NFT
(define-public (mint-book
    (title (string-utf8 200))
    (author (string-utf8 100))
    (isbn (string-ascii 13))
  )
  (let ((new-id (+ (var-get last-id) u1)))
    (try! (nft-mint? book-nft new-id tx-sender))
    (map-set metadata new-id {title: title, author: author, isbn: isbn})
    (var-set last-id new-id)
    (ok new-id)
  )
)

;; Transfer NFT
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR_NOT_OWNER))
    (nft-transfer? book-nft token-id sender recipient)
  )
)

;; SIP-009 compliance
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? book-nft token-id))
)

(define-read-only (get-metadata (token-id uint))
  (ok (map-get? metadata token-id))
)