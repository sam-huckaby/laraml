open Petrol
open Petrol.Postgres
open Cryptokit

let hex_of_string s =
  let result = Buffer.create (String.length s * 2) in
  String.iter (fun c -> Printf.bprintf result "%02x" (int_of_char c)) s;
  Buffer.contents result

(** ALL TIME IS IN GMT - BECAUSE IT IS - SO JUST LIKE, DEAL WITH THAT *)
(** 30 days as a Ptime *)
let login_time_update () = 
  let new_time = Ptime.of_float_s ((Unix.time ()) +. 2.592e+6) in 
  match new_time with
  | Some tm -> tm 
  | None -> Ptime.epoch
(** 24 hours as a Ptime *)
let post_ttl () = 
  let new_time = Ptime.of_float_s ((Unix.time ()) +. 86400.0) in 
  match new_time with
  | Some tm -> tm 
  | None -> Ptime.epoch
(** The current time as a Ptime *)
let ptime_now () =
  let today = Ptime.of_float_s (Unix.time ()) in 
  match today with
  | Some tm -> tm
  | None -> Ptime.epoch

(* WHNVR schema version 1.0.0 *)
let v_0_0_1 = VersionedSchema.version [0;0;1]
let v_0_0_2 = VersionedSchema.version [0;0;2]
let v_0_0_3 = VersionedSchema.version [0;0;3]

(* init the schema using the above version *)
let schema = VersionedSchema.init v_0_0_3 ~name:"whnvr"

(** Configurable page size for infinite scroll *)
let page_size = 100

(* TODO: Move individual table modules into separate files *)

module Dream_Session = struct
  let table, Expr.[id ; label ; expires_at ; payload] =
    VersionedSchema.declare_table schema ~name:"dream_session"
    Schema.[
      field ~constraints:[primary_key ()] "id" ~ty:Type.text ;
      field ~constraints:[not_null ()] "label" ~ty:Type.text ;
      field ~constraints:[not_null ()] "expires_at" ~ty:Type.real ;
      field ~constraints:[not_null ()] "payload" ~ty:Type.text ;
    ]
end

(* declare a table, returning the table name and fields *)
module Users = struct
  let table, Expr.[id ; username ; display_name ; expires ; secret ; bi_user_id] =
    VersionedSchema.declare_table schema ~name:"users"
      Schema.[
        field ~constraints:[primary_key ()] "id" ~ty:Type.big_serial ;
        field "username" ~ty:Type.(character_varying 32) ~constraints:[not_null ()] ; (* Beyond Identity handles this now *)
        field "display_name" ~ty:Type.(character_varying 32) ~constraints:[not_null ()] ; (* Beyond Identity handles this now *)
        field "expires" ~ty:Type.time ~constraints:[not_null ()] ;
        field "secret" ~ty:Type.bytea ; (* Beyond Identity handles this now *)
        field "bi_user_id" ~ty:Type.(character_varying 32) ;
      ]
      ~migrations:[
        v_0_0_2, [
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE users ALTER COLUMN expires SET DEFAULT (now() + '00:05:00'::interval) |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE users ALTER COLUMN expires TYPE character varying USING expires::character varying |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE users ALTER COLUMN expires TYPE timestamp without time zone USING expires::timestamp without time zone |sql} ;
        ] ;
        v_0_0_3, [
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE users ADD COLUMN bi_user_id CHARACTER VARYING |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE users ALTER COLUMN secret DROP NOT NULL |sql}
        ]
      ]
end

(* declare a table, returning the table name and fields *)
module Posts = struct
  let table, Expr.[id ; user_id ; message ; created ; expires] =
    VersionedSchema.declare_table schema ~name:"posts"
      Schema.[
        field ~constraints:[primary_key () ; not_null ()] "id" ~ty:Type.big_serial;
        field ~constraints:[foreign_key ~table:Users.table ~columns:Expr.[Users.id] () ; not_null ()] "user_id" ~ty:Type.big_int ;
        field "message" ~ty:(Type.character_varying 420) ~constraints:[not_null ()] ;
        field "created" ~ty:Type.time ~constraints:[not_null ()] ;
        field "expires" ~ty:Type.time ~constraints:[not_null ()] ;
      ]
      ~migrations:[v_0_0_2, [
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE posts ALTER COLUMN expires SET DEFAULT (now() + '1 day'::interval) |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE posts ALTER COLUMN expires TYPE character varying USING expires::character varying |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE posts ALTER COLUMN expires TYPE timestamp without time zone USING expires::timestamp without time zone |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE posts ALTER COLUMN created SET DEFAULT (now() + '00:00:00'::interval) |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE posts ALTER COLUMN created TYPE character varying USING created::character varying |sql} ;
          Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE posts ALTER COLUMN created TYPE timestamp without time zone USING created::timestamp without time zone |sql} ;
          (*Caqti_request.Infix.(Caqti_type.unit ->. Caqti_type.unit)
            {sql| ALTER TABLE posts ALTER COLUMN created TYPE time with time zone USING created::time with time zone |sql} ;*)
        ]]
end

module HydratedPost = struct
  type t = {
    id : int64 ;
    message : string ;
    username : string ;
    display_name : string ;
    created : Ptime.t ;
  }

  let decode
      (id,
        (username,
          (display_name,
            (message,
              (created, ()))))) = {
    id = id ;
    message ;
    username ;
    display_name ;
    created ;
  }
end

let find_user username db =
  let%lwt found = Query.select ~from:Users.table
  Expr.[
    Users.username ;
  ]
  |> Query.where Expr.( Users.username = s username )
  |> Request.make_zero_or_one
  |> Petrol.find_opt db in
  match found with
  | Ok user -> Lwt.return user
  | Error err -> Lwt.return (Some ((Caqti_error.show err), ()))

let give_user_bi_id whnvr_id beyond_identity_id db =
  Query.update ~table:Users.table ~set:Expr.[ Users.bi_user_id := vl ~ty:Type.(character_varying 32) beyond_identity_id ]
  |> Query.where Expr.( Users.id = vl ~ty:Type.big_int whnvr_id )
  |> Request.make_zero
  |> Petrol.exec db

let get_user_by_byndid byndid_id db =
  let%lwt found = Query.select ~from:Users.table
  Expr.[
    Users.id
  ]
  |> Query.where Expr.( Users.bi_user_id = s byndid_id)
  |> Request.make_zero_or_one
  |> Petrol.find_opt db in 
  match found with
  | Ok user -> Lwt.return user 
  | Error _ -> Lwt.return (Some (Int64.of_string "0", ()))

(** Creating a user only sets these key fields. Everything else is set dynamically elsewhere. *)
let create_user username display_name beyond_identity_id db =
  Query.insert ~table:Users.table ~values:(Expr.[
    Users.username := s username ;
    Users.display_name := s display_name ;
    Users.bi_user_id := s beyond_identity_id ;
  ])
  |> Request.make_zero
  |> Petrol.exec db

let authenticate username secret db =
  let sha3 = Hash.sha3 256 in
  let test_hash = hash_string sha3 secret in
  let%lwt found = Query.select [Users.id ; Users.username] ~from:Users.table
  |> Query.where Expr.( Users.username = s username )
  |> Query.where Expr.( Users.secret = s (hex_of_string test_hash) )
  |> Request.make_zero_or_one
  |> Petrol.find_opt db in
  match found with
  | Ok user_opt ->
      begin
        match user_opt with
        | Some (id, (username, _)) -> begin
          let%lwt _ = Query.update ~set:Expr.[ Users.expires := vl ~ty:Type.time (ptime_now ()) ] ~table:Users.table
        |> Query.where Expr.( Users.id = vl ~ty:Type.big_int id )
        |> Request.make_zero
        |> Petrol.exec db in
          Lwt.return (Some (Int64.to_string id, username))
        end
        | None -> Lwt.return None
      end
  | Error _ -> Lwt.return None

let create_post message user_id db =
  Query.insert ~table:Posts.table ~values:(Expr.[
    Posts.message := s message ;
    Posts.user_id := vl ~ty:Type.big_int user_id ;
    Posts.expires := vl ~ty:Type.time (post_ttl ()) ;
    Posts.created := vl ~ty:Type.time (ptime_now ()) ;
  ])
  |> Request.make_zero
  |> Petrol.exec db

(* This is a query which utilizes a workaround in Petrol with aliased fields for the join *)
let paginated_posts last_post_id db direction =
  let user_id, user_id_ref = Expr.as_ Users.id ~name:"joined_user_id" in
  let username, username_ref = Expr.as_ Users.username ~name:"username" in
  let display_name, display_name_ref = Expr.as_ Users.display_name ~name:"display_name" in
  Query.select 
    ~from:Posts.table 
    Expr.[
      Posts.id ;
      username_ref ;
      display_name_ref ;
      Posts.message ;
      Posts.created ;
    ]
  |> Query.join
    ~on:Expr.(Posts.user_id = user_id_ref)
    (
      Query.select
      ~from:Users.table
      Expr.[
        user_id ;
        username ;
        display_name ;
      ] 
    )
  |> Query.where Expr.(Posts.id < Expr.(vl ~ty:Type.big_int last_post_id))
  |> Query.where Expr.(Posts.expires > vl ~ty:Type.time (ptime_now ()) )
  |> Query.order_by ~direction Posts.id
  |> Query.limit Expr.(i page_size)
  |> Request.make_many
  |> Petrol.collect_list db
  |> Lwt_result.map (List.map HydratedPost.decode)

let last_posts_page post_id db = paginated_posts post_id db `ASC
let next_posts_page post_id db = paginated_posts post_id db `DESC

(* This is a query which utilizes a workaround in Petrol with aliased fields for the join *)
let fetch_posts db =
  let user_id, user_id_ref = Expr.as_ Users.id ~name:"joined_user_id" in
  let username, username_ref = Expr.as_ Users.username ~name:"username" in
  let display_name, display_name_ref = Expr.as_ Users.display_name ~name:"display_name" in
  Query.select 
    ~from:Posts.table 
    Expr.[
      Posts.id ;
      username_ref ;
      display_name_ref ;
      Posts.message ;
      Posts.created ;
    ]
  |> Query.join
    ~on:Expr.(Posts.user_id = user_id_ref)
    (
      Query.select
      ~from:Users.table
      Expr.[
        user_id ;
        username ;
        display_name ;
      ] 
    )
  |> Query.where Expr.(Posts.expires > vl ~ty:Type.time (ptime_now ()))
  |> Query.limit Expr.(i page_size) (* TODO: Up to 100 after testing *)
  |> Query.order_by Posts.id ~direction:`DESC
  |> Request.make_many
  |> Petrol.collect_list db
  |> Lwt_result.map (List.map HydratedPost.decode)

let print_fetch_posts =
  let user_id, user_id_ref = Expr.as_ Users.id ~name:"joined_user_id" in
  let username, username_ref = Expr.as_ Users.username ~name:"username" in
  let display_name, display_name_ref = Expr.as_ Users.display_name ~name:"display_name" in
  Query.select 
    ~from:Posts.table 
    Expr.[
      Posts.id ;
      username_ref ;
      display_name_ref ;
      Posts.message ;
      Posts.created ;
    ]
  |> Query.join
    ~on:Expr.(Posts.user_id = user_id_ref)
    (
      Query.select
      ~from:Users.table
      Expr.[
        user_id ;
        username ;
        display_name ;
      ] 
    )
  |> Query.where Expr.(Posts.expires > vl ~ty:Type.time (ptime_now ()))
  |> Query.limit Expr.(i page_size) (* TODO: Up to 100 after testing *)
  |> Query.order_by Posts.id ~direction:`DESC
  |> Format.asprintf "%a" Query.pp;;

let get_posts next_id db =
  match next_id with
  | Some id -> next_posts_page (Int64.of_string id) db
  | None -> fetch_posts db

exception EnvVarNotFound of string

let check_env_value var_name =
  match Sys.getenv_opt var_name with
  | Some _ -> true
  | None -> false

let get_env_value var_name =
  match Sys.getenv_opt var_name with
  | Some value -> value  
  | None -> raise (EnvVarNotFound ("Environment variable " ^ var_name ^ " not set"))

let db_driver () =
  match Sys.getenv_opt "DB_DRIVER" with
  | Some value -> value 
  | None -> "unset"



let check_connection_string () =
  (* Important note: These will throw `Not_found if the variables are not set, preventing execution *)
  let driver = check_env_value "DB_DRIVER" in
  let host = check_env_value "DB_HOST" in
  let port = check_env_value "DB_PORT" in
  let name = check_env_value "DB_NAME" in
  let user = check_env_value "DB_USER" in
  let pass = check_env_value "DB_PASS" in 
  driver && user && pass && host && port && name

(* I wonder what a test_connection function might look like... *)

let connection_string () =
  (* Important note: These will throw `Not_found if the variables are not set, preventing execution *)
  let driver = get_env_value "DB_DRIVER" in (* Example: postgresql *)
  let host = get_env_value "DB_HOST" in
  let port = get_env_value "DB_PORT" in
  let name = get_env_value "DB_NAME" in
  let user = get_env_value "DB_USER" in
  let pass = get_env_value "DB_PASS" in 
  driver ^ "://" ^ user ^ ":" ^ pass ^ "@" ^ host ^ ":" ^ port ^ "/" ^ name

(* I borrowed this function from github:gopiandcode/ocamlot *)
let init_database ?(force_migrations=false) path =
  let initialise =
    let open Lwt_result.Syntax in
    Caqti_lwt.with_connection path (fun conn ->
      let* needs_migration =
        Petrol.VersionedSchema.migrations_needed schema conn in
      Format.printf "needs migration: %b\n@." needs_migration;
      let* () =
        if needs_migration && not force_migrations
        then
          Lwt_result.fail
            (`Msg "migrations needed for local database - please \
                   re-run with suitable flags (-m). (You probably also \
                   want to backup your database file as well)")
        else Lwt_result.return () in
      Petrol.VersionedSchema.initialise schema conn
    ) in
  let version_to_string (ver: Petrol.VersionedSchema.version) =
    String.concat "." (List.map string_of_int (ver :> int list)) in
  match Lwt_main.run initialise with
  | Ok () -> Ok ()
  | Error (`Newer_version_than_supported version) ->
    Error (`Msg
             (
               "database uses newer version (" ^
               (version_to_string version) ^
               ") than supported"))
  | Error (#Caqti_error.t as err) ->
    Error (`Msg ("internal error: " ^ Caqti_error.show err))
  | Error (`Msg m) -> Error (`Msg m)

