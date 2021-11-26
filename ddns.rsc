# Script for updating DDNS records on FreeDNS.afraid.org
# http://habrahabr.ru/post/270719/
# tested on ROS 6.46.5
# updated 2020/05/06

:global subdomainHashes;
:global domainsDNS;
:global interfacesWAN;

:global quant [:len $domainsDNS];
:global skipCounters;
:if ([:typeof $skipCounters] != "array") do={
    :set skipCounters {""};
    :for i from=0 to=($quant-1) do={ :set ($skipCounters->$i) 1};
}

:global lastIPs;
:if ([:typeof $lastIPs] != "array") do={
    :set lastIPs {""};
    :for i from=0 to=($quant-1) do={ :set ($lastIPs->$i) ""};
}

:for i from=0 to=($quant-1) do={
    :local currentIP "";
    :set currentIP [/ip dhcp-client get [find where interface=($interfacesWAN->$i)] address];
    :set currentIP [:pick $currentIP 0 ([:find $currentIP "/"])];
    :if ([:len $currentIP] > 0 and ($currentIP != ($lastIPs->$i) or ($skipCounters->$i) > 59)) do={
        :if ($currentIP != ($lastIPs->$i)) do={
            :log warning (">>>       DynDNS: ".($lastIPs->$i)." for ".($domainsDNS->$i)." to $currentIP on ".($interfacesWAN->$i) );
        }
        /tool fetch url=("http://freedns.afraid.org/dynamic/update.php\?".($subdomainHashes->$i)."&address=".$currentIP) keep-result=no;
        :set ($lastIPs->$i) $currentIP;
        :set ($skipCounters->$i) 1;
    } else={ :set ($skipCounters->$i) (($skipCounters->$i) + 1); }
}
