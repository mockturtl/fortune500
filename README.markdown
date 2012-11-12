# fortune500

fortune500 scrapes [CNN.com's list of Fortune 500 companies](http://money.cnn.com/magazines/fortune/fortune500/2012/full_list/) to calculate their total revenue and profit.

I hope someone finds it useful as a brief exercise in \*nix tools, or politics.

## usage

To see a different year's data (2009-present), set the `YEAR` variable and refresh the download cache.

```sh
YEAR=2010 ./fortune500 -d
```
