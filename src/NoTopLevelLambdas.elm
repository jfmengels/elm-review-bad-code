module NoTopLevelLambdas exposing (rule)

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
        [ NoTopLevelLambdas.rule
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
elm-review --template jfmengels/elm-review-bad-code/preview --rules NoTopLevelLambdas
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "NoTopLevelLambdas" initialContext
        |> Rule.withDeclarationEnterVisitor (\node context -> ( declarationVisitor node context, context ))
        |> Rule.providesFixesForModuleRule
        |> Rule.fromModuleRuleSchema


initialContext : Rule.ContextCreator () Context
initialContext =
    Rule.initContextCreator
        (\extractSourceCode () ->
            { extractSourceCode = extractSourceCode }
        )
        |> Rule.withSourceCodeExtractor


type alias Context =
    { extractSourceCode : Range -> String
    }


declarationVisitor : Node Declaration -> Context -> List (Rule.Error {})
declarationVisitor node context =
    case Node.value node of
        Declaration.FunctionDeclaration { declaration } ->
            case Node.value (Node.value declaration).expression of
                Expression.LambdaExpression { args, expression } ->
                    case args of
                        [ Node lambdaArgRange _ ] ->
                            [ Rule.errorWithFix
                                { message = "REPLACEME"
                                , details = [ "REPLACEME" ]
                                }
                                (Node.range (Node.value declaration).name)
                                (case last (Node.value declaration).arguments of
                                    Just (Node { end } _) ->
                                        [ Fix.insertAt end (" " ++ context.extractSourceCode lambdaArgRange)
                                        , Fix.removeRange { start = (Node.range (Node.value declaration).expression).start, end = (Node.range expression).start }
                                        ]

                                    Nothing ->
                                        []
                                )
                            ]

                        _ ->
                            []

                _ ->
                    []

        _ ->
            []


last : List a -> Maybe a
last list =
    case List.reverse list of
        [] ->
            Nothing

        x :: _ ->
            Just x
