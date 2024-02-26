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

(*let () = Core.Bootstrap.launch ();*)

open Riot
(*open Tyxml*)
open Tyxml_html

(*let build_page html_obj = Format.asprintf "%a" (Html.pp ()) html_obj*)
let compile_elt elt = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) elt
(*let compile_elt_list elt = List.fold_left (fun acc s -> acc ^ s) "" (List.map (fun x -> Format.asprintf "%a" (Tyxml.Html.pp_elt ()) x) elt)*)

module Echo_server = struct
  include Trail.Sock.Default

  type args = unit
  type state = int

  let init _args = `ok 0

  let handle_frame frame _conn state =
    Logger.info (fun f -> f "handling frame: %a" Trail.Frame.pp frame);
    `push ([ frame ], state)
end

let trail =
  let open Trail in
  let open Router in
  let demo_page = Bytestring.of_string (compile_elt (div ~a:[a_class ["bold"]] [ txt "beep" ])) in
  [
    use (module Logger) Logger.(args ~level:Debug ());
    router
      [
        get "/" (fun conn -> Conn.send_response `OK {%b|demo_page|} conn);
        socket "/ws" (module Echo_server) ();
        scope "/api"
          [
            get "/version" (fun conn ->
                Conn.send_response `OK {%b|"none"|} conn);
            scope "/test" [
              get "/version" (fun conn ->
                  Conn.send_response `OK {%b|"none"|} conn);
              get "/version" (fun conn ->
                  Conn.send_response `OK {%b|"none"|} conn);
            ]
          ];
      ];
  ]

[@@@warning "-8"]

let () =
  Riot.run @@ fun () ->
  Logger.set_log_level (Some Info);
  let (Ok _) = Logger.start () in
  sleep 0.1;
  let port = 2118 in
  let handler = Nomad.trail trail in
  let (Ok pid) = Nomad.start_link ~port ~handler () in
  Logger.info (fun f -> f "Listening on 0.0.0.0:%d" port);
  wait_pids [ pid ]

