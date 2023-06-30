module NoTopLevelLambdasTest exposing (all)

import NoTopLevelLambdas exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoTopLevelArguments"
        [ test "should not report an error for constants" <|
            \() ->
                """module A exposing (..)
constant = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should not report an error when a function has a single argument" <|
            \() ->
                """module A exposing (..)
fn a = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report an error when a function has multiple arguments" <|
            \() ->
                """module A exposing (..)
fn a =
    \\b -> 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Arguments in lambda could be joined with the arguments of the function"
                            , details =
                                [ "Unless you're trying to optimize for performance (which I am not currently checking for), it is unnecessary to separate the two as that hurts readability of the function."
                                , "I would recommend moving the arguments from the lambda to the function declaration."
                                ]
                            , under = "fn"
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
fn a b =
    1
"""
                        ]
        ]
