open Tyxml
(* TODO: Setup routes, which will be exported and ingested by Core.Bootstrap *)

let build_page html_obj = Format.asprintf "%a" (Html.pp ()) html_obj

(* The hello page is basically a demo page to show off *)
let hello_page _ =
  build_page (
    Layout.root 
      "Laraml"
      (Layout.centered (View.hello_content ()))
  ) |> Lwt.return
(*
let missing_page _ =
  build_page (
    Layout.root 
      "How do I get my passkey on this device?"
      (Layout.content (h1 ~a:[a_class ["text-4xl text-black dark:text-white"]] [txt "Laraml"]) (Builder.missing_content ()))
  ) |> Lwt.return

(* The login page is where the user enters their username and either logs in or registers *)
let login_page request =
  build_page (
    Layout.root 
      "Login"
      (Layout.centered (Builder.login_dialog request))
  ) |> Lwt.return

let extend_page request =
  build_page (
    Layout.root 
      "Extend My Account"
      (Layout.centered (Builder.extend_dialog request))
  ) |> Lwt.return

(* The feed page is where the social messages will appear in this test of infinite loading *)
(* Look! nested layouts!!! *)
let feed_page request =
  build_page (
    Layout.root
      "WHNVR - Echos from the void"
      (Layout.standard request (Layout.feed request))
  ) |> Lwt.return
*)
let pages = [
  Dream.scope "/" [(* Middleware goes here *)] [
    Dream.get "/" (fun request ->
      let%lwt page = (hello_page request) in
      Dream.html page
    ) ;
  ]
]

let api = [
  Dream.scope "/api" [(* Middleware goes here *)] [
      Dream.post "/logout" (fun request ->
      let%lwt () = Dream.invalidate_session request in 
      Lwt.return (Dream.response ~headers:[("HX-Redirect", "/")] ~code:200 "Logged out!")
    ) ;
  ]
];
(*
(** The routes below are not protected by the auth middleware *)
let no_auth_routes = [
  Dream.get "/hello" (fun request ->
    let%lwt page = (Core.Router.generate_page Hello request) in
    Dream.html page
  ) ;

  Dream.get "/missing" (fun request ->
    let%lwt page = (Core.Router.generate_page Missing request) in
    Dream.html page
  ) ;

  Dream.get "/extend" (fun request ->
    let%lwt page = (Core.Router.generate_page Extend request) in
    Dream.html page
  ) ;
]

(* TODO: These are API routes *)
let actions = [
  Dream.post "/logout" (fun request ->
    let%lwt () = Dream.invalidate_session request in 
    Lwt.return (Dream.response ~headers:[("HX-Redirect", "/")] ~code:200 "Logged out!")
  )
]

(* The below "fragments" are page pieces that can be hot swapped out with htmx *)
let fragments = [
  Dream.get "/menu-close" (fun request ->
    Dream.html (Core.Layout.compile_elt (Core.Builder.standard_menu request false))
  ) ;

  Dream.get "/menu-open" (fun request ->
    Dream.html (Core.Layout.compile_elt (Core.Builder.standard_menu request true))
  ) ;
]
*)
