(* Notion API: developers.notion.com,
  https://developers.notion.com/docs/getting-started
*)

let _base_url = "https://api.notion.com/"

let _wget host path headers =
  Eio_main.run @@ fun env ->
  Easy_tls.run env @@ fun tls ->
  Eio.Net.with_tcp_connect ~host ~service:"https" env#net @@ fun connection ->
  let connection =
    Easy_tls.client_of_flow tls ~host connection 
  in
  let (http_response, reader) =
    Cohttp_eio.Client.get ~headers ~conn:connection (host, None) path
  in      
  Eio.Flow.shutdown connection `Send;
  match Http.Response.status http_response with
    | `OK ->
      Ok (Cohttp_eio.Client.read_fixed (http_response, reader))
    | status -> Error 
      ((Http.Status.to_string status) ^ (Eio.Buf_read.take_all reader))

let wget_notion id =
  let path = "https://api.notion.com/v1/blocks/" ^ id ^ "/children" in
  let token = Sys.getenv "NOTION_TOKEN" in
  let headers = (* Http.Header.of_list *)
  [
    "Notion-Version", "2022-06-28";
    "Authorization", ("Bearer " ^ token);
    "Content-type", "application/json";
  ]
  in
  (* wget "api.notion.com" path headers *)
  let url = path in
  let r = Ezcurl.get ~headers ~url () in
  match r with
  | Ok { code=200; body; _ } ->
    Ok body
  | Ok { body; _ } -> Error body
  | _ -> Error "ezcurl internal error"

let _ =
  match (wget_notion "49970e75e46e49b89d176926940b1acc") with
  | Ok s ->
    let json_object = Yojson.Safe.from_string s in
    let open Yojson.Safe.Util in
    let string_member key obj = member key obj |> to_string in
    let results = member "results" json_object |> to_list in
    let p x =
      try (string_member "object" x = "block") &&
          (string_member "type" x = "child_page")
      with _ -> false
    in
    let subpages = List.filter p results in
    List.iter (fun block -> print_endline (string_member "id" block)) subpages
  | Error e -> print_string e
