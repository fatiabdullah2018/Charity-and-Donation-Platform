;; Donation Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-amount (err u102))

;; Data Variables
(define-data-var donation-nonce uint u0)

;; Data Maps
(define-map donations
  { donation-id: uint }
  {
    donor: principal,
    campaign-id: uint,
    amount: uint,
    timestamp: uint
  }
)

;; Public Functions

;; Make a donation
(define-public (donate (campaign-id uint) (amount uint))
  (let
    (
      (donation-id (var-get donation-nonce))
    )
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set donations
      { donation-id: donation-id }
      {
        donor: tx-sender,
        campaign-id: campaign-id,
        amount: amount,
        timestamp: block-height
      }
    )
    (var-set donation-nonce (+ donation-id u1))
    (ok donation-id)
  )
)

;; Read-only Functions

;; Get donation details
(define-read-only (get-donation (donation-id uint))
  (ok (unwrap! (map-get? donations { donation-id: donation-id }) err-not-found))
)

;; Initialize contract
(begin
  (var-set donation-nonce u0)
)

