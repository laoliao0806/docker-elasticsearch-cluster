#!/bin/bash
[[ $DEBUG ]] && set -x 

sed -i -e "s/POD_IP/${POD_IP:-'0.0.0.0'}/g" \
       -e "s/HOSTNAME/${HOSTNAME}.${HOSTNAME%-*}.${TENANT_ID}.svc.cluster.local./g" /usr/share/elasticsearch/config/elasticsearch.yml

sleep 10
CURRENT_POD_NUM=$(nslookup ${SERVICE_NAME} | grep Address | sed '1d' | awk '{print $2}' | wc -l)
[[ $DEBUG ]] && echo $(nslookup ${SERVICE_NAME})> ./logfile
if [[ $CURRENT_POD_NUM -gt 1 ]];then
#    sed -i '$a\cluster.initial_master_nodes' /usr/share/elasticsearch/config/elasticsearch.yml
#    sed -i '$a\discovery.seed_hosts' /usr/share/elasticsearch/config/elasticsearch.yml
    ip=$(nslookup ${SERVICE_NAME} | grep Address | sed '1d' | awk '{print $2}')
    ips=$(echo $ip | tr ' ' ',')
    [[ $DEBUG ]] && echo ${ip} >> ./logfile
    sed -i "s/cluster.initial_master_nodes*/cluster.initial_master_nodes: [${ips}]/g" /usr/share/elasticsearch/config/elasticsearch.yml
    sed -i "s/discovery.seed_hosts*/discovery.seed_hosts: [${ips}]/g" /usr/share/elasticsearch/config/elasticsearch.yml
fi

[[ $DEBUG ]] && cat /usr/share/elasticsearch/config/elasticsearch.yml

[[ $PAUSE ]] && sleep $PAUSE

exec $@
