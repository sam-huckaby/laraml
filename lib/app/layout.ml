open Tyxml_html

let compile_elt elt = Format.asprintf "%a" (Tyxml.Html.pp_elt ()) elt
let compile_elt_list elt = List.fold_left (fun acc s -> acc ^ s) "" (List.map (fun x -> Format.asprintf "%a" (Tyxml.Html.pp_elt ()) x) elt)

(*********************************************************************************************)
(*                                      root layout                                          *)
(* This is the main page wrapping function. Every page will go through this function so that *)
(* it gets the necessary 3rd party scripts and styles that are used site-wide. Ultimately    *)
(* The scripts loaded here need to be moved into the stack and have cache control configured *)
(* so that they aren't being loaded on every page refresh.                                   *)
(* @param {string} title - The page title that will be applied to the HTML document          *)
(* @param {[< html_types.flow5 ] elt} content - The content for the page, layout pre-applied *)
(*********************************************************************************************)
let root page_title content =
  html ~a:[a_class ["min-h-full"] ; a_lang "en" ]
    (head (title (txt page_title)) [
      meta ~a:[a_name "viewport" ; a_content "width=device-width, initial-scale=1"] () ;
      link ~rel:[`Stylesheet] ~href:"/static/build.css" () ;
      script ~a:[a_src (Xml.uri_of_string "/static/htmx.min.js")] (txt "") ;
      script ~a:[a_src (Xml.uri_of_string "/static/_hyperscript.min.js")] (txt "") ;
    ])
    (body ~a:[a_class [
      "min-h-full" ;
      "text-neutral-900 dark:text-neutral-100" ;
    ]] [content])

(* TODO: Write real documentation below *)
(*********************************************************************************************)
(*                                    centered layout                                        *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} header - The element that will be displayed at the top *)
(* @param {[< html_types.flow5 ] elt} content - The content for the page,                    *)
(*********************************************************************************************)
let centered content =
  div ~a:[a_class ["min-w-[100%] min-h-[100vh]" ; "flex flex-col justify-start items-center" ; "relative -z-20" ; "bg-gray-800"]] [
    div ~a:[a_class ["fixed top-0 right-0 bottom-0 left-0 -z-10"] ; a_style "background: linear-gradient(120deg, rgba(202,242,154,0.5) 0%, rgba(164,253,45,0) 50%);"] [] ;
    div ~a:[a_class ["fixed top-0 right-0 bottom-0 left-0 -z-10"] ; a_style "background: linear-gradient(180deg, rgba(154,205,242,0.5) 0%, rgba(164,253,45,0) 50%);"] [] ;
    div ~a:[a_class ["fixed top-0 right-0 bottom-0 left-0 -z-10"] ; a_style "background: linear-gradient(240deg, rgba(242,154,188,0.5) 0%, rgba(60,253,45,0) 50%);"] [] ;
    div ~a:[a_class ["relative z-10"]] [content] ;
  ]

(* TODO: Write real documentation below *)
(*********************************************************************************************)
(*                                    content layout                                         *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} header - The element that will be displayed at the top *)
(* @param {[< html_types.flow5 ] elt} content - The content for the page,                    *)
(*********************************************************************************************)
let content header content =
  div ~a:[a_class ["flex flex-col"]] [
    div ~a:[a_class ["flex justify-center items-center" ; "h-32"]] [header] ;
    div ~a:[a_class ["flex flex-row grow justify-center items-center"]] [
      div ~a:[a_class ["w-[10%]"]] [] ;
      div ~a:[a_class ["grow" ; "w-[80%] rounded border border-solid border-whnvr-300 dark:border-whnvr-800" ; "bg-whnvr-200 dark:bg-whnvr-900" ; "drop-shadow-md"]] [content] ;
      div ~a:[a_class ["w-[10%]"]] [] ;
    ]
  ]

(* TODO: Write real documentation below *)
(*********************************************************************************************)
(*                                     infinite layout                                       *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} left_content - The content shown in the left pane,     *)
(*                                                   usually a nav or something.             *)
(* @param {[< html_types.flow5 ] elt} middle_content - The main page content                 *)
(* @param {[< html_types.flow5 ] elt} right_content - The content shown in the right pane,   *)
(*                                                    which is usually... something.         *)
(*********************************************************************************************)
let three_column left_content middle_content right_content =
  div ~a:[a_class ["flex" ; "flex-row"]] [
    div ~a:[a_class ["flex" ; "flex-col" ; "grow"]] [left_content] ;
    div ~a:[a_class ["flex" ; "flex-col" ; "w-[525px]" ; "px-4" ; "mx-4"]] [middle_content] ;
    div ~a:[a_class ["flex" ; "flex-col" ; "grow"]] [right_content] ;
  ]

(* TODO: Write real documentation below *)
(*********************************************************************************************)
(*                                     standard layout                                       *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} left_content - The content shown in the left pane,     *)
(*                                                   usually a nav or something.             *)
(* @param {[< html_types.flow5 ] elt} middle_content - The main page content                 *)
(* @param {[< html_types.flow5 ] elt} right_content - The content shown in the right pane,   *)
(*                                                    which is usually... something.         *)
(*********************************************************************************************)
let standard _ main_content =
  div ~a:[a_class ["dark:bg-whnvr-800" ; "flex" ; "flex-row" ; "absolute top-0 right-0 bottom-0 left-0" ; "overflow-hidden"]] [
    div ~a:[a_class ["p-4" ; "grow" ; "overflow-auto" ; "pb-[100px] lg:pb-0"]] [main_content] ;
    button ~a:[
      a_class [
        "absolute bottom-8 right-8 z-100" ; 
        "border border-whnvr-900 rounded-full" ;
        "bg-whnvr-300 dark:bg-whnvr-500 shadow-lg" ;
        "h-[75px] w-[75px]" ;
        "text-3xl text-neutral-900" ;
      ] ;
      Utils.a_hx_typed Target ["#feed_side_menu"] ;
      Utils.a_hx_typed Swap ["outerHTML"] ;
      Utils.a_hx_typed Get ["/menu-open"] ;
    ] [ txt "☰" ] ;
    (* Menu visibility always starts false and is toggled into view by the button *)
    (*(Builder.standard_menu request false) ;*) (* TODO: Maybe put something back in here, or just delete the whole layout *)
  ]

(* TODO: Write real documentation below *)
(*********************************************************************************************)
(*                                        feed layout                                        *)
(* This is the layout to be used with a standard content page. It features a large upper div *)
(* that is sometimes called a "jumbotron" in other systems. Anything can go here, but        *)
(* normally it's like a line of text and a background picture or something.                  *)
(* @param {[< html_types.flow5 ] elt} left_content - The content shown in the left pane,     *)
(*                                                   usually a nav or something.             *)
(* @param {[< html_types.flow5 ] elt} middle_content - The main page content                 *)
(* @param {[< html_types.flow5 ] elt} right_content - The content shown in the right pane,   *)
(*                                                    which is usually... something.         *)
(*********************************************************************************************)
(* TODO: maybe just get rid of this layout? It isn't really a base layout
let feed request =
  div ~a:[a_class ["flex flex-col" ; "w-full" ; "items-center"]] [
    Builder.post_form request ;
    div ~a:[
      a_id "feed_container" ;
      a_class ["py-4 px-4 lg:px-0" ; "w-full" ; "lg:max-w-[700px]"] ;
    ] [
      div ~a:[
        a_class ["flex flex-col items-center gap-4"] ;
        Utils.a_hx "get" ["/posts"] ;
        Utils.a_hx_typed Trigger ["load"] ;
        Utils.a_hx "swap" ["innerHTML"] ;
        a_id "posts_container" ;
      ] []
    ]
  ]
*)

