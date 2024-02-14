open Riot

type Message.t += Usage_info

type Message.t += Init of string
type Message.t += Add
(* Should I namespace sub-commands underneath Add? *)
(*
type Message.t += Add_Database
type Message.t += Add_Migration
type Message.t += Add_View
type Message.t += Add_Job
type Message.t += Add_Route
*)
type Message.t += Start
type Message.t += Migrate

(*
Probably need to create separate modules for each of the four main action types (Init, Add, Start, Migrate)

This really isn't the desired flow, since this is all directly in a Riot process, and realistically we want to
start Mint Tea and check which action the user is trying to perform. Then, Mint Tea can invoke main methods
for each of the actions to spin up separate Riot processes to handle these tasks. 

This is especially true for the start command, since it will spawn processes that are long-living to support
the entire app (database handlers, web server, job queue, etc)
 *)

(*let rec handler () =*)
let handler () =
  (match receive () with
  | Usage_info -> Printf.printf "Usage: %s [init|start|add|migrate] args...\n" Sys.argv.(0)
  | Init project_name -> print_endline ("Creating project \"" ^ project_name ^ "\"...")
  | Add -> print_endline "Hello Add"
  | Start -> print_endline "Hello Start"
  | Migrate -> print_endline "Hello Migrate"
  | _ -> print_endline "It turns out that not every piece fits in the puzzle D:")
(*  handler ()*)

let () = 
        Riot.run @@ fun () ->
                let pid = spawn (handler) in
                let command = Sys.argv.(1) in
                (
                match command with
                | "init" -> (
                        if Array.length Sys.argv != 3 then Printf.printf "Usage: %s init [project-name]" Sys.argv.(0)
                        else send pid (Init Sys.argv.(2))
                )
                | "start" -> send pid Start
                | "add" -> send pid Add
                | "migrate" -> send pid Migrate
                | _ -> send pid Usage_info
                ); 
                wait_pids [ pid ];
                shutdown ()

(*
        Mosaic
        - init [project name] (The entire app should run and be viable after just running this command, no DB required)
        - add [database | migration | view | job | route ]
        - start
                - Create a Riot process for Dream
                - Create a Riot process for each Database handler
                - Create a Riot process for log management?
        - migrate [--fresh] [database] (should this just always migrate every DB?) (Fresh flag dumps the DB and starts from scratch)
*)

(*
open Riot
open Minttea
open Leaves

(* Memory references used throughout the CLI *)
let ref = Riot.Ref.make ()
let download_ref = Riot.Ref.make ()
let finished_ref = Riot.Ref.make ()

(* Stylistic elements from Spices package *)
let dot = Spices.(default |> fg (color "236") |> build) " • "
let subtle fmt = Spices.(default |> fg (color "241") |> build) fmt
let keyword fmt = Spices.(default |> fg (color "211") |> build) fmt
let highlight fmt = Spices.(default |> fg (color "#FF06B7") |> build) fmt

(* Model types for the various screens *)
type selection_screen = { 
  selected : int; 
  options : string list; 
  timeout : int 
}
type reading_screen = {
  timeout : int;
  progress : Progress.t;
  spinner : Sprite.t;
  finished : bool;
}

type init_screen = { 
  name: string;
}

(*
Possible future screens:
  - init_screen
  - start_screen
  - add_screen
 *)

(* Function to take a screen and increment the current selection *)
let select_next screen =
  let option_count = List.length screen.options in
  let selected = screen.selected + 1 in
  let selected = if selected >= option_count then 0 else selected in
  { screen with selected }

(* Function to take a screen and decrement the current selection *)
let select_prev screen =
  let option_count = List.length screen.options in
  let selected = screen.selected - 1 in
  let selected = if selected < 0 then option_count - 1 else selected in
  { screen with selected }

type section =
  | Init_screen of init_screen
  | Selection_screen of selection_screen
  | Reading_screen of reading_screen

(* Exception raised if a screen that does not exist is somehow selected *)
exception Invalid_transition

(* This is the function that handles a selection on a screen *)
(* Each screen should have exactly one choice to make *)
let transition screen =
  match screen with
  | Init_screen _name ->
      ( Reading_screen
        {
          timeout = 5;
          progress = 
            Progress.make ~width:50
              ~color:
                (`Gradient (Spices.color "#ffb14f", Spices.color "#a300ff"))
                ();
          finished = false;
          spinner = Spinner.globe;
        },
        Command.Set_timer (download_ref, 0.5) )
  | Selection_screen _select ->
      ( Reading_screen
          {
            timeout = 5;
            progress =
              Progress.make ~width:50
                ~color:
                  (`Gradient (Spices.color "#b14fff", Spices.color "#00ffa3"))
                ();
            finished = false;
            spinner = Spinner.globe;
          },
        Command.Set_timer (download_ref, 0.5) )
  | _ -> raise Invalid_transition

(* Model is typed to keep track of whether the user has quit and the current section of the app it is in *)
type model = { quit : bool; section : section }

(* The init function waits for 1 second before starting the countdown timer *)
let init _ = Command.Set_timer (ref, 1.)

(* The initial model is the starting point of the model every time this program is run *)
let initial_model =
  {
    quit = false;
    section =
      Init_screen
        {
          name = "";
        };
  }
(*
let initial_model =
  {
    quit = false;
    section =
      Selection_screen
        {
          timeout = 9;
          selected = 0;
          options =
            [
              "Plant carrots";
              "Go to the market";
              "Read something";
              "See friends";
            ];
        };
  }
*)

(* Create an exception called Exit that will be used to exit the program? *)
exception Exit

let update event model =
  try
    if event = Event.KeyDown (Key "q") then raise Exit
    else
      let section, cmd =
        match model.section with
        | Init_screen _ -> (
          match event with
          | _ -> (model.section, Command.Noop)
          )
        | Reading_screen screen -> (
            match event with
            | Event.Frame now ->
                let spinner = Sprite.update ~now screen.spinner in
                (Reading_screen { screen with spinner }, Command.Noop)
            | Event.Timer ref when screen.finished && Ref.equal ref finished_ref
              ->
                let timeout = screen.timeout - 1 in
                if timeout = 0 then raise Exit
                else
                  ( Reading_screen { screen with timeout },
                    Command.Set_timer (finished_ref, 1.) )
            | Event.Timer ref
              when (not screen.finished) && Ref.equal ref download_ref ->
                let progress = Progress.increment screen.progress 0.03 in
                let finished = Progress.is_finished progress in
                ( Reading_screen { screen with progress; finished },
                  if finished then Command.Set_timer (finished_ref, 1.)
                  else Command.Set_timer (download_ref, 0.1) )
            | _ -> (model.section, Command.Noop))
        | Selection_screen screen -> (
            match event with
            | Event.KeyDown Space -> transition model.section
            | Event.KeyDown (Key "j" | Down) ->
                (Selection_screen (select_next screen), Command.Noop)
            | Event.KeyDown (Key "k" | Up) ->
                (Selection_screen (select_prev screen), Command.Noop)
            | Event.Timer ref ->
                let timeout = screen.timeout - 1 in
                if timeout = 0 then raise Exit
                else
                  ( Selection_screen { screen with timeout },
                    Command.Set_timer (ref, 1.) )
            | _ -> (model.section, Command.Noop))
      in
      ({ model with section }, cmd)
  with Exit -> ({ model with quit = true }, Command.Quit)

(*
This function draws the screen. It takes the current model and maps it to the current
state of execution and then displays the appropriate place in the sequence.
For instance, when the program first starts, it displays the Selection_screen and when
a selection is made, it transitions to a new screen (originally the Reading_screen)
 *)
let view model =
  if model.quit then "Bye 👋🏼"
  else
    match model.section with
    | Init_screen screen ->
        Format.sprintf 
          {|
Starting a new Project.

What would you like to call this project? %s
          |}
          screen.name 
    | Reading_screen screen when screen.finished ->
        Format.sprintf
          {|Reading time?

            Okay, cool, then we'll need a library! Yes, an %s.

            Done, waiting %d seconds before exiting... %s
          |}
          (keyword "actual library") screen.timeout
          (Sprite.view screen.spinner)
    | Reading_screen screen ->
        Format.sprintf
          {|Reading time?

            Okay, cool, then we'll need a library! Yes, an %s.

            %s
          |}
          (keyword "actual library")
          (Progress.view screen.progress)
    | Selection_screen screen ->
        let choices =
          List.mapi
            (fun idx choice ->
              let checked = idx = screen.selected in
              let checkbox = Leaves.Forms.checkbox ~checked choice in
              if checked then highlight "%s" checkbox else checkbox)
            screen.options
          |> String.concat "\n  "
        in
        let help =
          subtle "j/k: select" ^ dot ^ subtle "space: choose" ^ dot
          ^ subtle "q: quit"
        in

        Format.sprintf
          {|What should we do today?

            %s

            Program quits in %d seconds

            %s
          |} choices screen.timeout help

let () = Minttea.app ~init ~update ~view () |> Minttea.start ~initial_model
*)
