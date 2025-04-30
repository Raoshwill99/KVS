(define-constant contract-admin principal "SP2P0E6ZGXZXF1E8ACX16CFXQF7DHTZPS4Q8Q43W9") 

;; Error codes
(define-constant error-access-denied u100)
(define-constant error-item-not-found u102)
(define-constant err-already-registered u101)
(define-constant err-not-verified u104)
(define-constant err-not-owner u105)

;; Data Structures
(define-map identities
    principal
    (tuple (name (string-utf8 50)) (email (string-utf8 50)) (verified bool) (timestamp uint) (reputation uint) (revoked bool)))

(define-map identity-attributes
    (tuple (address principal) (key (string-utf8 50)))
    (value (string-utf8 100)))

(define-map knowledge-entries
    uint
    (tuple (title (string-ascii 50)) (content (string-utf8 1000)) (author principal) (timestamp uint) (status (string-ascii 20))))

(define-map content-attestations
    (tuple (attester principal) (entry-id uint))
    (tuple (timestamp uint) (validity-score uint) (review-text (string-utf8 500)) (valid bool)))

(define-map member-reputation
    principal
    uint)

(define-counter entry-counter)

;; Helper function to check if the sender is the contract admin
(define-public (is-contract-admin)
    (if (is-eq tx-sender contract-admin)
        (ok true)
        (err error-access-denied)))

;; Identity Management
(define-public (register-identity name email)
    (begin
        (asserts! (is-eq (get identities tx-sender) none) err-already-registered)
        (map-set identities tx-sender (tuple (name name) (email email) (verified false) (timestamp (get-block-time)) (reputation u0) (revoked false)))
        (ok "Identity Registered")))

(define-public (verify-identity principal)
    (begin
        (is-contract-admin)
        (let ((identity (get identities principal)))
            (asserts! (is-eq identity none) err-not-found)
            (asserts! (not (get verified identity)) err-already-verified)
            (map-set identities principal (tuple (name (get name identity)) (email (get email identity)) (verified true) (timestamp (get timestamp identity)) (reputation u0) (revoked (get revoked identity))))
            (ok "Identity Verified"))))

(define-public (revoke-identity principal)
    (begin
        (is-contract-admin)
        (let ((identity (get identities principal)))
            (asserts! (is-eq identity none) err-not-found)
            (map-set identities principal (tuple (name (get name identity)) (email (get email identity)) (verified false) (timestamp (get timestamp identity)) (reputation u0) (revoked true)))
            (ok "Identity Revoked"))))

(define-public (set-identity-attribute key value)
    (begin
        (let ((identity (get identities tx-sender)))
            (asserts! (is-eq identity none) err-not-found)
            (map-set identity-attributes (tuple (address tx-sender) (key key)) (value value))
            (ok "Attribute Set"))))

(define-read-only (get-identity)
    (get identities tx-sender))

(define-read-only (is-verified)
    (let ((identity (get identities tx-sender)))
        (if (is-eq identity none)
            (err err-not-found)
            (ok (get verified identity)))))

;; Reputation Management
(define-public (update-reputation principal delta)
    (begin
        (let ((current-reputation (get member-reputation principal)))
            (map-set member-reputation principal (+ current-reputation delta))
            (ok "Reputation Updated"))))

(define-read-only (get-reputation)
    (get member-reputation tx-sender))

;; Content Submission
(define-public (submit-content title content)
    (begin
        (asserts! (is-verified) err-not-verified)
        (let ((entry-id (counter-increment entry-counter)))
            (map-set knowledge-entries entry-id (tuple (title title) (content content) (author tx-sender) (timestamp (get-block-time)) (status "pending review")))
            (ok entry-id))))

;; Peer Review (Attestation)
(define-public (make-review entry-id validity-score review-text)
    (begin
        (asserts! (is-verified) err-not-verified)
        (let ((content-entry (get knowledge-entries entry-id)))
            (asserts! (is-eq content-entry none) error-item-not-found)
            (map-set content-attestations (tuple (attester tx-sender) (entry-id entry-id)) (tuple (timestamp (get-block-time)) (validity-score validity-score) (review-text review-text) (valid true)))
            (ok "Review Submitted"))))

;; Content Retrieval
(define-read-only (get-content-details entry-id)
    (get knowledge-entries entry-id))

(define-read-only (get-attestations-by-entry entry-id)
    (filter (lambda (x) (is-eq (get entry-id x) entry-id)) (map-values content-attestations)))

(define-read-only (get-attestations-by-principal principal)
    (filter (lambda (x) (is-eq (get attester x) principal)) (map-values content-attestations)))

;; Contract Activation (initialization)
(define-public (activate-contract)
    (begin
        (ok "Contract Activated")))

;; Testing environment setup for Clarinet