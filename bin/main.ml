(*
let pages = [
  (* Handler methodology - use a handler and a type to generate pages at the root *)
  Dream.get "/" (fun request ->
    let%lwt page = (Core.Router.generate_page Hello request) in
    Dream.html page
  ) ;
]

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

let auth_middleware next request =
      (* Check for the existence of a BI access token - this will invalidate any previously logged in people with passwords *)
      match Dream.session_field request "access_token" with
      | None ->
          (* Invalidate this session, to prevent session fixation attacks before sending them back to login *)
          let%lwt () = Dream.invalidate_session request in 
          Dream.redirect request ~code:302 "/login"
      | Some _ ->
          next request
*)

let () = Core.Bootstrap.launch ();

  (*
  Dotenv.export () |> ignore;

  match Core.Database.check_connection_string () with
  | true -> (
    (* Not every app needs a DB - some may use headless CMS or just be static *)
    (* Need to conditionally check if the environment variables are set and NOT attempt init if they are not *)
    match Core.Database.init_database ~force_migrations:true (Uri.of_string @@ Core.Database.connection_string ()) with
    | Error (`Msg err) -> Format.printf "Error: %s" err
    | Ok () -> Core.Bootstrap.start_server ()
  )
  | false -> Core.Bootstrap.start_server ()
  *)
