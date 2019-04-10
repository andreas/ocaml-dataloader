type ('a, 'b, 'err) t

val create :
  load:('a list -> ('b list, 'err) result Lwt.t) ->
  ('a, 'b, 'err) t

val load :
  ('a, 'b, 'err) t ->
  'a ->
  ('b, 'err) result Lwt.t
