module NoTopLevelLambdas exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Range exposing (Range)
import Review.Fix as Fix exposing (Fix)
import Review.Rule as Rule exposing (Rule)


{-| Reports when a function's body consists of a lambda expression.

🔧 Running with `--fix` will automatically remove all the reported errors.

**WARNING**: This rule is meant as a joke to undo the changes in the [`NoMultipleFunctionArguments`](NoMultipleFunctionArguments) rule.

In practice, this rule has its uses, but also its drawbacks (though probably leans closer to the positive side).

**NOTE**: This rule is still a bit incomplete: it doesn't handle let functions nor lambdas yet.

    config =
        [ NoTopLevelLambdas.rule
        ]


## Fail

    fn a =
        \b ->
            a + b


## Success

    fn a b =
        a + b


## When (not) to enable this rule

I think that in general this rule actually makes sense, **but** this could have a performance impact.

For instance, given the following code:

    a =
        List.filter (someFunction data) list

the code would run faster if `someFunction` was defined like:

    someFunction data =
        \item -> ...

rather than the more usual

    someFunction data item =
        ...

because Elm is faster when functions are called with the exact number of arguments (from the declaration of the function).
Automatic partial application in Elm has a performance cost, that we pay in favor of ergonomics and other benefits of automatic currying.

This change in performance could be negative, but it could end up being positive too as this rule could potentially make the arguments of the declarations and call sites match.

To put things into perspective, the performance change is likely unnoticeable: in practice we call functions with the "wrong" number of arguments all the time in Elm already!
But if you've carefully crafted your function to adapt to the call sites — because you had this performance knowledge already and the code is used very frequently — then this could have a negative impact.

In practice, we could try to make the rule smarter, by looking at the call sites, and see whether this change would improve or worsen the call sites (or not affect much).
This could be an interesting exploration, and could make the rule actually pretty useful.


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
                                (fixError context declaration lambdaArgRange expression)
                            ]

                        _ ->
                            []

                _ ->
                    []

        _ ->
            []


fixError : Context -> Node Expression.FunctionImplementation -> Range -> Node Expression -> List Fix
fixError context (Node _ declaration) lambdaArgRange expression =
    case last declaration.arguments of
        Just (Node { end } _) ->
            [ Fix.insertAt end (" " ++ context.extractSourceCode lambdaArgRange)
            , Fix.removeRange { start = (Node.range declaration.expression).start, end = (Node.range expression).start }
            ]

        Nothing ->
            []


last : List a -> Maybe a
last list =
    case List.reverse list of
        [] ->
            Nothing

        x :: _ ->
            Just x
