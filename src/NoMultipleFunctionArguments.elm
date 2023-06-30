module NoMultipleFunctionArguments exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Expression as Expression
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Range exposing (Range)
import Review.Fix as Fix exposing (Fix)
import Review.Rule as Rule exposing (Rule)


{-| Reports when a function has multiple arguments, and encourages using nested lambdas instead.

**WARNING**: This rule is meant as a joke, and should probably not be used in production code.
It is an attempt to transform Elm code into the worst possible Elm code possible
([some more ideas on that](https://realmario.notion.site/Worst-Elm-Code-Possible-393f8fc7338b46afb13efb9766d909bf?pvs=4))

**NOTE**: This rule is still a bit incomplete: it doesn't handle let functions not lambdas yet.

    config =
        [ NoMultipleFunctionArguments.rule
        ]


## Fail

    fn a b c =
        a + b + c


## Success

    fn a =
        \b ->
            c ->
                a + b + c


## When (not) to enable this rule

NEVER enable this rule in production. If you think there is a real use-case, let me know, I'd be curious to hear.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template jfmengels/elm-review-bad-code/preview --rules NoMultipleFunctionArguments
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoMultipleFunctionArguments" ()
        |> Rule.withSimpleDeclarationVisitor declarationVisitor
        |> Rule.providesFixesForModuleRule
        |> Rule.fromModuleRuleSchema


declarationVisitor : Node Declaration -> List (Rule.Error {})
declarationVisitor node =
    case Node.value node of
        Declaration.FunctionDeclaration { declaration } ->
            reportFunction (Node.value declaration)

        _ ->
            []


reportFunction : Expression.FunctionImplementation -> List (Rule.Error {})
reportFunction functionImplementation =
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
                    (Node.range functionImplementation.name)
                    (Fix.insertAt first.end " =" :: fix (Node.range functionImplementation.expression) rest)
                ]


fix : Range -> List (Node a) -> List Fix
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
