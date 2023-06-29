# elm-review-bad-code

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.

## Provided rules

- [`NoMultipleFunctionArguments`](https://package.elm-lang.org/packages/jfmengels/elm-review-bad-code/1.0.0/NoMultipleFunctionArguments) - Reports REPLACEME.

## Configuration

```elm
module ReviewConfig exposing (config)

import NoMultipleFunctionArguments
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ NoMultipleFunctionArguments.rule
    ]
```

## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template jfmengels/elm-review-bad-code/example
```
