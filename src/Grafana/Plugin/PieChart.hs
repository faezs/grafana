{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Grafana.Plugin.PieChart where

import Data.Aeson (ToJSON(..))
import Data.Aeson ((.=), Value(..))
import Data.Map.Strict (Map)
import Data.Text (Text)

import qualified Data.Aeson as AE

import Grafana

data PieType = Donut | Pie

instance ToJSON PieType where
  toJSON = \case
    Donut -> "donut"
    Pie -> "pie"

data PieChart = PieChart
  { pieChartTitle :: Text
  , pieChartQueries :: [Query]
  , pieChartUnit :: Maybe UnitFormat
  , pieChartAliasColors :: Map Text RGBA
  , pieType :: PieType
  }

pieChartToPairs :: PieChart -> [(Text, AE.Value)]
pieChartToPairs (PieChart {..}) =
  [ "type" .= String "grafana-piechart-panel"
  , "title" .= pieChartTitle
  , "targets" .= makeTargets pieChartQueries
  , "format" .= pieChartUnit
  , "pieType" .= pieType
  , "aliasColors" .= pieChartAliasColors
  ]

pieChartPanel :: PieChart -> GridPos -> Panel
pieChartPanel = Panel . pieChartToPairs
