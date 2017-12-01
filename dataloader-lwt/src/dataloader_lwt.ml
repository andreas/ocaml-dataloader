type ('a, 'b) t = {
  dataloader : ('a, 'b) Dataloader.t;
  mutable pause : unit Lwt.t option;
}

let create ~load =
  let dataloader = Dataloader.create ~load:(fun keys fail ok ->
    Lwt.on_success (load keys) (function
    | Ok values -> ok values
    | Error err -> fail err
  )) in
  { dataloader; pause = None }

let pause t =
  let open Lwt.Infix in
  match t.pause with
  | None ->
    let pause =
      Lwt.pause () >|= fun () ->
      Dataloader.trigger t.dataloader
    in
    t.pause <- Some pause;
    pause 
  | Some pause -> pause

let load t key =
  let open Lwt.Infix in
  let p, resolver = Lwt.wait () in
  Dataloader.load t.dataloader key (fun err ->
    Lwt.wakeup resolver (Error err)
  ) (fun value ->
    Lwt.wakeup resolver (Ok value)
  );
  pause t >>= fun () ->
  p
