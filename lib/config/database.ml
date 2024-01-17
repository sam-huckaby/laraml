let database_creds () = ["postgresql" , "localhost" , "postgres", ""]

(*
Laravel uses a defualting style where the user provides the name of the environment variable and then a default value if it isn't found
This is easy enough to do here, but I'm wondering what the advantages are to the default value structure. Surely the default user and pass
should never be used in a real world scenario, but maybe they are enough for development situations?
 *)
