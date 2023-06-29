module NoMultipleFunctionArgumentsTest exposing (all)

import NoMultipleFunctionArguments exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoMultipleFunctionArguments"
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
fn a b = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "REPLACEME"
                            , details = [ "REPLACEME" ]
                            , under = "fn a b = 1"
                            }
                        ]
        ]
