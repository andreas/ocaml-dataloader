Dataloader is a utility to be used for your application's data fetching layer to provide batching and caching, in particular with [`ocaml-graphql-server`](https://github.com/andreas/ocaml-graphql-server). It is a port of [facebook/dataloader](https://github.com/facebook/dataloader) for Node. The library is still under active development.

This repo contains two packages:

- `dataloader`, which is IO-agnostic written in CPS-style.
- `dataloader-lwt`, which is a shim on top of `dataloader` for [`Lwt`](https://github.com/ocsigen/lwt).

## Example

The following examples assumes a function `batchLoadUsersFromDatabase` of the type `user_id list -> (user list, exn) result Lwt.t`:

```ocaml
let user_loader = Dataloader_lwt.create ~load:(fun user_ids ->
  batchLoadUsersFromDatabase user_ids
)

(* triggers only 1 query rather than 5 *)
List.map (fun user_id ->
  Dataloader_lwt.load user_loader user_id
) [1; 2; 3; 4; 5]
```

The function `~load` provided to `Dataloader.create` must uphold the following constraints:

- The list of values must be the same length as the list of keys.
- Each index in the list of values must correspond to the same index in the list of keys.
