(lang dune 3.11)

(name laraml)

(generate_opam_files true)

(source
 (github samhuckaby/laraml))

(authors "Sam Huckaby")

(maintainers "Sam Huckaby")

(license MIT)

(documentation https://laraml.com)

(package
 (name laraml)
 (synopsis "An opinionated OCaml web framework built on Dream")
 (description "Laraml is a Laravel-esque web framework that is designed to help OCaml developers to build web apps rapidly so that OCaml can become a go-to rapid prototyping tool.")
 (depends ocaml dune)
 (tags
  (dream "web framework" SaaS rapid prototype)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
