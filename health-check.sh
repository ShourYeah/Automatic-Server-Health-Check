#!/bin/bash

#------variables used------#
S="************************************"
D="-------------------------------------"
COLOR="y"

# Function to print a table header and footer
function print_table_header() {
  echo -e "\n+------------------------------------------------------------------------+"
  echo -e "| $(printf "%-40s" "$1") |"
  echo -e "+------------------------------------------------------------------------+"
}

function print_table_footer() {
  echo -e "+------------------------------------------------------------------------+"
}



MOUNT=$(mount|egrep -iw "ext4|ext3|xfs|gfs|gfs2|btrfs"|grep -v "loop"|sort -u -t' ' -k1,2)
FS_USAGE=$(df -PThl -x tmpfs -x iso9660 -x devtmpfs -x squashfs|awk '!seen[$1]++'|sort -k6n|tail -n +2)
IUSAGE=$(df -iPThl -x tmpfs -x iso9660 -x devtmpfs -x squashfs|awk '!seen[$1]++'|sort -k6n|tail -n +2)

if [ $COLOR == y ]; then
{
 GCOLOR="\e[47;32m ------ OK/HEALTHY \e[0m"
 WCOLOR="\e[43;31m ------ WARNING \e[0m"
 CCOLOR="\e[47;31m ------ CRITICAL \e[0m"
}
else
{
 GCOLOR=" ------ OK/HEALTHY "
 WCOLOR=" ------ WARNING "
 CCOLOR=" ------ CRITICAL "
}
fi

echo -e "$S"
echo -e "\tSystem Health Status"
echo -e "$S"
printf
#--------Print system uptime-------#

print_table_header "System Uptime"

UPTIME=$(uptime)
echo -en "System Uptime : "
echo $UPTIME|grep day &> /dev/null
if [ $? != 0 ]; then
  echo $UPTIME|grep -w min &> /dev/null && echo -en "$(echo $UPTIME|awk '{print $2" by "$3}'|sed -e 's/,.*//g') minutes" \
 || echo -en "$(echo $UPTIME|awk '{print $2" by "$3" "$4}'|sed -e 's/,.*//g') hours"
else
  echo -en $(echo $UPTIME|awk '{print $2" by "$3" "$4" "$5" hours"}'|sed -e 's/,//g')
fi
echo -e "\nCurrent System Date & Time : "$(date +%c)

print_table_footer

#--------Check disk usage on all mounted file systems--------#

print_table_header "Disk Usage"


# echo -e "\n\nChecking For Disk Usage On Mounted File System[s]"
# echo -e "$D$D"
echo -e "( 0-85% = OK/HEALTHY,  85-95% = WARNING,  95-100% = CRITICAL )"
echo -e "$D$D"
echo -e "Mounted File System[s] Utilization (Percentage Used):\n"

COL1=$(echo "$FS_USAGE"|awk '{print $1 " "$7}')
COL2=$(echo "$FS_USAGE"|awk '{print $6}'|sed -e 's/%//g')

for i in $(echo "$COL2"); do
{
  if [ $i -ge 95 ]; then
    COL3="$(echo -e $i"% $CCOLOR\n$COL3")"
  elif [[ $i -ge 85 && $i -lt 95 ]]; then
    COL3="$(echo -e $i"% $WCOLOR\n$COL3")"
  else
    COL3="$(echo -e $i"% $GCOLOR\n$COL3")"
  fi
}
done
COL3=$(echo "$COL3"|sort -k1n)
paste  <(echo "$COL1") <(echo "$COL3") -d' '|column -t

print_table_footer


#--------Check for Processor Utilization (current data)--------#

print_table_header "Processor Utilization"


# echo -e "\n\nChecking For Processor Utilization"
# echo -e "$D"
echo -e "\nCurrent Processor Utilization Summary :\n"
mpstat|tail -2

print_table_footer

#--------Check for load average (current data)--------#

print_table_header "Load Average"

# echo -e "\n\nChecking For Load Average"
# echo -e "$D"
echo -e "\e[47;32mCurrent Load Average\e[0m : \e[47;31m$(uptime|grep -o "load average.*"|awk '{print $3" " $4" " $5}')\e[0m"
print_table_footer

#------Print most recent 3 reboot events if available----#

print_table_header "Last 3 Reboots"


# echo -e "\n\nMost Recent 3 Reboot Events if available"
echo -e "$D$D"
last -x 2> /dev/null|grep reboot 1> /dev/null && /usr/bin/last -x 2> /dev/null|grep reboot|head -3 || \
echo -e "No reboot events are recorded."

print_table_footer


#------Print most recent 3 shutdown events if available-----#

print_table_header "Last 3 Shutdowns if available"


# echo -e "\n\nMost Recent 3 Shutdown Events"
echo -e "$D$D"
last -x 2> /dev/null|grep shutdown 1> /dev/null && /usr/bin/last -x 2> /dev/null|grep shutdown|head -3 || \
echo -e "No shutdown events are recorded."

print_table_footer


#--------Print top 5 Memory & CPU consumed process threads---------#
#--------excludes current running program which is hwlist----------#

print_table_header "Top 5 Memory Resource Hog Processes"


# echo -e "\n\nTop 5 Memory Resource Hog Processes"
echo -e "$D$D"
ps -eo pmem,pid,ppid,user,stat,args --sort=-pmem|grep -v $$|head -6|sed 's/$/\n/'

print_table_footer


print_table_header "Top 5 CPU Resource Hog Processes"

# echo -e "\nTop 5 CPU Resource Hog Processes"
echo -e "$D$D"
ps -eo pcpu,pid,ppid,user,stat,args --sort=-pcpu|grep -v $$|head -6|sed 's/$/\n/'

print_table_footer


echo -e "NOTE:- If any of the above fields are marked as \"blank\" or \"NONE\" or \"UNKNOWN\" or \"Not Available\" or \"Not Specified\"
that means either there is no value present in the system for these fields, otherwise that value may not be available,
or suppressed since there was an error in fetching details."
