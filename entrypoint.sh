#!/bin/bash
set -e

# allow arguments to be passed to squid
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --  #If no arguments follow this option, then the positional parameters are unset.
          #Otherwise, the positional parameters are set to the arguments,
          #even if some of them begin with a '-'.
elif [[ ${1} == /opt/duoauthproxy/bin/authproxy ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

CONFIG_GEN=1
for env in DUO_AD_HOST DUO_AD_USER DUO_AD_PASSWORD DUO_AD_SEARCH_DN DUO_INTEGRATION_KEY DUO_SECRET_KEY DUO_API_HOSTNAME DUO_RADIUS_SECRET DUO_FAILMODE DUO_PORT
do
  if [ -z "${!env}" ]
    then
    echo $env is not set. Skipping config generation.
    CONFIG_GEN=0
    break
  fi
done
NL=$'\n'
if [ $CONFIG_GEN -eq 1 ]
then
  echo "[main]${NL}debug=${DEBUG}${NL}log_auth_events=true${NL}log_sso_events=true${NL}log_stdout=true${NL}" > /opt/duoauthproxy/conf/authproxy.cfg;
  echo "${NL}[ad_client]${NL}host=${DUO_AD_HOST}${NL}service_account_username=${DUO_AD_USER}${NL}service_account_password=${DUO_AD_PASSWORD}${NL}search_dn=${DUO_AD_SEARCH_DN}${NL}" >> /opt/duoauthproxy/conf/authproxy.cfg;
  echo "${NL}[radius_server_auto]${NL}ikey=${DUO_INTEGRATION_KEY}${NL}skey=${DUO_SECRET_KEY}${NL}api_host=${DUO_API_HOSTNAME}${NL}radius_ip_1=0.0.0.0/0${NL}radius_secret_1=${DUO_RADIUS_SECRET}${NL}failmode=${DUO_FAILMODE}${NL}client=ad_client${NL}port=${DUO_PORT}" >> /opt/duoauthproxy/conf/authproxy.cfg;
fi

# default behaviour is to launch authproxy
if [[ -z ${1} ]]; then #if there are no extra arguments i.e. ${1} is null.
  echo "Starting authproxy..."
  exec /opt/duoauthproxy/bin/authproxy ${EXTRA_ARGS}
else
  exec "$@"
fi

