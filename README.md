# The git-notion mirroring tool

git-notion lets you fetch pages from a [Notion](https://www.notion.os)
workspace and view them as a git repository

## Intended use

To be allowed to interact with Notion's API, an integration token is
required. In other words, accesses to the API can not be made as a
logged-in user.

For this reason, the intended use of this program is not so much
to be installed by each user of an organization using Notion.

It's rather the organization that would install this program and
let it export a git view of their Notion workspace in a private
repository users can then fetch from.

`git-notion` looks for the token in the `NOTION_TOKEN` environment variable.

In addition, for each hierarchy of pages one wants to make accessible,
permission must be granted at the level of the root page of the hierarchy.
The permission is then inherited by all its subpages.

## Installation 

After having cloned the repository, create a local opam switch:

```
opam update && opam switch create . x.y.z
```

where `x.y.z` is the release number of OCaml you want to base your switch
on.

Bring your system environment up-to-date:

```
eval $(opam env)
```

Install required packages:

```
opam install yojson ezcurl cohttp-eio tls-eio mirage-crypto-rng-eio eio_main uri
```
