open Tyxml_html

(* EVERY checklist item needs to have a link to documentation *)
let hello_content () =
  let db_connected = Database.check_connection_string () in
  let db_driver = Database.db_driver () in
  div ~a:[a_class ["w-full" ; "h-full" ; "flex flex-col justify-center items-center" ; "p-8" ; "text-base"]] [
    span ~a:[a_class ["text-2xl text-black"]] [txt "You don't need a landing page."] ;
    span ~a:[a_class ["font-extrabold text-transparent text-5xl bg-clip-text bg-gradient-to-r from-lime-400 to-rose-400"]] [txt "You need a launch platform."] ;
    img ~src:"/static/Spaceship_launch.png" ~alt:"A rocket ship blasting off" ~a:[a_height 300 ; a_width 300] () ;
    h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "Launch Checklist" ] ;
    div ~a:[a_class ["CHECKLIST w-[200px]" ; "flex flex-col justify-start items-start"]] [
      div ~a:[a_class ["flex flex-col justify-start items-center" ; "pb-4"]] [
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          (
            if db_connected then 
              span ~a:[a_class ["pr-4 text-green-600"]] [txt "✓"] 
            else 
              span ~a:[a_class ["pr-4 text-red-600"]] [txt "✗"] 
          ) ;
          span [ txt "Database Configured" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          (
            if db_driver = "postgresql" then 
              span ~a:[a_class ["pr-4 text-green-600"]] [txt "✓"] 
            else 
              span ~a:[a_class ["pr-4 text-red-600"]] [txt "✗"] 
          ) ;
          span [ txt "PostgreSQL" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ (
            if db_driver == "mysql" then txt "✓" else txt "✗"
          ) ] ;
          span [ txt "MySQL" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ (
            if db_driver == "sqlite" then txt "✓" else txt "✗"
          ) ] ;
          span [ txt "SQLite" ] ;
        ] ;
      ] ;
      (*
      div ~a:[a_class ["flex flex-col justify-start items-center" ; "pb-4"]] [
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "AUTH" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "USERS" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "TEAMS" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "PASSKEYS" ] ;
        ] ;
      ] ;
      div ~a:[a_class ["flex flex-col justify-start items-center" ; "pb-4"]] [
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "STYLES" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "TAILWIND" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "SCSS" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "CSS (global.css)" ] ;
        ] ;
      ] ;
      div ~a:[a_class ["flex flex-col justify-start items-center" ; "pb-4"]] [
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "CLIENT STATE" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "ALPINE" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "HYPERSCRIPT" ] ;
        ] ;
        div ~a:[a_class ["w-full" ; "flex flex-row justify-start items-center"]] [
          span ~a:[a_class ["pl-1 pr-4"]] [ txt "↳" ] ;
          span ~a:[a_class ["pr-4 text-red-600"]] [ txt "✗" ] ;
          span [ txt "React" ] ;
        ] ;
      ] ;
      *)
    ]
  ]
