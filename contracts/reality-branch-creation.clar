;; Reality Branch Creation Contract

(define-map reality-branches
  { branch-id: uint }
  {
    creator: principal,
    parent-branch: (optional uint),
    description: (string-utf8 256),
    creation-time: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-branch-id uint u0)

(define-public (create-branch (parent-branch (optional uint)) (description (string-utf8 256)))
  (let
    ((branch-id (var-get next-branch-id)))
    (var-set next-branch-id (+ branch-id u1))
    (ok (map-set reality-branches
      { branch-id: branch-id }
      {
        creator: tx-sender,
        parent-branch: parent-branch,
        description: description,
        creation-time: block-height,
        status: "active"
      }
    ))
  )
)

(define-public (close-branch (branch-id uint))
  (match (map-get? reality-branches { branch-id: branch-id })
    branch (begin
      (asserts! (is-eq tx-sender (get creator branch)) (err u403))
      (ok (map-set reality-branches
        { branch-id: branch-id }
        (merge branch { status: "closed" })
      )))
    (err u404)
  )
)

(define-read-only (get-branch (branch-id uint))
  (map-get? reality-branches { branch-id: branch-id })
)

