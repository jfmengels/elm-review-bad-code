module NoMultipleFunctionArguments exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.Rule as Rule exposing (Rule)


{-| Reports... REPLACEME

    config =
        [ NoMultipleFunctionArguments.rule
        ]


## Fail

    a =
        "REPLACEME example to replace"


## Success

    a =
        "REPLACEME example to replace"


## When (not) to enable this rule

This rule is useful when REPLACEME.
This rule is not useful when REPLACEME.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template jfmengels/elm-review-bad-code/example --rules NoMultipleFunctionArguments
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoMultipleFunctionArguments" {}
        |> Rule.withSimpleDeclarationVisitor declarationVisitor
        |> Rule.withSimpleExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


declarationVisitor : Node Declaration -> List (Rule.Error {})
declarationVisitor node =
    case Node.value node of
        Declaration.FunctionDeclaration { declaration } ->
            reportFunction (Node.value declaration) (Node.range declaration)

        _ ->
            []


expressionVisitor : Node Expression -> List (Rule.Error {})
expressionVisitor node =
    case Node.value node of
        _ ->
            []


reportFunction : Expression.FunctionImplementation -> Range -> List (Rule.Error {})
reportFunction node range =
    if List.length node.arguments > 1 then
        [ Rule.error
            { message = "REPLACEME"
            , details = [ "REPLACEME" ]
            }
            range
        ]

    else
        []
