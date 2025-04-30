;; Define the contract administrator 
(define-constant contract-admin 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)

;; Error codes
(define-constant error-access-denied u100)
(define-constant error-item-not-found u102)
(define-constant err-already-registered u101)
(define-constant err-not-found u103)  ;; Added missing error code
(define-constant err-not-verified u104)
(define-constant err-not-owner u105)
(define-constant err-already-verified u106)  ;; Added missing error code

;; Data Structures
(define-map identities
    principal
    {name: (string-utf8 50), 
     email: (string-utf8 50), 
     verified: bool, 
     timestamp: uint, 
     reputation: uint, 
     revoked: bool})

(define-map identity-attributes
    {address: principal, key: (string-utf8 50)}
    {value: (string-utf8 100)})

(define-map knowledge-entries
    uint
    {title: (string-ascii 50), 
     content: (string-utf8 1000), 
     author: principal, 
     timestamp: uint, 
     status: (string-ascii 20)})

(define-map content-attestations
    {attester: principal, entry-id: uint}
    {timestamp: uint, 
     validity-score: uint, 
     review-text: (string-utf8 500), 
     valid: bool})

(define-map member-reputation
    principal
    uint)

;; Counter for Entry IDs
(define-data-var entry-counter uint u0)  ;; Changed from map to data-var

;; Helper function to check if the sender is the contract admin
(define-public (is-contract-admin)
    (if (is-eq tx-sender contract-admin)
        (ok true)
        (err error-access-denied)))

;; Identity Management
(define-public (register-identity (name (string-utf8 50)) (email (string-utf8 50)))
    (begin
        (asserts! (is-none (map-get? identities tx-sender)) (err err-already-registered))
        (map-set identities tx-sender 
            {name: name, 
             email: email, 
             verified: false, 
             timestamp: block-height, 
             reputation: u0, 
             revoked: false})
        (ok "Identity Registered")))

(define-public (verify-identity (principal principal))
    (begin
        (try! (is-contract-admin))  ;; Use try! to process the result
        (let ((identity (unwrap! (map-get? identities principal) (err err-not-found))))
            (asserts! (not (get verified identity)) (err err-already-verified))
            (map-set identities principal 
                (merge identity {verified: true}))
            (ok "Identity Verified"))))

(define-public (revoke-identity (principal principal))
    (begin
        (try! (is-contract-admin))
        (let ((identity (unwrap! (map-get? identities principal) (err err-not-found))))
            (map-set identities principal 
                (merge identity {verified: false, revoked: true}))
            (ok "Identity Revoked"))))

(define-public (set-identity-attribute (key (string-utf8 50)) (value (string-utf8 100)))
    (begin
        (asserts! (is-some (map-get? identities tx-sender)) (err err-not-found))
        (map-set identity-attributes {address: tx-sender, key: key} {value: value})
        (ok "Attribute Set")))

(define-read-only (get-identity)
    (map-get? identities tx-sender))

(define-read-only (is-verified)
    (let ((identity (map-get? identities tx-sender)))
        (if (is-none identity)
            (err err-not-found)
            (ok (get verified (unwrap-panic identity))))))

;; Reputation Management
(define-public (update-reputation (principal principal) (delta int))
    (begin
        (try! (is-contract-admin))  ;; Added admin check
        (let ((current-reputation (default-to u0 (map-get? member-reputation principal))))
            ;; Handle both positive and negative reputation changes
            (if (< delta 0)
                ;; For negative delta, we need to handle the absolute value manually
                (let ((abs-delta (- 0 delta)))  ;; Manually calculate absolute value
                    (if (> (to-uint abs-delta) current-reputation)
                        (map-set member-reputation principal u0)  ;; Can't go below 0
                        (map-set member-reputation principal (- current-reputation (to-uint abs-delta)))))
                ;; For positive delta, just add it
                (map-set member-reputation principal (+ current-reputation (to-uint delta))))
            (ok "Reputation Updated"))))

(define-read-only (get-reputation)
    (default-to u0 (map-get? member-reputation tx-sender)))

;; Content Submission
(define-public (submit-content (title (string-ascii 50)) (content (string-utf8 1000)))
    (begin
        (asserts! (unwrap! (is-verified) (err err-not-verified)) (err err-not-verified))
        (let ((new-id (+ (var-get entry-counter) u1)))
            (var-set entry-counter new-id)
            (map-set knowledge-entries new-id 
                {title: title, 
                 content: content, 
                 author: tx-sender, 
                 timestamp: block-height, 
                 status: "pending review"})
            (ok new-id))))

;; Peer Review (Attestation)
(define-public (make-review (entry-id uint) (validity-score uint) (review-text (string-utf8 500)))
    (begin
        (asserts! (unwrap! (is-verified) (err err-not-verified)) (err err-not-verified))
        (let ((content-entry (unwrap! (map-get? knowledge-entries entry-id) (err error-item-not-found))))
            ;; Prevent authors from reviewing their own content
            (asserts! (not (is-eq tx-sender (get author content-entry))) (err err-not-owner))
            (map-set content-attestations 
                {attester: tx-sender, entry-id: entry-id} 
                {timestamp: block-height, 
                 validity-score: validity-score, 
                 review-text: review-text, 
                 valid: true})
            (ok "Review Submitted"))))

;; Content Retrieval
(define-read-only (get-content-details (entry-id uint))
    (map-get? knowledge-entries entry-id))

;; Note: The filter functions need to be rewritten as they're not valid in Clarity
;; These functions would require a different approach in Clarity

;; Contract Activation (initialization)
(define-public (activate-contract)
    (begin
        (try! (is-contract-admin))  ;; Only admin can activate
        (ok "Contract Activated")))
