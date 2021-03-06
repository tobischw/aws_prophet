module App.Settings exposing (Model, Msg(..), init, subscriptions, update, view)
import App.Instances as Instances exposing (FilterType, Model, Filters, update, Msg(..))
import App.Constants exposing (instanceTypes)
import App.Util as Util
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Grid.Col as Col
import Html exposing (..)
import Html.Attributes exposing (..)
import Multiselect
import App.Instances exposing (Instances)


type alias Model =
    { excludedInstances : Multiselect.Model
    , excludedSystems: Multiselect.Model
    , enableLiveResults : Bool
    }


init : Model
init =
    { excludedInstances = Multiselect.initModel instanceTypes "A"
    , excludedSystems = Multiselect.initModel [("SUSE", "SUSE"), ("Windows", "Windows"), ("Linux", "Linux"), ("RHEL", "RHEL")] "B"
    , enableLiveResults = True
    }



-- There's a better way to do this...


type Msg
    = UpdateExcludedInstances Multiselect.Msg
    | UpdateExcludedOS Multiselect.Msg
    | UpdateEnableLiveResults Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateExcludedInstances instancesChangedMessage ->
            let
                ( newExcludedInstances, subCmd, _ ) =
                    Multiselect.update instancesChangedMessage model.excludedInstances
            in
            ( { model | excludedInstances = newExcludedInstances }, Cmd.map UpdateExcludedInstances subCmd )

        UpdateEnableLiveResults value ->
            ( { model | enableLiveResults = value }, Cmd.none )

        UpdateExcludedOS osChangedMessage ->
            let
                ( newExcludedos, subCmd, _ ) =
                    Multiselect.update osChangedMessage model.excludedSystems
            in
            ( { model | excludedSystems = newExcludedos}, Cmd.map UpdateExcludedOS subCmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch 
    [ Sub.map UpdateExcludedInstances <| Multiselect.subscriptions model.excludedInstances
    , Sub.map UpdateExcludedOS <| Multiselect.subscriptions model.excludedSystems
    ]
    


view : Model -> Html Msg
view model =
    Card.config []
        |> Card.header [] [ text "Global Settings" ]
        |> Card.block []
            [ Block.custom <|
                Form.form []
                    [ Form.row []
                        [ Form.colLabel [ Col.sm3 ] [ text "Excluded Instance Types" ]
                        , Form.col [ Col.sm9 ]
                            [ Html.map UpdateExcludedInstances <| Multiselect.view model.excludedInstances
                            , Form.help [] [ text "Exclude specific ECS instances. These will be ignored during the cluster optimization calculation." ]
                            ]
                        ]
                    , hr [] []
                    , Form.row []
                        [ Form.colLabel [ Col.sm3 ] [ text "Excluded Operating System Types" ]
                        , Form.col [ Col.sm9 ]
                            [ Html.map UpdateExcludedOS <| Multiselect.view model.excludedSystems
                            , Form.help [] [ text "Exclude specific operating systems from the EC2 instances." ]
                            ]
                        ]
                    ]
            ]
        |> Card.view
