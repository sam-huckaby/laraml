open Lwt
open Cohttp
open Cohttp_lwt_unix


let create_identity display_name username email =
  let body = Cohttp_lwt.Body.of_string ("{\"identity\":{\"display_name\":\"" ^ display_name ^ "\",\"traits\": {\"type\": \"traits_v0\",\"username\": \"" ^ username ^ "\",\"primary_email_address\":\"" ^ email ^ "\"}}}") in 
  let api_token = Database.get_env_value "BI_API_TOKEN" in
  let tenant_id = Database.get_env_value "BI_TENANT_ID" in
  let realm_id = Database.get_env_value "BI_REALM_ID" in
  let headers = Header.of_list [("Content-Type", "application/json") ; ("Authorization", "Bearer " ^ api_token)] in
  Client.post ~headers ~body (Uri.of_string ("https://api-us.beyondidentity.com/v1/tenants/" ^ tenant_id ^ "/realms/" ^ realm_id ^ "/identities"))
  >>= fun (resp, body) -> 
    if Code.is_success (Code.code_of_status (Cohttp.Response.status resp)) then
      body |> Cohttp_lwt.Body.to_string 
      |> Lwt.map (fun res -> Some res)
    else
      (* Drain the body to prevent leakage - everyone hates leakage *)
      body |> Cohttp_lwt.Body.drain_body
      >|= fun _ -> None

(** Identity ID comes either from a create_identity response (new user) or from the passkey itself (existing user) *)
let get_credential_binding_url identity_id =
  let api_token = Database.get_env_value "BI_API_TOKEN" in
  let auth_config_id = Database.get_env_value "BI_AUTH_CONFIG_ID" in
  let tenant_id = Database.get_env_value "BI_TENANT_ID" in
  let realm_id = Database.get_env_value "BI_REALM_ID" in
  let headers = Header.of_list [("Content-Type", "application/json") ; ("Authorization", "Bearer " ^ api_token)] in
  (* delivery_method: RETURN, sends the credential binding url back as a response, rather than sending an email *)
  let body = Cohttp_lwt.Body.of_string ("{\"job\": {\"delivery_method\": \"RETURN\", \"authenticator_config_id\": \"" ^ auth_config_id ^ "\"}}") in 
  Client.post ~headers ~body (Uri.of_string ("https://api-us.beyondidentity.com/v1/tenants/" ^ tenant_id ^ "/realms/" ^ realm_id ^ "/identities/" ^ identity_id ^ "/credential-binding-jobs"))
  >>= fun (_, body) ->
  (* The resppnse body should be a credential binding link that the embedded SDK can use *)
  body |> Cohttp_lwt.Body.to_string

(** Identity ID comes either from a create_identity response (new user) or from the passkey itself (existing user) *)
let get_otp_credential_binding_url passkey_binding_token =
  let app_id = Database.get_env_value "BI_APP_ID" in
  let tenant_id = Database.get_env_value "BI_TENANT_ID" in
  let realm_id = Database.get_env_value "BI_REALM_ID" in
  let headers = Header.of_list [("Content-Type", "application/json") ; ("Authorization", "Bearer " ^ passkey_binding_token)] in
  Client.post ~headers (Uri.of_string ("https://auth-us.beyondidentity.com/v1/tenants/" ^ tenant_id ^ "/realms/" ^ realm_id ^ "/applications/" ^ app_id ^ "/credential-binding-jobs"))
  >>= fun (_, body) ->
    (* The resppnse body should be a credential binding link that the embedded SDK can use *)
    body |> Cohttp_lwt.Body.to_string

let exchange_token request =
    let code = match Dream.query request "code" with
               | Some auth_code -> auth_code 
               | _ -> "" in

    (* Gather all of the environment values used by the token exchange *)
    let client_id = Database.get_env_value "BI_APP_CLIENT_ID" in
    let client_secret = Database.get_env_value "BI_APP_CLIENT_SECRET" in
    let auth_redirect = Database.get_env_value "BI_AUTH_REDIRECT" in
    let tenant_id = Database.get_env_value "BI_TENANT_ID" in
    let realm_id = Database.get_env_value "BI_REALM_ID" in
    let app_id = Database.get_env_value "BI_APP_ID" in

    (* Build the request to the Beyond Identity auth server *)
    let body = Cohttp_lwt.Body.of_string ("grant_type=authorization_code&scope=openid&code=" ^ code ^ "&redirect_uri=" ^ auth_redirect) in 
    let headers = Header.of_list [("Content-Type", "application/x-www-form-urlencoded") ; ("Authorization", "Basic " ^ Base64.encode_string (client_id ^ ":" ^ client_secret))] in
    Client.post ~headers ~body (Uri.of_string ("https://auth-us.beyondidentity.com/v1/tenants/" ^ tenant_id ^ "/realms/" ^ realm_id ^ "/applications/" ^ app_id ^ "/token"))

    (* Process the returned status code and body, which hopefully contains an access_token *)
    >>= fun (resp, body) ->
      let code = resp |> Response.status |> Code.code_of_status in
      match Cohttp.Code.is_success code with
      | true ->
        let open Yojson.Basic.Util in
        let%lwt token_json = body |> Cohttp_lwt.Body.to_string in
        let token_obj = Yojson.Basic.from_string token_json in
        let access_token = token_obj |> member "access_token" |> to_string in
        let id_token = token_obj |> member "id_token" |> to_string in
        Lwt.return (access_token , id_token)
      | false -> 
        Lwt.return ("" , "")

