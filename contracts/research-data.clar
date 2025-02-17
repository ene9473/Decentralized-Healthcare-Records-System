;; Research Data Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-data (err u101))

;; Data Variables
(define-data-var data-nonce uint u0)

;; Data Maps
(define-map anonymized-data
  { data-id: uint }
  {
    age: uint,
    gender: (string-ascii 10),
    condition: (string-ascii 50),
    treatment: (string-ascii 50),
    outcome: (string-ascii 20)
  }
)

;; Public Functions

;; Add anonymized research data
(define-public (add-research-data (age uint) (gender (string-ascii 10)) (condition (string-ascii 50)) (treatment (string-ascii 50)) (outcome (string-ascii 20)))
  (let
    (
      (data-id (var-get data-nonce))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set anonymized-data
      { data-id: data-id }
      {
        age: age,
        gender: gender,
        condition: condition,
        treatment: treatment,
        outcome: outcome
      }
    )
    (var-set data-nonce (+ data-id u1))
    (ok data-id)
  )
)

;; Read-only Functions

;; Get anonymized research data
(define-read-only (get-research-data (data-id uint))
  (ok (unwrap! (map-get? anonymized-data { data-id: data-id }) err-invalid-data))
)

;; Get total number of research data entries
(define-read-only (get-data-count)
  (ok (var-get data-nonce))
)

;; Initialize contract
(begin
  (var-set data-nonce u0)
)

