(* Database configurations all flow from this file *)

(*
Laravel uses a defualting style where the user provides the name of the environment variable and then a default value if it isn't found
This is easy enough to do here, but I'm wondering what the advantages are to the default value structure. Surely the default user and pass
should never be used in a real world scenario, but maybe they are enough for development situations?
 *)

type db_conn_details = { driver : string; host : string; port : string; name : string; user : string; pass : string }
type db_conn = { name : string; details : db_conn_details }

(* The user should be able to configure multiple DB connections *)
(* Not sure yet how this looks, but the idea is that users can use multiple DBs in tandem, *)
(* like redis for session management and postgresql for user management *)
let connections () = [
        {
                name = "PostgreSQL" ;
                details = {
                        driver = Utils.env_or_default "DB_DRIVER" "postgresql" ;
                        host = Utils.env_or_default "DB_HOST" "localhost" ;
                        port = Utils.env_or_default "DB_PORT" "5432" ;
                        name = Utils.env_or_default "DB_NAME" "laraml" ;
                        user = Utils.env_or_default "DB_USER" "postgres" ;
                        pass = Utils.env_or_default "DB_PASS" "" ;
                } ;
        } ;
        {
                name = "MySQL" ;
                details = {
                        driver = Utils.env_or_default "DB_DRIVER" "mysql" ;
                        host = Utils.env_or_default "DB_HOST" "localhost" ;
                        port = Utils.env_or_default "DB_PORT" "5432" ;
                        name = Utils.env_or_default "DB_NAME" "laraml" ;
                        user = Utils.env_or_default "DB_USER" "admin" ;
                        pass = Utils.env_or_default "DB_PASS" "" ;
                } ;
        } ;
]

(* Function to construct the connection string *)
let construct_connection_string details =
    Printf.sprintf "%s://%s:%s@%s:%s/%s"
        details.driver
        details.user
        details.pass
        details.host
        details.port
        details.name

(* Modified function to find a connection by name and return its connection string *)
let get_connection name =
    let conns = connections () in
    match List.find_opt (fun conn -> conn.name = name) conns with
    | Some conn -> Some (construct_connection_string conn.details)
    | None -> None

(*
let get_connection name =
    let conns = connections () in
    try 
        Some (List.find (fun conn -> conn.name = name) conns).details
    with
    | Not_found -> None
*)

