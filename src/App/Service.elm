module App.Service exposing (view)

import App.Util as Util
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (..)
import Html.Attributes exposing (..)


view : Grid.Column msg
view =
    Grid.col [ Col.md4, Col.attrs [ class "p-0 bg-light sidebar" ] ]
        [ div [ class "px-3", class "pt-1" ]
            [ Util.viewColumnTitle "Detail"
            , viewServiceDetail
            ]
        ]


viewServiceDetail : Html msg
viewServiceDetail =
    Card.config []
        |> Card.header [] [ text "Service A" ]
        |> Card.block []
            [ Block.custom <|
                Form.form []
                    [ Form.row []
                        [ Form.colLabel [ Col.sm8 ] [ text "EC2 Instance Scaling", Form.help [] [ text "when each EC2 instance reaches 80% or something, then scal eor something ask WILL" ] ]
                        , Form.col [ Col.sm4 ]
                            [ Input.number [ Input.value "1" ] ]
                        ]
                    ]
            ]
        |> Card.view