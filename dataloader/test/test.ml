let suite = [
  ("load one", `Quick, fun () ->
    let loader = Dataloader.create ~load:(fun keys _fail ok ->
      ok keys
    ) in
    Dataloader.load loader 1
      (fun _ -> Alcotest.fail "Loader failed, expected 1")
      (fun value -> Alcotest.(check int) "Load value" 1 value)
    ;
    Dataloader.trigger loader
  );
  ("load n", `Quick, fun () ->
    let loader_calls = ref 0 in
    let loader = Dataloader.create ~load:(fun keys _fail ok ->
      loader_calls := !loader_calls + 1;
      ok keys
    ) in
    List.iter (fun i ->
      Dataloader.load loader i
        (fun _ -> Alcotest.failf "Loader failed, expected %d" i)
        (fun value -> Alcotest.(check int) "Load value" i value)
    ) [1;2;3;4;5;6;7;8;9;10];
    Dataloader.trigger loader;
    Alcotest.(check int) "Load calls" 1 !loader_calls
  );
  ("failed load", `Quick, fun () ->
    let loader = Dataloader.create ~load:(fun _keys fail _ok ->
      fail (Failure "boom")
    ) in
    List.iter (fun i ->
      Dataloader.load loader i
        (fun _ -> ())
        (fun _value -> Alcotest.failf "Expected failure, got %d" i)
    ) [1;2;3;4;5;6;7;8;9;10];
    Dataloader.trigger loader;
  )
]

let () = Alcotest.run "dataloader" [
  "dataloader", suite
]
