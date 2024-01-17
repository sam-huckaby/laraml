open Tyxml
open Tyxml.Html

let submit =
    Html.[input ~a:[ a_input_type `Submit ; a_class Theme.button_styles ; a_value "Submit"] () ]

(*********************************************************************************************)
(*                                        error page                                         *)
(* This takes a list of posts that have been retrieved from the database and formats them to *)
(* look like standard social media tiles using TailwindCSS and the magic of friendship.      *)
(*********************************************************************************************)
(* In a perfect world, this should just be a component and not a full HTML document *)
let error_page message =
  Router.build_page (
    html 
    (head (title (txt "Error!")) [
      link ~rel:[`Stylesheet] ~href:"/static/build.css" () ;
      script ~a:[a_src (Xml.uri_of_string "/static/htmx.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/_hyperscript.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/helpers.js")] (txt "") ;
    ])
    (body [
      div ~a:[a_class ["bg-orange-600/50" ; "rounded" ; "w-full" ; "h-full" ; "flex" ; "flex-col" ; "p-8"]] [
        h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "That Seems Like A Problem" ] ;
        div ~a:[a_class ["p-4"]] [
          txt "This is the error page. If you've reached it, then you must have had a problem. I would go back if I were you." ;
        ] ;
        pre ~a:[a_class ["p-4" ; "bg-red-600" ; "whitespace-pre-wrap"]] [
          txt (String.concat " \n " (String.split_on_char '\n' message))
        ] ;
        div ~a:[a_class ["p-4"]] [
          txt "Just use the back button in your browser, like normal." ;
        ] ;
      ]
    ])
  )

