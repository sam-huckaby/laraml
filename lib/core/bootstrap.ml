(* Here we initialize and launch the app *)
(* Everything that needs to happen at launch time must be kicked off from this file *)

(* Run any DB migrations *)
let init_database () = match Database.check_connection_string () with
  | true -> (
    (* Not every app needs a DB - some may use headless CMS or just be static *)
    (* Need to conditionally check if the environment variables are set and NOT attempt init if they are not *)
    match Database.init_database ~force_migrations:true (Uri.of_string @@ Database.connection_string ()) with
    | Error (`Msg err) -> Some (Format.sprintf "Error: %s" err)
    | Ok () -> None
  )
  | false -> None

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
  match init_database () with
  | Some err -> Format.printf "Error: %s" err
  | None -> start_server ();

