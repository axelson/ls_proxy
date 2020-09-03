defmodule LsppWebWeb.BarchartHelpers do
  def lookup_colours("pastel"), do: :pastel1
  def lookup_colours("default"), do: :default
  def lookup_colours("warm"), do: :warm
  def lookup_colours("themed"), do: ["ff9838", "fdae53", "fbc26f", "fad48e", "fbe5af", "fff5d1"]

  def lookup_colours("custom"),
    do: ["004c6d", "1e6181", "347696", "498caa", "5da3bf", "72bbd4", "88d3ea", "9eebff"]

  def lookup_colours("nil"), do: nil
  def lookup_colours(_), do: nil
end
