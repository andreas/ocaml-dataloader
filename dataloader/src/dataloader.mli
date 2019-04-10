type ('a, 'b, 'err) t

type 'a cont = 'a -> unit
type ('a, 'err) cps = 'err cont -> 'a cont -> unit
type ('a, 'b, 'err) loader = 'a list -> ('b list, 'err) cps

val create :
  load:('a, 'b, 'err) loader ->
  ('a, 'b, 'err) t

val load :
  ('a, 'b, 'err) t ->
  'a ->
  ('b, 'err) cps

val trigger :
  ('a, 'b, 'err) t ->
  unit
