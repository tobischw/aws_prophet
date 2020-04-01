module App.Configuration exposing (Cluster, Container, Model, Msg(..), Service, init, update, view)

import App.Constants exposing (RegionRecord, allRegions)
import App.Util as Util
import Bootstrap.Button as Button
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.Utilities.Size as Size
import Dict exposing (Dict)
import Dict.Extra exposing (filterMap)
import FeatherIcons
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events.Extra exposing (onChange, onEnter)
import Multiselect
import Tuple exposing (first, second)


init : Model
init =
    { clusters = Dict.fromList [ ( 0, Cluster "Cluster 1" ) ]
    , services = Dict.fromList [ ( 0, Service "Service 1" 0 0 (Multiselect.initModel [] "A") 0 ), ( 1, Service "Service 2" 0 0 (Multiselect.initModel [] "A") 0 ) ]
    , containers = Dict.fromList [ ( 0, Container "Container A" 0 20 20 20 20 ), ( 1, Container "Container B" 0 20 20 20 20 ) ]
    }


type alias Services =
    Dict Int Service


type alias Clusters =
    Dict Int Cluster


type alias Containers =
    Dict Int Container


type alias Model =
    { clusters : Clusters
    , services : Services
    , containers : Containers
    }


type Msg
    = AddCluster
    | AddService Int
    | AddContainer Int
    | DeleteContainer Int
    | DeleteService Int
    | DeleteCluster Int


type alias Cluster =
    { name : String
    }


type alias Service =
    { name : String
    , clusterId : Int
    , scalingTarget : Int
    , regions : Multiselect.Model
    , taskTotalMemory : Int
    }


type alias Container =
    { name : String
    , serviceId : Int
    , cpuShare : Int
    , memory : Int
    , ioops : Int
    , bandwidth : Int
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        AddCluster ->
           { model | clusters = model.clusters |> Dict.insert (Dict.size model.clusters) (Cluster "Cluster")} 
        AddService clusterId ->
            { model | services = model.services |> Dict.insert (Dict.size model.services) (Service "Service" clusterId 0 (Multiselect.initModel [] "A") 0)}

        AddContainer serviceId ->
            { model | containers = model.containers |> Dict.insert (Dict.size model.containers) (Container "Container" serviceId 128 2048 128 1048)}
        
        DeleteContainer containerId ->
            {model | containers = model.containers |> Dict.remove containerId}

        DeleteService serviceId ->
            let
                newModel = {model | containers = model.containers |> Dict.Extra.removeWhen (\_ container -> container.serviceId == serviceId )}
            in
                {newModel | services  = model.services|> Dict.remove serviceId}

        DeleteCluster clusterId ->
            model


view : Model -> Html Msg
view model =
    div [ class "px-3", class "pt-1" ]
        [ Util.viewColumnTitle "Configuration", hr [] []
        , Button.button
            [ Button.outlineSuccess, Button.onClick AddCluster, Button.block, Button.attrs [ class "mb-2" ] 
            ]
            [ FeatherIcons.plus |> FeatherIcons.toHtml [], text "Add Cluster"]
        , ListGroup.custom (viewClusters model)
        , hr [] []
        , ListGroup.custom
            [ simpleListItem "Global Settings" FeatherIcons.settings [ href "../../settings" ]
            , simpleListItem "Export as JSON" FeatherIcons.share [ href "#" ]
            , simpleListItem "Load JSON" FeatherIcons.download [ href "#" ]
            ]
        ]


viewClusters : Model -> List (ListGroup.CustomItem Msg)
viewClusters model =
    List.concatMap (viewClusterItem model) (Dict.toList model.clusters)


viewClusterItem : Model -> ( Int, Cluster ) -> List (ListGroup.CustomItem Msg)
viewClusterItem model clusterTuple =
    let
        id =
            first clusterTuple

        cluster =
            second clusterTuple
    in
    List.concat
        [ [ ListGroup.anchor
                [ ListGroup.attrs [ Flex.block, Flex.justifyBetween, class "cluster-item", href ("/cluster/" ++ String.fromInt id) ] ]
                [ div [ Flex.block, Flex.justifyBetween, Size.w100 ]
                    [ span [ class "pt-1" ] [ FeatherIcons.share2 |> FeatherIcons.withSize 19 |> FeatherIcons.toHtml [], text cluster.name ]
                    , div [] [
                        span [] [ Button.button [ Button.outlineSecondary, Button.small, Button.onClick (AddService id) ] [ FeatherIcons.plus |> FeatherIcons.withSize 16 |> FeatherIcons.withClass "empty-button" |> FeatherIcons.toHtml [], text "" ] ]
                        , span [ class "ml-3 text-danger", Html.Events.Extra.onClickPreventDefaultAndStopPropagation (DeleteCluster id)] [ FeatherIcons.trash2 |> FeatherIcons.withSize 16 |> FeatherIcons.toHtml [] ]
                        -- needed to prevent the onClick of the list item from firing, and rerouting us to a non-existant thingy
                        ]
                    ]
                ]
          ]
        , viewServices model (getServices id model.services)
        ]


getServices : Int -> Services -> Services
getServices clusterId services =
    let
        associateService _ service =
            if service.clusterId == clusterId then
                Just service

            else
                Nothing
    in
    services |> filterMap associateService


viewServices : Model -> Services -> List (ListGroup.CustomItem Msg)
viewServices model services =
    List.concatMap (viewServiceItem model) (Dict.toList services)


viewServiceItem : Model -> ( Int, Service ) -> List (ListGroup.CustomItem Msg)
viewServiceItem model serviceTuple =
    let
        id =
            first serviceTuple

        service =
            second serviceTuple
    in
    List.concat
        [ [ ListGroup.anchor
                [ ListGroup.attrs [ Flex.block, Flex.justifyBetween, href ("/service/" ++ String.fromInt id) ] ]
                [ div [ Flex.block, Flex.justifyBetween, Size.w100 ]
                    [ span [ class "pt-1" ] [ FeatherIcons.server |> FeatherIcons.withSize 19 |> FeatherIcons.toHtml [], text service.name ]
                    , span [ class "text-danger", Html.Events.Extra.onClickPreventDefaultAndStopPropagation (DeleteService id) ] [ FeatherIcons.trash2 |> FeatherIcons.withSize 16 |> FeatherIcons.toHtml [] ]
                    ]
                ]
          ]
        , viewTaskItem id
        , viewContainers (getContainers id model.containers)
        ]


viewTaskItem : Int -> List (ListGroup.CustomItem Msg)
viewTaskItem id =
    [ ListGroup.anchor
        [ ListGroup.attrs [ Flex.block, Flex.justifyBetween, style "padding-left" "40px", href ("/task/" ++ String.fromInt id) ] ]
        [ div [ Flex.block, Flex.justifyBetween, Size.w100 ]
            [ span [ class "pt-1" ] [ FeatherIcons.clipboard |> FeatherIcons.withSize 19 |> FeatherIcons.toHtml [], text "Tasks" ]
            , span [] [ Button.button [ Button.outlineSuccess, Button.small, Button.onClick (AddContainer id) ] [ FeatherIcons.plus |> FeatherIcons.withSize 16 |> FeatherIcons.withClass "empty-button" |> FeatherIcons.toHtml [], text "" ] ]
            ]
        ]
    ]


getContainers : Int -> Containers -> Containers
getContainers serviceId containers =
    let
        associateContainer _ container =
            if container.serviceId == serviceId then
                Just container

            else
                Nothing
    in
    containers |> filterMap associateContainer


viewContainers : Containers -> List (ListGroup.CustomItem Msg)
viewContainers containers =
    List.map viewContainerItem (Dict.toList containers)


viewContainerItem : ( Int, Container ) -> ListGroup.CustomItem Msg
viewContainerItem containerTuple =
    let
        id =
            first containerTuple

        container =
            second containerTuple
    in
    ListGroup.anchor [ ListGroup.attrs [ href ("/container/" ++ String.fromInt id), style "padding-left" "60px" ] ] [ 
        FeatherIcons.box |> FeatherIcons.withSize 19 |> FeatherIcons.toHtml []
        , text container.name
        , span [ class "ml-3 text-danger float-right", Html.Events.Extra.onClickPreventDefaultAndStopPropagation (DeleteContainer id)] [ FeatherIcons.trash2 |> FeatherIcons.withSize 16 |> FeatherIcons.toHtml [] ]
    ]



simpleListItem : String -> FeatherIcons.Icon -> List (Html.Attribute Msg) -> ListGroup.CustomItem Msg
simpleListItem label icon attrs =
    ListGroup.anchor [ ListGroup.attrs attrs ] [ icon |> FeatherIcons.withSize 19 |> FeatherIcons.toHtml [], text label ]
