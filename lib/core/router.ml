open Tyxml
open Tyxml.Html
(*
let start_server () =
  Dream.run ~interface:"0.0.0.0"
    @@ Dream.logger
    (* Why does livereload not work like the docs show? *)
    (*@@ Dream.livereload*)
    @@ (if Database.check_connection_string () then
          Dream.sql_pool (Database.connection_string ()) 
        else
          Dream.no_middleware)
    (* Sessions last exactly as long as a user does, if a user has not logged in after this period they are deleted *)
    @@ (if Database.check_connection_string () then
          Dream.sql_sessions ~lifetime:2.592e+6 
        else
          Dream.memory_sessions ~lifetime:2.592e+6)
    (* TODO: Move this functionality into App.Router and move middleware to Core.Auth *)
    @@ Dream.router (
      [
        Dream.scope "/" [] no_auth_routes ;
        Dream.scope "/" [] pages ;
        Dream.scope "/" [auth_middleware] fragments ;
        Dream.scope "/" [auth_middleware] actions ;
        (* Serve any static content we may need, maybe stylesheets? *)
        (* This local_directory path is relative to the location the app is run from *)
        Dream.get "/static/**" @@ Dream.static "www/static" ;
      ]
    )
*)
let build_page html_obj = Format.asprintf "%a" (Html.pp ()) html_obj

(* The hello page is basically a demo page to show off *)
let hello_page _ =
  build_page (
    Layout.root 
      "Laraml"
      (Layout.centered (Builder.hello_content ()))
  ) |> Lwt.return

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

(* The page types that are available, so that a non-existant page cannot be specified *)
type page =
  | Extend 
  | Feed
  | Hello
  | Login
  | Missing

(* the main handler that lets the router ask for pages *)
let generate_page page request =
  match page with
  | Extend -> extend_page request
  | Hello -> hello_page request
  | Login -> login_page request
  | Feed -> feed_page request
  | Missing -> missing_page request

