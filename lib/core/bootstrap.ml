(* Here we initialize and launch the app *)
(* Everything that needs to happen at launch time must be kicked off from this file *)

(* Initialize DB connection and optionally Run any migrations *)
let init_databases force_migrations =
  let results = [
    ("PostgreSQL", Database.init_postgresql force_migrations) ;
    (* ("SQLite", Database.init_sqlite force_migrations) ; *)
    (* ("MySQL", Database.init_mysql force_migrations) ; *)
  ] in
  List.fold_left (fun acc (db_name, init_func) ->
    match acc with
    | Some _ -> acc  (* If an error already occurred, skip further initializations *)
    | None ->
      match Config.Database.get_connection db_name with
      | Some _ ->
        (match init_func with
        | Error (`Msg err) -> Some (Format.sprintf "Error initializing %s: %s" db_name err)
        | Ok () -> None)
      | None -> None  (* Skip initialization if environment variables are not set *)
  ) None results

(* Start Dream *)
let start_server () =
  Dream.run ~interface:"0.0.0.0"
    @@ Dream.logger
    (* Why does livereload not work like the docs show? *)
    (*@@ Dream.livereload*)

    (* If there is a DB configured, use that for the pool, otherwise don't use a pool *)
    @@ (if Database.check_connection_string () then
          Dream.sql_pool (Database.connection_string ()) 
        else
          Dream.no_middleware)
    (* If there is a DB configured, use that for sessions, otherwise use in-memory sessions *)
    @@ (if Database.check_connection_string () then
          Dream.sql_sessions ~lifetime:2.592e+6 
        else
          Dream.memory_sessions ~lifetime:2.592e+6)
    (* Configure all the routes used by the app *)
    @@ Dream.router (
      [
        Dream.scope "/" [] App.Router.pages ;
        Dream.scope "/api" [] App.Router.api ;

        (* Serve any static content we may need, maybe stylesheets? *)
        (* This local_directory path is relative to the location the app is run from *)
        Dream.get "/static/**" @@ Dream.static "www/static" ;
      ]
    )

(* Spin up the Riot scheduler/worker processes here? *)

(* Start the entire app *)
let launch () =
  (* Load environment variables into memory *)
  Dotenv.export () |> ignore;
  (* Confirm that the database is configured or not used *)
  match init_databases true with
  | Some err -> Format.printf "Error: %s" err
  | None -> start_server ();

