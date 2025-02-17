;; Appointment Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-appointment (err u102))
(define-constant err-payment-failed (err u103))

;; Data Variables
(define-data-var appointment-nonce uint u0)

;; Data Maps
(define-map appointments
  { appointment-id: uint }
  {
    patient-id: principal,
    doctor-id: principal,
    timestamp: uint,
    duration: uint,
    fee: uint,
    status: (string-ascii 20)
  }
)

;; Public Functions

;; Schedule an appointment
(define-public (schedule-appointment (patient-id principal) (doctor-id principal) (timestamp uint) (duration uint) (fee uint))
  (let
    (
      (appointment-id (var-get appointment-nonce))
    )
    (asserts! (or (is-eq tx-sender contract-owner) (is-eq tx-sender patient-id)) err-not-authorized)
    (map-set appointments
      { appointment-id: appointment-id }
      {
        patient-id: patient-id,
        doctor-id: doctor-id,
        timestamp: timestamp,
        duration: duration,
        fee: fee,
        status: "scheduled"
      }
    )
    (var-set appointment-nonce (+ appointment-id u1))
    (ok appointment-id)
  )
)

;; Pay for an appointment
(define-public (pay-appointment (appointment-id uint))
  (let
    (
      (appointment (unwrap! (map-get? appointments { appointment-id: appointment-id }) err-invalid-appointment))
    )
    (asserts! (is-eq tx-sender (get patient-id appointment)) err-not-authorized)
    (asserts! (is-eq (get status appointment) "scheduled") err-invalid-appointment)
    (try! (stx-transfer? (get fee appointment) tx-sender (get doctor-id appointment)))
    (map-set appointments
      { appointment-id: appointment-id }
      (merge appointment { status: "paid" })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get appointment details
(define-read-only (get-appointment (appointment-id uint))
  (ok (unwrap! (map-get? appointments { appointment-id: appointment-id }) err-invalid-appointment))
)

;; Initialize contract
(begin
  (var-set appointment-nonce u0)
)

