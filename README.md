# Netcheck

A simple way to keep tabs on your ISP performance. It will ping a domain of your choice every 30
seconds and write the results to `output/<your-domain>.csv` for later analysis.

## Usage

There is a binary included, so you can kick it off in the background like so:

```bash
./bin/netcheck google.ie > output/run.log 2>&1 &
```

Program output and errors will be written to `output/run.log`.

## Analysis

The statistics provided by the `ping` program will be collected every 30 seconds (3 commands are
issued, i.e. `ping -c 3 <your-domain>` is executed) and written to the CSV file.

The CSV file will look like so:

```csv
"ts","success","pkt_loss_percent","min","avg","max","stddev"
"2020-10-11T19:21:20Z","true","0.0","18.478","18.65","18.848","0.152"
"2020-10-11T19:21:52Z","true","0.0","12.166","13.618","15.797","1.569"
"2020-10-11T19:22:24Z","true","0.0","14.495","17.079","18.747","1.853"
```

A failure to execute the ping will result in a line like so:

```csv
"2020-10-11T23:16:13Z","false","-","-","-","-","-"
```

## Graphing results

Instructions on how to get yourself some pretty [Gnuplot](http://www.gnuplot.info/) graphs based on the CSV files output can be found [here](./graphs/README.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ciaranarcher/netcheck.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
