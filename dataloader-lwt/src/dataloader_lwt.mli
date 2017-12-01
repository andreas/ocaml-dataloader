type ('a, 'b) t

val create :
  load:('a list -> ('b list, exn) result Lwt.t) ->
  ('a, 'b) t

val load :
  ('a, 'b) t ->
  'a ->
  ('b, exn) result Lwt.t
