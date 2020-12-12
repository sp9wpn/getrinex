#!/bin/bash
SCRIPT_DIR=${PWD}
cd /tmp/


# Aby miec dostep do danych na serwerach NASA, nalezy zalozyc konto na stronie:
#   https://urs.earthdata.nasa.gov/users/new
# a nastepnie w katalogu glownym uzytkownika umiescic plik ~/.netrc o tresci:
# machine urs.earthdata.nasa.gov login <login> password <haslo>

# To access data on NASA server, you need to register on the website:
#   https://urs.earthdata.nasa.gov/users/new
# then create a ~/.netrc file in user home directory containing:
# machine urs.earthdata.nasa.gov login <login> password <password>


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
  if [ ${u: -2} = '.Z' -o  ${u: -2} = '.z' ] ; then
    rm -f rinex.txt.tmp.Z
    wget --auth-no-challenge -t 3 -O rinex.txt.tmp.Z $u || continue
    gzip -f -d rinex.txt.tmp.Z || continue
  else
    rm -f rinex.txt.tmp
    wget --auth-no-challenge -t 3 -O rinex.txt.tmp $u || continue
  fi

  if [ -r rinex.txt.tmp -a `wc -c rinex.txt.tmp | cut -d " " -f 1` -gt 2000 ] ; then
    mv -f rinex.txt.tmp /home/pi/dxlAPRS/tmp/rinex.txt
    exit 0
  fi
done


# Próbujemy wczorajszy
if [ "$1" != "yesterday" ] ; then
  echo "retry for yesterday's file"
  cd ${SCRIPT_DIR}
  $0 yesterday
fi
