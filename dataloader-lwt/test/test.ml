open Lwt.Infix

let suite = [
  ("load one", `Quick, fun () ->
    let loader = Dataloader_lwt.create ~load:(fun keys ->
      Lwt_result.return keys
    ) in
    (Dataloader_lwt.load loader 1 >|= function
    | Error _ -> Alcotest.fail "Loader failed, expected 1"
    | Ok value -> Alcotest.(check int) "Load value" 1 value)
    |> Lwt_main.run
  );
  ("load n", `Quick, fun () ->
    let loader_calls = ref 0 in
    let loader = Dataloader_lwt.create ~load:(fun keys ->
      loader_calls := !loader_calls + 1;
      Lwt_result.return keys
    ) in
    (List.map (fun i ->
      Dataloader_lwt.load loader i >|= function
      | Error _ -> Alcotest.failf "Loader failed, expected %d" i
      | Ok value -> Alcotest.(check int) "Load value" i value
    ) [1;2;3;4;5;6;7;8;9;10]
    |> Lwt.join >|= fun () ->
       Alcotest.(check int) "Load calls" 1 !loader_calls)
    |> Lwt_main.run
  );
  ("failed load", `Quick, fun () ->
    let loader = Dataloader_lwt.create ~load:(fun keys ->
      Lwt_result.fail (Failure "boom")
    ) in
    List.map (fun i ->
      Dataloader_lwt.load loader i >|= function
      | Error _ -> ()
      | Ok _ -> Alcotest.failf "Expected failure, got %d" i
    ) [1;2;3;4;5;6;7;8;9;10]
    |> Lwt.join
    |> Lwt_main.run
  )
]

let () = Alcotest.run "dataloader-lwt" [
  "dataloader-lwt", suite
]
