(*
An HTMX builder that constructions components for use
in various parts of the app.
*)

open Tyxml_html

let post_form request =
  div ~a:[
    a_class ["py-4 px-4 lg:px-0" ; "w-full" ; "lg:max-w-[700px]"] ;
    a_id "post_submit_form" ;
    Utils.a_hx_typed Get ["/postForm"] ;
    Utils.a_hx_typed Trigger ["invalidCSRF_reloadForm"] ;
    Utils.a_hx_typed Swap ["outerHTML"] ;
  ] [
    form ~a:[
        Utils.a_hx_typed Post [Xml.uri_of_string "/posts"] ;
        Utils.a_hx_typed Target ["#posts_container"] ;
        Utils.a_hx_typed Swap ["innerHTML"] ;
        Utils.a_hx_typed Hx_ ["on htmx:afterRequest reset() me"]
    ] [
      (Dream.csrf_tag request) |> Unsafe.data ;
      textarea ~a:[
        a_class [
          "w-full h-[100px]" ;
          "bg-whnvr-300 dark:bg-whnvr-700" ;
          "border-whnvr-600 dark:border-whnvr-400" ;
          "p-2" ;
        ] ;
        a_name "message" ;
        a_id "post_message_input" ;
        a_required () ;
        a_placeholder "The void is listening, what will you say?" ;
        a_maxlength 420 ;
      ] (txt "") ;
      input ~a:[
        a_class (Theme.button_styles @ ["w-full" ; "mt-4 lg:mt-0" ; "py-2" ; "hover:bg-whnvr-300" ; "disabled:hover:bg-whnvr-800 disabled:hover:cursor-not-allowed"]) ;
        a_input_type `Submit ;
        a_disabled () ;
        Utils.a_hx_typed Hx_ [
          "on keyup from closest <form/>" ;
            "for elt in <*:required/>" ;
              "if the elt's value.length is less than 1" ;
                "add @disabled then exit" ;
              "end" ;
            "end" ;
          "remove @disabled"
        ] ;
        a_value "Post" ;
      ] ()
    ] ;
    (*script ~a:[a_src (Xml.uri_of_string "/static/feed_handlers.dist.js")] (txt "") ;*)
  ]

let passkey_list rm = 
  let loader = match rm with
    | true -> script ~a:[a_src (Xml.uri_of_string "/static/list_passkeys_to_delete.dist.js")] (txt "")
    | false -> script ~a:[a_src (Xml.uri_of_string "/static/load_passkeys.dist.js")] (txt "") in
    div ~a:[a_class [
      "w-full py-2 mt-2 max-full lg:max-w-[400px]" ;
      "shadow-inner" ;
      "flex flex-col items-center justify-start" ;
      "max-h-[500px] lg:max-h-[350px] min-h-[200px] lg:min-h-[75px] overflow-auto" ;
    ] ; a_id "passkey_container" ] [
      div ~a:[
        a_class [
          "rounded-full border-2 border-whnvr-800 dark:border-whnvr-300 border-t-transparent dark:border-t-transparent border-solid animate-spin" ;
          "w-[50px] h-[50px]" ;
        ] ;
        a_id "passkey_loader" ;
      ] [] ;
      loader ;
    ] 

let account_form request =
    form ~a:[
      a_class ["flex flex-col justify-center items-center w-full"] ;
      Utils.a_hx_typed Post ["/enroll"] ;
      Utils.a_hx_typed ReplaceUrl ["/login"] ;
      a_name "login_form" ;
    ] [
      h1 ~a:[a_class ["text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
      p ~a:[a_class ["text-center" ; "text-base" ; "pt-2"]] [ txt "Join us" ] ;
      (Dream.csrf_tag request) |> Unsafe.data ;
      div ~a:[a_class ["p-4" ; "flex" ; "flex-col" ; "w-full"] ; a_id "enroll_form"] [
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class (Theme.input_styles @ [
            "mb-8 lg:mb-2" ;
          ]) ;
          a_name "username" ;
          a_placeholder "username" ;
        ] () ;
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class (Theme.input_styles @ [
            "mb-4 lg:mb-0"
          ]) ;
          a_name "email" ;
          a_placeholder "email" ;
        ] () ;
      ] ;
      div ~a:[a_class ["p-4 flex flex-row justify-around w-full lg:max-w-[300px]"] ; a_id "continue_button"] [
        a ~a:[a_class Theme.button_styles ; a_href "/login"] [ txt "Back to login" ] ;
        input ~a:[
          a_input_type `Submit ;
          a_class Theme.button_styles ;
          a_value "Continue" ;
          a_disabled () ;
          Utils.a_hx_typed Hx_ [
            "on keyup from closest <form/>" ;
              "for elt in <*:required/>" ;
                "if the elt's value.length is less than 5" ;
                  "add @disabled then exit" ;
                "end" ;
              "end" ;
            "remove @disabled"
          ]
        ] () ;
      ] ;
    ]

let password_destroyer request =
    form ~a:[
      a_class ["flex flex-col justify-center items-center w-full"] ;
      Utils.a_hx_typed Post ["/passkey-upgrade"] ;
      Utils.a_hx_typed ReplaceUrl ["/login"] ;
      a_name "login_form" ;
    ] [
      h1 ~a:[a_class ["mt-4 text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
      p ~a:[a_class ["text-center" ; "text-base" ; "pt-2"]] [ txt "WHNVR has migrated to using passkeys as a more secure login method." ] ;
      p ~a:[a_class ["text-center" ; "text-base" ; "pt-2"]] [ txt "This form will convert your password to a passkey on this device." ] ;
      (Dream.csrf_tag request) |> Unsafe.data ;
      div ~a:[a_class ["p-4" ; "flex" ; "flex-col" ; "w-full"] ; a_id "enroll_form"] [
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class (Theme.input_styles @ [
            "mb-2" ;
          ]) ;
          a_name "username" ;
          a_placeholder "username" ;
        ] () ;
        input ~a:[
          a_input_type `Password ;
          a_required () ;
          a_class (Theme.input_styles @ [
            "mb-2" ;
          ]) ;
          a_name "password" ;
          a_placeholder "password" ;
        ] () ;
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class Theme.input_styles ;
          a_name "email" ;
          a_placeholder "email" ;
        ] () ;
        span ~a:[a_class ["text-whnvr-600 dark:text-whnvr-300" ; "text-base"]] [ txt "Needed for account recovery and extension" ]
      ] ;
      div ~a:[a_class ["p-4 flex flex-row justify-around w-full lg:max-w-[400px]"] ; a_id "continue_button"] [
        a ~a:[a_class Theme.button_styles ; a_href "/login"] [ txt "Back to login" ] ;
        input ~a:[
          a_input_type `Submit ;
          a_class Theme.button_styles ;
          a_value "Convert to passkey" ;
          a_disabled () ;
          Utils.a_hx_typed Hx_ [
            "on keyup from closest <form/>" ;
              "for elt in <*:required/>" ;
                "if the elt's value.length is less than 5" ;
                  "add @disabled then exit" ;
                "end" ;
              "end" ;
            "remove @disabled"
          ]
        ] () ;
      ] ;
    ]

let login_dialog request =
  let error = Dream.query request "error" in 
  let err = match error with
            | Some err -> err
            | None -> "" in
  div ~a:[
    a_class [
      "rounded" ;
      "w-full h-full" ;
      "flex flex-col items-center justify-center" ;
      "p-8"
    ] ;
    a_id "main_login_container"
  ] [
    h1 ~a:[a_class ["text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
    p ~a:[a_class ["text-center text-base" ; "pt-2"]] [ txt "Who will be screaming into the void today?" ] ;
    p ~a:[a_class ["text-center text-base text-red-600 font-bold" ; "pt-2"] ; a_id "login_error_msg"] [ txt err ] ;
    (* Passkey tiles are loaded into this div *)
    passkey_list false ;
    a ~a:[
      a_class ["my-4 underline hover:no-underline cursor-pointer text-base"] ;
      a_id "password_destroyer_link" ;
      Utils.a_hx_typed Get ["/upgrade-to-passkey"] ;
      Utils.a_hx_typed Target ["#main_login_container"] ;
      Utils.a_hx_typed Swap ["outerHTML"] ;
    ] [ txt "I have a password" ] ;
    div ~a:[a_class ["w-full flex flex-col lg:flex-row flex-wrap justify-center items-center"] ; a_id "login_links"] [
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        a ~a:[a_href (Xml.uri_of_string "/hello") ; a_class ["underline hover:no-underline"]] [ txt "What is this place?" ]
      ] ;
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        a ~a:[a_href (Xml.uri_of_string "/extend") ; a_class ["underline hover:no-underline"]] [ txt "I don't see my account" ] ;
      ] ;
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        button ~a:[
          a_class ["underline hover:no-underline"] ;
          a_id "delete_passkey_link" ;
          Utils.a_hx_typed Get ["/delete-passkey"] ;
          Utils.a_hx_typed Target ["#passkey_container"] ;
          Utils.a_hx_typed Swap ["outerHTML"] ;
        ] [ txt "Delete a passkey" ] ;
      ] ;
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        button ~a:[
          a_class ["underline hover:no-underline"] ;
          Utils.a_hx_typed Get ["/create-account"] ;
          Utils.a_hx_typed Target ["#main_login_container"] ;
          Utils.a_hx_typed Swap ["innerHTML"] ;
        ] [ txt "Create an account" ] ;
      ] ;
    ] ;
    div ~a:[a_class ["flex flex-row flex-wrap justify-center items-center w-full" ; "hidden"] ; a_id "delete_links"] [
      div ~a:[a_class ["w-full lg:w-1/2 my-4 flex flex-row justify-center items-center text-base"]] [
        a ~a:[a_href (Xml.uri_of_string "/login") ; a_class ["underline hover:no-underline"]] [ txt "Back to login" ]
      ] ;
    ] ;
  ]

let extend_dialog request =
  div ~a:[
    a_class [
      "flex flex-col justify-center items-center" ;
      "w-full h-full" ;
      "p-8" ;
    ] ;
  ] [
    form ~a:[
      a_class [
        "flex flex-col justify-center items-center" ;
        "w-full h-full" ;
      ] ;
      Utils.a_hx_typed Post ["/extend-passkey"] ;
      Utils.a_hx_typed Swap ["innerHTML"] ;
      a_name "extend_form" ;
    ] [
      h1 ~a:[a_class ["mt-4 text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
      p ~a:[a_class ["text-center text-base" ; "pt-2"]] [ txt "Extend your account to this device with a new passkey." ] ;
      div ~a:[a_class ["p-4" ; "flex" ; "flex-col" ; "w-full"] ; a_id "enroll_form"] [
        (Dream.csrf_tag request) |> Unsafe.data ;
        input ~a:[
          a_input_type `Text ;
          a_required () ;
          a_class (Theme.input_styles @ [
            "mb-4 lg:mb-0"
          ]) ;
          a_name "email" ;
          a_placeholder "email" ;
        ] () ;
      ] ;
      div ~a:[a_class ["p-4 flex flex-row justify-around w-full lg:max-w-[300px]"] ; a_id "continue_button"] [
        a ~a:[a_class Theme.button_styles ; a_href "/login"] [ txt "Back to login" ] ;
        input ~a:[
          a_input_type `Submit ;
          a_class Theme.button_styles ;
          a_value "Continue" ;
          a_disabled () ;
          Utils.a_hx_typed Hx_ [
            "on keyup from closest <form/>" ;
              "for elt in <*:required/>" ;
                "if the elt's value.length is less than 5" ;
                  "add @disabled then exit" ;
                "end" ;
              "end" ;
            "remove @disabled"
          ]
        ] () ;
      ] ;
    ]
  ]

let extension_result_form request user_email =
  form ~a:[
    a_class [
      "flex flex-col justify-center items-center" ;
      "w-full h-full" ;
    ] ;
    a_id "otp_completion_form" ;
    Utils.a_hx_typed Post ["/extend-complete"] ;
    Utils.a_hx_typed Trigger ["completeOTP"] ; (* This form is no longer submitted via the submit *)
    Utils.a_hx_typed Vals ["js:{passkeyBindingToken: event.detail.passkeyBindingToken}"] ;
    Utils.a_hx_typed Swap ["innerHTML"] ;
  ] [
    h1 ~a:[a_class ["mt-4 text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
    p ~a:[a_class ["text-center text-base" ; "mb-2"]] [ txt "Please enter the One-time password that was emailed to you" ] ;
    (Dream.csrf_tag request) |> Unsafe.data ;
    input ~a:[
      a_input_type `Hidden ;
      a_name "email" ;
      a_id "email" ;
      a_value user_email ;
    ] () ;
    input ~a:[
      a_input_type `Hidden ;
      a_name "state" ;
      a_id "state" ;
      a_value (Dream.csrf_token request) ;
    ] () ;
    input ~a:[
      a_input_type `Hidden ;
      a_name "otp_url" ;
      a_id "otp_url" ;
      a_value "" ; (* This will store the URL that continues the OTP flow - it is not a secret *)
    ] () ;
    input ~a:[
      a_input_type `Text ;
      a_class @@ Theme.input_styles @ ["text-center" ; "text-2xl" ; "m-2"] ;
      a_name "otp" ;
      a_id "otp" ;
      a_value "" ; (* This is where the user will put the OTP that was emailed to them *)
    ] () ;
    input ~a:[
      a_input_type `Button ;
      a_class @@ Theme.button_styles @ ["mt-2"] ;
      a_value "Verify" ;
      a_id "verify_button" ;
      a_disabled () ;
      Utils.a_hx_typed Hx_ [
        "on keyup from closest <form/>" ;
          "for elt in <*:required/>" ;
            "if the elt's value.length is less than 6" ; (* poor man's validation === basically no validation *)
              "add @disabled then exit" ;
            "end" ;
          "end" ;
        "remove @disabled"
      ]
    ] () ;
    script ~a:[a_src (Xml.uri_of_string "/static/extend_account.dist.js")] (txt "") ;
  ]

(** The enroll dialog needs to receive a new credential binding link that can
 * be used by the binding script on the page to setup a passkey on the current
 * device for the user to use going forward. *)
let enroll_dialog is_new new_name binding_url = 
    (* It's a little confusing for users if they are upgrading from a password and it says it created a new account... *)
    let creation_text = match is_new with
    | true -> (p ~a:[a_class ["mb-2 text-base"]] [ txt ("Created account for '" ^ new_name ^ "'!") ])
    | false -> (p ~a:[a_class ["mb-2 text-base"]] [ txt ("Created passkey for '" ^ new_name ^ "'!") ]) in

    let self_destruct_text = match is_new with
    | true -> (p ~a:[a_class ["mt-2 text-base"]] [ txt "This user will self-destruct in 5 minutes if it does not login." ])
    | false -> (p ~a:[a_class ["mt-2 text-base"]] [ txt "Please return to login to try it out." ]) in

    div ~a:[
      a_class ["flex" ; "flex-col" ; "justify-center" ; "items-center"] ;
    ] [
      h1 ~a:[a_class ["mt-4 text-4xl text-black dark:text-white"]] [txt "WHNVR"] ;
      div ~a:[a_class ["p-4" ; "text-center text-whnvr-950 dark:text-whnvr-100"]] [
        creation_text ;
        self_destruct_text ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "binding_url" ;
          a_id "binding_url" ;
          a_value binding_url ;
        ] () ;
      ] ;
      div ~a:[a_class ["mb-4 rounded-full border-2 border-solid border-whnvr-400 border-t-transparent animate-spin w-[50px] h-[50px]"] ; a_id "bind_passkey_loader"] [] ;
      div ~a:[a_class ["mb-4 p-4 hidden"] ; a_id "bind_passkey_continue"] [
        a ~a:[a_href "/login" ; a_class Theme.button_styles] [ txt "Continue" ]
      ] ;
      script ~a:[a_src (Xml.uri_of_string "/static/bind_new_passkey.dist.js")] (txt "") ;
    ]

let authenticate_dialog request = 
  (* None of these are a secret, but it sure feels weird to have to pass them back like this *)
  let passkey_id = match (Dream.query request "id") with
  | Some id -> id 
  | _ -> failwith "Invalid Passkey Selected" in
  let client_id = Database.get_env_value "BI_APP_CLIENT_ID" in
  let app_id = Database.get_env_value "BI_APP_ID" in 
  let tenant_id = Database.get_env_value "BI_TENANT_ID" in
  let realm_id = Database.get_env_value "BI_REALM_ID" in
  let redirect_uri = Database.get_env_value "BI_AUTH_REDIRECT" in
    div ~a:[
      a_class ["flex" ; "flex-col" ; "justify-center" ; "items-center"] ;
    ] [
      div ~a:[a_class ["p-4" ; "text-whnvr-950 dark:text-whnvr-100"]] [
        div ~a:[a_class ["rounded-full border-2 border-solid border-whnvr-400 border-t-transparent animate-spin h-[50px] w-[50px]"]] [] ;
        (* This is silly. I need a different (read: better) way to pass these around *)
        input ~a:[
          a_input_type `Hidden ;
          a_name "tenant_id" ;
          a_id "tenant_id" ;
          a_value tenant_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "realm_id" ;
          a_id "realm_id" ;
          a_value realm_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "app_id" ;
          a_id "app_id" ;
          a_value app_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "client_id" ;
          a_id "client_id" ;
          a_value client_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "redirect_uri" ;
          a_id "redirect_uri" ;
          a_value (Dream.to_percent_encoded redirect_uri) ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "passkey_id" ;
          a_id "passkey_id" ;
          a_value passkey_id ;
        ] () ;
        input ~a:[
          a_input_type `Hidden ;
          a_name "state" ;
          a_id "state" ;
          a_value (Dream.csrf_token request) ;
        ] () ;
      ] ;
      script ~a:[a_src (Xml.uri_of_string "/static/authenticate_passkey.dist.js")] (txt "") ;
    ]

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

let missing_content () = 
  div ~a:[a_class ["flex flex-col" ; "p-8"]] [
    h1 ~a:[a_class ["text-4xl" ; "p-4"]] [txt "Where is my passkey?" ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "Passkeys are more like regular keys than passwords. To be clear, this is more secure but it's also a new way of thinking. " ;
        txt "WHNVR employs passkeys from Beyond Identity, which cannot be moved from one device to another. " ;
        txt "This means that in order to log in to your account on this device, you will need to request a new passkey enrollment link from a device that already has a passkey." ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4"]] [
      p [
        txt "In the future, we plan to implement a way for you to request a passkey binding link from the login page. " ;
        txt "For now though, you will need to use another device that has a passkey for your account." ;
      ] ;
    ] ;
    div ~a:[a_class ["p-4" ; "text-center"]] [
      a ~a:[a_href (Xml.uri_of_string "/login") ; a_class ["underline hover:no-underline"]] [txt "Return to login"] ;
    ]
  ]

let left_column () =
  div ~a:[a_class ["flex" ; "flex-col" ; "px-8"]] [
    div ~a:[a_class ["flex" ; "flex-row" ]] [
      (txt "/dev/null >> WHNVR")
    ]
  ]

let right_column username =
  div ~a:[a_class ["h-full" ; "flex" ; "flex-col" ; "justify-between" ; "px-8" ]] [
    div ~a:[a_class ["flex" ; "flex-col" ; "items-center" ; "pt-4"]] [
      h1 ~a:[a_class ["text-5xl" ; "text-black dark:text-white"]] [ txt "WHNVR"] ;
      div ~a:[a_class [
        "w-[150px] lg:w-[300px] h-[150px] lg:h-[300px]" ;
        "mt-4 mb-4" ;
        "rounded-full" ;
        "bg-whnvr-200 dark:bg-whnvr-900" ;
        "flex flex-row justify-center items-center" ;
        "text-2xl lg:text-4xl" ;
      ]] [
        txt username
      ] ;
    ] ;
    div ~a:[a_class ["pb-4" ; "flex flex-col items-center"]] [
      input ~a:[ a_input_type `Button ; a_class (Theme.button_styles @ ["w-full lg:w-[300px]"]) ; Utils.a_hx_typed Post ["/logout"] ; a_value "Logout"] () ;
    ]  
  ]

let standard_menu request visible =
  let username = match (Dream.session_field request "username") with
                 | Some uname -> uname
                 | None -> "" in
  let display_class = match visible with
                      | true -> "block"
                      | false -> "hidden lg:block" in
  div ~a: [
    a_class [
      display_class ;
      "absolute z-200 lg:relative w-full lg:w-auto h-full lg:h-auto bg-whnvr-600/50 lg:bg-transparent"
    ] ;
    a_id "feed_side_menu" ;
    Utils.a_hx_typed Target ["this"] ;
    Utils.a_hx_typed Swap ["outerHTML"] ;
    Utils.a_hx_typed Get ["/menu-close"] ;
  ] [
    div ~a:[
      a_class [
        "absolute lg:relative top-0 lg:top-auto right-0 lg:right-auto" ;
        "bg-whnvr-400 dark:bg-whnvr-950" ;
        "w-[60%] lg:w-[400px]" ;
        "h-full" ;
        "shadow-[-5px_0px_5px_rgba(0,0,0,0.2)]" ;
        "border-l" ;
        "border-whnvr-200 dark:border-black/50"
      ] ;
      Utils.a_hx_typed Hx_ [
        "on click" ;
          "halt the event" ;
        "end" ;
      ]
    ] [ (right_column username) ] ;
  ]


