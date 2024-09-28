:global subdomainHashes {"U3dWVE5V01TWxPcjluEo0bEtJQWjg5DUz=";"U3pWV5VFTWxPcjlOEo0EtJpOE1MAyDc="};
:global domainsDNS {"aaa.xyz.pu";"bbb.xyz.pu"};
:global interfacesWAN {"ether4-WAN-Inet";"ether3-WAN-Beeline"};

# Script for updating DDNS records on FreeDNS.afraid.org
# Script uses ideas by Chupakabra303
# http://habrahabr.ru/post/270719/
# tested on ROS 6.49.17 & 7.16
# updated 2024/09/26

:do {
  :local ifcWAN {"ether3-ISP";"ether2-ISP";"ether1-ISP"};
  :local dmnDNS {"aaa.xyz.pu";"bbb.xyz.pu";"ccc.xyz.pu"};
  :local subDmnHsh {"TElRcWlwRzNYMHNnZ2NCR3VmeE92a2pnOjE5MTgXXXXX";"TElRcWlwRzNYMHNnZ2NCR3VmeE92a2pnOjE5MTgXXXXX";"TElRcWlwRzNYMHNnZ2NCR3VmeE92a2pnOjIyMTAXXXXX"};
  :local quant [:len $dmnDNS]; :local skipCnt; :local msg "Start of updating DDNS script on router: $[/system identity get name]";
  :global lastIPs;
  :if ([:typeof $skipCnt]!="array") do={:set $skipCnt {""}; :for i from=0 to=($quant-1) do={:set ($skipCnt->$i) 1}}
  :if ([:typeof $lastIPs]!="array") do={:set $lastIPs {""}; :for i from=0 to=($quant-1) do={:set ($lastIPs->$i) ""}}
  :for i from=0 to=($quant-1) do={
    :local currIP [/ip dhcp-client get [find interface=($ifcWAN->$i)] address];
    :set $currIP [:pick $currIP 0 [:find $currIP "/"]];
    :set $msg "$msg\r\n>>> $[($ifcWAN->$i)] IP=$currIP";
    :if ([:len $currIP]>0 && ($currIP!=($lastIPs->$i) or ($skipCnt->$i)>59)) do={
      :if ($currIP!=($lastIPs->$i)) do={
        :set $msg "$msg changed for $[($dmnDNS->$i)] (old IP=$[($lastIPs->$i)])";
        :log warning ">>> DynDNS: $[($lastIPs->$i)] for $[($dmnDNS->$i)] to $currIP on $[($ifcWAN->$i)]";
      }
      :local url "http://freedns.afraid.org/dynamic/update.php\?$[($subDmnHsh->$i)]&address=$currIP";
      :local method "put"; # or "post"
      /tool fetch http-method=$method url=$url keep-result=no;
      :set ($lastIPs->$i) $currIP; :set ($skipCnt->$i) 1;
    } else={:set ($skipCnt->$i) (($skipCnt->$i)+1); :set $msg "$msg nothing has changed"}
  }
  :put $msg;
} on-error={log warning "Error on script of updating DDNS records"}
