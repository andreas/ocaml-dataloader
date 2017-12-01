type 'a cont = 'a -> unit
type 'a cps = exn cont -> 'a cont -> unit
type ('key, 'value) loader = 'key list -> 'value list cps

type ('key, 'value) entry = {
  key  : 'key;
  fail : exn cont;
  ok   : 'value cont;
}

type ('key, 'value) t = {
  loader : ('key, 'value) loader;
  mutable entries : ('key, 'value) entry list
}

let create ~load =
  { loader = load; entries = []}

let load t key fail ok =
  t.entries <- {key; fail; ok}::t.entries

let trigger t =
  if t.entries = [] then
    ()
  else
    let entries = t.entries in
    t.entries <- [];
    let keys = List.map (fun entry -> entry.key) entries in
    t.loader keys (fun err ->
      List.iter (fun entry -> entry.fail err) entries
    ) (fun values ->
      List.combine values entries
      |> List.iter (fun (value, entry) ->
           entry.ok value
         )
    )
