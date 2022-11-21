#!/usr/bin/env bash

# <bitbar.title>JD Gold</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Felix2yu</bitbar.author>
# <bitbar.author.github>felix2yu</bitbar.author.github>
# <bitbar.desc>Show JD Gold price. the price only show up in market time.</bitbar.desc>
# <bitbar.dependencies>bash,jq,bc</bitbar.dependencies>
# <bitbar.abouturl>https://yufei.im</bitbar.abouturl>

function MarketClosed() {
  echo "休市|color=#7397ab" #蒼青色
  exit
}

function ShowPrice() {
  PriceChange=$(echo "$latestPrice - $yesterdayPrice" | bc)
  PriceChangePercent=$(echo "scale=2; 100*($latestPrice - $yesterdayPrice)/$yesterdayPrice" | bc)
  printf '¥'"%-5.2f" $latestPrice
  echo " $PriceChange $PriceChangePercent%|color=$color"
}

if [ "$(date +%w)" -eq 0 ]; then
  MarketClosed
elif [ "$(date +%w)" = 6 ] && [ "$(date +%H)" -ge 4 ]; then
  MarketClosed
elif [ "$(date +%w)" -eq 1 ] && [ "$(date +%H)" -lt 9 ]; then
  MarketClosed
fi

getPrice=$(curl -s https://api.jdjygold.com/gw/generic/hj/h5/m/latestPrice)
latestPrice="$(echo $getPrice | jq .resultData.datas.price | sed 's/\"//g')"
yesterdayPrice="$(echo $getPrice | jq .resultData.datas.yesterdayPrice | sed 's/\"//g')"

if [ $(echo "$latestPrice == $yesterdayPrice" | bc) -eq 1 ]; then
  color="default"
elif [ $(echo "$latestPrice > $yesterdayPrice" | bc) -eq 1 ]; then
  color="#ff4c00" #硃紅色
elif [ $(echo "$latestPrice < $yesterdayPrice" | bc) -eq 1 ]; then
  color="#0eb840" #蔥蒨色
fi

ShowPrice
