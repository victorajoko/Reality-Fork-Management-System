;; Inter-reality Asset Transfer Contract

(define-map assets
  { asset-id: uint }
  {
    owner: principal,
    name: (string-ascii 64),
    current-branch: uint
  }
)

(define-map transfer-requests
  { request-id: uint }
  {
    asset-id: uint,
    from-branch: uint,
    to-branch: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-asset-id uint u0)
(define-data-var next-request-id uint u0)

(define-public (create-asset (name (string-ascii 64)) (branch-id uint))
  (let
    ((asset-id (var-get next-asset-id)))
    (var-set next-asset-id (+ asset-id u1))
    (ok (map-set assets
      { asset-id: asset-id }
      {
        owner: tx-sender,
        name: name,
        current-branch: branch-id
      }
    ))
  )
)

(define-public (request-transfer (asset-id uint) (from-branch uint) (to-branch uint))
  (let
    ((request-id (var-get next-request-id)))
    (asserts! (is-eq tx-sender (get owner (unwrap! (map-get? assets { asset-id: asset-id }) (err u404)))) (err u403))
    (var-set next-request-id (+ request-id u1))
    (ok (map-set transfer-requests
      { request-id: request-id }
      {
        asset-id: asset-id,
        from-branch: from-branch,
        to-branch: to-branch,
        status: "pending"
      }
    ))
  )
)

(define-public (approve-transfer (request-id uint))
  (match (map-get? transfer-requests { request-id: request-id })
    request (begin
      (asserts! (is-eq (get status request) "pending") (err u403))
      (map-set assets
        { asset-id: (get asset-id request) }
        (merge (unwrap! (map-get? assets { asset-id: (get asset-id request) }) (err u404))
          { current-branch: (get to-branch request) }
        )
      )
      (ok (map-set transfer-requests
        { request-id: request-id }
        (merge request { status: "approved" })
      )))
    (err u404)
  )
)

(define-read-only (get-asset (asset-id uint))
  (map-get? assets { asset-id: asset-id })
)

(define-read-only (get-transfer-request (request-id uint))
  (map-get? transfer-requests { request-id: request-id })
)

