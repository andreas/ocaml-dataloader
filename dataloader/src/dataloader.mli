type ('a, 'b) t

type 'a cont = 'a -> unit
type 'a cps = exn cont -> 'a cont -> unit
type ('a, 'b) loader = 'a list -> 'b list cps

val create :
  load:('a, 'b) loader ->
  ('a, 'b) t

val load :
  ('a, 'b) t ->
  'a ->
  'b cps

val trigger :
  ('a, 'b) t ->
  unit
