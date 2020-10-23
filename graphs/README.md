# Graphs using Gnuplot

## Installing Gnuplot

```bash
brew install gnuplot
```

## Displaying a graph

When we run a plot we pass in the CSV file sa a parameter, like so:

```bash
gnuplot -e "csv='<PATH>'" -p <GRAPH>.gnuplot
```

Example:

```bash
gnuplot -e "csv='../output/google.ie.csv'" -p packetloss.gnuplot
```

This should open the graph for you n a new window.
