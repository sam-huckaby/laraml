let _ = Random.self_init ()

(** Generate a stupid, ugly, confusing, password until I sit down and write an OCaml passkey library *)
let ugly_password_generator () =
  let possible_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*{[}]" in
  let len = String.length possible_chars in 
  let octet () =
    let str = Bytes.create 8 in 
    for i = 0 to 7 do 
      Bytes.set str i possible_chars.[Random.int len]
    done;
    Bytes.to_string str 
  in 
  octet () ^ "-" ^ octet () ^ "-" ^ octet ()

let replace_chars str =
  let replace_char c =
    match c with
    | '-' -> '+'
    | '_' -> '/'
    | _ -> c
  in
  String.map replace_char str

let get_json_key json key =
  let open Yojson.Basic.Util in
  let parsed = Yojson.Basic.from_string json in
  parsed |> member key |> to_string

(* I think there is a library to handle these types for htmx, we should use that if possible *)
(* This is NOT the way *)
type hx_attr = Boost | Get | Post | On | PushUrl | Select | SelectOob | Swap | SwapOob | Target | Trigger | Vals | Confirm | Delete | Disable | Disinherit | Encoding | Ext | Headers | History | HistoryElt | Hx_ | Include | Indicator | Params | Patch | Preserve | Prompt | Put | ReplaceUrl | Request | Sse | Sync | Validate | Vars | Ws

let hx_to_string = function
  | Boost -> "hx-boost" (* Bool *)
  | Get -> "hx-get" (* uri *)
  | Post -> "hx-post" (* uri *)
  | On -> "hx-on" (* EventName (JS or htmx): javascript function *)
  | PushUrl -> "hx-push-url" (* true | false | uri *)
  | Select -> "hx-select" (* CSS Selector *)
  | SelectOob -> "hx-select-oob" (* CSS Selector *)
  | Swap -> "hx-swap" (* complicated -- https://htmx.org/attributes/hx-swap/ *)
  | SwapOob -> "hx-swap-oob" (* complicated -- https://htmx.org/attributes/hx-swap-oob/ *)
  | Target -> "hx-target" (* this | augmented CSS Selector *)
  | Trigger -> "hx-trigger" (* complicated -- https://htmx.org/attributes/hx-trigger/ *)
  | Vals -> "hx-vals" (* complicated -- https://htmx.org/attributes/hx-vals/ *)
  | Confirm -> "hx-confirm"
  | Delete -> "hx-delete"
  | Disable -> "hx-disable"
  | Disinherit -> "hx-disinherit"
  | Encoding -> "hx-encoding"
  | Ext -> "hx-ext"
  | Headers -> "hx-headers"
  | History -> "hx-history"
  | HistoryElt -> "hx-history-elt"
  | Hx_ -> "_"
  | Include -> "hx-include"
  | Indicator -> "hx-indicator"
  | Params -> "hx-params"
  | Patch -> "hx-patch"
  | Preserve -> "hx-preserve"
  | Prompt -> "hx-prompt"
  | Put -> "hx-put"
  | ReplaceUrl -> "hx-replace-url"
  | Request -> "hx-request"
  | Sse -> "hx-sse"
  | Sync -> "hx-sync"
  | Validate -> "hx-validate"
  | Vars -> "hx-vars"
  | Ws -> "hx-ws"

let a_hx_typed name =
  match name with
  (*
  | Get | Post -> Tyxml.Html.Unsafe.space_sep_attrib (hx_to_string name)
  | Boost | On | PushUrl | Select | SelectOob | Swap -> Tyxml.Html.Unsafe.space_sep_attrib ("long-" ^ (hx_to_string name))
  *)
  | _ -> Tyxml.Html.Unsafe.space_sep_attrib (hx_to_string name)

(* Type safety? What's that? *)
let a_hx name = Tyxml.Html.Unsafe.space_sep_attrib ("hx-" ^ name)
