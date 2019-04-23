type 'a cont = 'a -> unit
type ('a, 'err) cps = 'err cont -> 'a cont -> unit
type ('key, 'value, 'err) loader = 'key list -> ('value list, 'err) cps

type ('key, 'value, 'err) entry = {
  key  : 'key;
  fail : 'err cont;
  ok   : 'value cont;
}

type ('key, 'value, 'err) t = {
  loader : ('key, 'value, 'err) loader;
  mutable entries : ('key, 'value, 'err) entry list
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
