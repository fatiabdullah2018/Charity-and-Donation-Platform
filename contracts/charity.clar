;; Charity Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-registered (err u102))

;; Data Variables
(define-data-var charity-nonce uint u0)
(define-data-var campaign-nonce uint u0)

;; Data Maps
(define-map charities
  { charity-id: uint }
  {
    name: (string-ascii 100),
    description: (string-utf8 500),
    website: (string-ascii 100),
    wallet: principal
  }
)

(define-map campaigns
  { campaign-id: uint }
  {
    charity-id: uint,
    name: (string-ascii 100),
    description: (string-utf8 500),
    goal: uint,
    raised: uint,
    active: bool
  }
)

;; Public Functions

;; Register a new charity
(define-public (register-charity (name (string-ascii 100)) (description (string-utf8 500)) (website (string-ascii 100)))
  (let
    (
      (charity-id (var-get charity-nonce))
    )
    (asserts! (is-none (map-get? charities { charity-id: charity-id })) err-already-registered)
    (map-set charities
      { charity-id: charity-id }
      {
        name: name,
        description: description,
        website: website,
        wallet: tx-sender
      }
    )
    (var-set charity-nonce (+ charity-id u1))
    (ok charity-id)
  )
)

;; Create a new campaign
(define-public (create-campaign (charity-id uint) (name (string-ascii 100)) (description (string-utf8 500)) (goal uint))
  (let
    (
      (campaign-id (var-get campaign-nonce))
      (charity (unwrap! (map-get? charities { charity-id: charity-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get wallet charity)) err-owner-only)
    (map-set campaigns
      { campaign-id: campaign-id }
      {
        charity-id: charity-id,
        name: name,
        description: description,
        goal: goal,
        raised: u0,
        active: true
      }
    )
    (var-set campaign-nonce (+ campaign-id u1))
    (ok campaign-id)
  )
)

;; Update campaign status
(define-public (update-campaign-status (campaign-id uint) (active bool))
  (let
    (
      (campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) err-not-found))
      (charity (unwrap! (map-get? charities { charity-id: (get charity-id campaign) }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get wallet charity)) err-owner-only)
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { active: active })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get charity details
(define-read-only (get-charity (charity-id uint))
  (ok (unwrap! (map-get? charities { charity-id: charity-id }) err-not-found))
)

;; Get campaign details
(define-read-only (get-campaign (campaign-id uint))
  (ok (unwrap! (map-get? campaigns { campaign-id: campaign-id }) err-not-found))
)

;; Initialize contract
(begin
  (var-set charity-nonce u0)
  (var-set campaign-nonce u0)
)

