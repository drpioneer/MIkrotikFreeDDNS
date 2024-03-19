# Script for updating DDNS records on FreeDNS.afraid.org
# Script uses ideas by Chupakabra303
# http://habrahabr.ru/post/270719/
# tested on ROS 6.49.10 & 7.12
# updated 2024/03/19

:do {
  :global lastIPs;
  :local ifcWAN {"ether3-WAN3";"ether2-WAN2";"ether1-WAN1"};
  :local dmnDNS {"aaa.xyz.pu";"bbb.xyz.pu";"ccc.xyz.pu"};
  :local subDmnHsh {"TElRcWlwRzNYMHNnZ2NCR3VmeE92a2pnOjE5MTg1ODM4";"TElRcWlwRzNYMHNnZ2NCR3VmeE92a2pnOjE5MTg2OTAx";"TElRcWlwRzNYMHNnZ2NCR3VmeE92a2pnOjIyMTA4NzUw"};
  :local quant [:len $dmnDNS]; :local skipCnt; :local msg "Start of updating DDNS script on router: $[/system identity get name]";
  :if ([:typeof $skipCnt]!="array") do={:set skipCnt {""}; :for i from=0 to=($quant-1) do={:set ($skipCnt->$i) 1}}
  :if ([:typeof $lastIPs]!="array") do={:set lastIPs {""}; :for i from=0 to=($quant-1) do={:set ($lastIPs->$i) ""}}
  :for i from=0 to=($quant-1) do={
    :local currIP [/ip dhcp-client get [find interface=($ifcWAN->$i)] address];
    :set currIP [:pick $currIP 0 [:find $currIP "/"]]; :set msg "$msg\r\n>>> $[($ifcWAN->$i)] IP=$currIP";
    :if ([:len $currIP]>0 && ($currIP!=($lastIPs->$i) or ($skipCnt->$i)>59)) do={
      :if ($currIP!=($lastIPs->$i)) do={
        :set msg "$msg changed for $[($dmnDNS->$i)] (old IP=$[($lastIPs->$i)])";
        :log warning ">>> DynDNS: $[($lastIPs->$i)] for $[($dmnDNS->$i)] to $currIP on $[($ifcWAN->$i)]";
      }
      /tool fetch url="http://freedns.afraid.org/dynamic/update.php\?$[($subDmnHsh->$i)]&address=$currIP" keep-result=no;
      :set ($lastIPs->$i) $currIP; :set ($skipCnt->$i) 1;
    } else={:set ($skipCnt->$i) (($skipCnt->$i)+1); :set msg "$msg nothing has changed"}
  }
  :put $msg;
}
