; extends
;; H3 = "### "
((comment) @symbol @name
  (#match? @name "^###\\s+.+")
  (#gsub!  @name "^###\\s+" "H3 ")
  (#set!   kind "Package")
  (#set!   detail "H3"))

;; H2 = "## "
((comment) @symbol @name
  (#match? @name "^##\\s+.+")
  (#gsub!  @name "^##\\s+" "")
  (#set!   kind "Namespace")
  (#set!   detail "H2"))

;; H1 = "# "
((comment) @symbol @name
  (#match? @name "^#\\s+.+")
  (#gsub!  @name "^#\\s+" "")
  (#set!   kind "Module")
  (#set!   detail "H1"))

;; Variables from assignments:  name <- ..., name <<- ..., name = ...
((binary_operator
  lhs: (identifier) @symbol
  operator: [
    ("<-")
    ("<<-")
    ("=")
  ]
  rhs: (_) @rhs
  (#not-match? @rhs "^\\s*function\\s*\\(")
  (#set! kind "Variable")
  (#set! detail "Assignment")
  ) @name)
