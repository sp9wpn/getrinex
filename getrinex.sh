#!/bin/bash
TMP_DIR=/tmp

# Aby miec dostep do danych na serwerze NASA, nalezy zalozyc konto na stronie:
#   https://urs.earthdata.nasa.gov/users/new
# a nastepnie w katalogu glownym uzytkownika umiescic plik ~/.netrc o tresci:
# machine urs.earthdata.nasa.gov login <login> password <haslo>

# To access data on NASA server, you need to register on the website:
#   https://urs.earthdata.nasa.gov/users/new
# then create a ~/.netrc file in user home directory containing:
# machine urs.earthdata.nasa.gov login <login> password <password>

if [ -z "$1" ] ; then
  echo "Usage:  $0 <local_rinex>"
  echo ""
  echo "  local_rinex - filename to place downloaded rinex data into"
  exit 0
fi


dzien=$(date -u +%j)
rok2=$(date -u +%y)
rok4=$(date -u +%Y)

if [ "$1" = "yesterday" ] ; then
  dzien=$(date --date='yesterday' -u +%j)
  rok2=$(date --date='yesterday' -u +%y)
  rok4=$(date --date='yesterday' -u +%Y)
fi

urls[0]=ftp://igs.bkg.bund.de/IGS/BRDC/${rok4}/${dzien}/brdc${dzien}0.${rok2}n.gz
urls[1]=https://cddis.nasa.gov/archive/gnss/data/daily/${rok4}/${dzien}/${rok2}n/brdc${dzien}0.${rok2}n.gz
urls[2]=https://cddis.nasa.gov/archive/gnss/data/daily/${rok4}/brdc/brdc${dzien}0.${rok2}n.gz
# urls[3]=http://aprs.ehamnet.cz/gps_rinex_usable_1h_nasa.txt

for u in ${urls[@]}; do
  if [ ${u: -3} = '.GZ' -o  ${u: -3} = '.gz' ] ; then
    rm -f ${TMP_DIR}/rinex.txt.tmp.gz
    wget --auth-no-challenge --timeout=20 -t 3 -O ${TMP_DIR}/rinex.txt.tmp.gz $u || continue
    gzip -f -d ${TMP_DIR}/rinex.txt.tmp.gz || continue
  else
    rm -f ${TMP_DIR}/rinex.txt.tmp
    wget --auth-no-challenge --timeout=20 -t 3 -O ${TMP_DIR}/rinex.txt.tmp $u || continue
  fi

  if [ -r ${TMP_DIR}/rinex.txt.tmp -a `wc -c ${TMP_DIR}/rinex.txt.tmp | cut -d " " -f 1` -gt 2000 ] ; then
    mv -f ${TMP_DIR}/rinex.txt.tmp $1
    exit 0
  fi
done


# no success, try yesterday's file
if [ "$1" != "yesterday" ] ; then
  echo "retry for yesterday's file"
  $0 yesterday
fi
