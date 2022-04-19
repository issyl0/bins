# bins

Very hacky, only works for Horsham council.

Requirements:

```shell
docker build . -t issyl0/bins
docker run -p 4567:4567 issyl0/bins -e BINS_ADDRESS="<number>, <road>, <area>, Horsham, West Sussex, <postcode>"
```
