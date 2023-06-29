module NoMultipleFunctionArguments exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Range exposing (Range)
import Review.Fix as Fix
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
        |> Rule.providesFixesForModuleRule
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
reportFunction functionImplementation range =
    case functionImplementation.arguments of
        [] ->
            []

        (Node first _) :: rest ->
            if List.isEmpty rest then
                []

            else
                [ Rule.errorWithFix
                    { message = "REPLACEME"
                    , details = [ "REPLACEME" ]
                    }
                    range
                    (Fix.insertAt first.end " =" :: fix (Node.range functionImplementation.expression) rest)
                ]


fix : Range -> List (Node a) -> List Fix.Fix
fix bodyRange arguments =
    case arguments of
        [] ->
            []

        (Node range _) :: rest ->
            if List.length rest == 0 then
                [ Fix.insertAt range.start "\\"
                , Fix.replaceRangeBy { start = range.end, end = bodyRange.start } " ->\n    "
                ]

            else
                [ Fix.insertAt range.start "\\"
                , Fix.insertAt range.end " -> "
                ]
                    ++ fix bodyRange rest
