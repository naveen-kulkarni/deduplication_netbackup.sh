#!/bin/bash

##########################################################################################
# Name    :  dup_src_v3.sh                     		                                 #
# Owner   :  root                                                                        #
# Date    :                          		                                         #
# Version :  1                                                                           #
# Author  :  						                                 #
# Permission : 750                                                                       #
# Shell script to check the Cloud Duplication Report of backup and present us with       #
# backup image count and backup image size.                                              #
##########################################################################################

NOW=$(date +"%F")
LOGDIR=$PWD/log
DIRTYPE=($LOGDIR )

#cleanupdir() {
        if [ -d $LOGDIR ]
        then
                rm -rf $LOGDIR
        else
               echo ""

        fi
#}

for DIRTYPE in "${DIRTYPE[@]}"
do
        if [ -d $DIRTYPE ]
        then
                echo ""
        else
                mkdir -p $DIRTYPE
        fi
done
BACKUPFILTERLOG=$LOGDIR/bkp_filter.log
BACKUPOUTPUTLOG=$LOGDIR/bkp_output.log
PRESENTDATE=$(date +%m/%d/%Y)
FIRSTDAY=$(date -d "-0 month -$(($(date +%d)-1)) days" +%m/%d/%Y)
STARTTIME="00:01:00"
ENDTIME="10:00:00"
BACKUPLOG=$LOGDIR/backup.csv
DUPBACKUPLOG=$LOGDIR/duplicateBackup.csv
#DUPCOUNT=$(cat $DUPBACKUPLOG |wc -l)
#BKPCOUNT=$(cat $BACKUPLOG |wc -l)
TOTALSIZE=$LOGDIR/totalsize.log
DUPSIZE=$LOGDIR/dup_size.log
BKP_SIZE=$LOGDIR/bkp_size.log
COUNTLOG=$LOGDIR/countlog.log
INFOLOG=$LOGDIR/info.txt
STARTC=$PWD/start
ENDC=$PWD/end
MYCUSTOMTAB='                            '
BKPLOG=$LOGDIR/bkpsizelog.log
DUPBKPLOG=$LOGDIR/dupbkpsizelog.log
####################################################################################
backupDupCheck () {
#BKPFILTER=$(bpimagelist -L -d $FIRSTDAY $STARTTIME -e $PRESENTDATE $ENDTIME |grep -i 'Backup ID\|Sched Label\|Number of Copies')
BKPFILTER=$(bpimagelist -L -d 05/01/2020 18:00:00 -e 05/01/2020 20:00:00 |grep -i -w 'Backup ID\|Sched Label\|Number of Copies')

echo "$BKPFILTER" > $BACKUPFILTERLOG

BKPOUTPUT=$(cat $BACKUPFILTERLOG | awk '{line=line " " $0} NR%3==0{print substr(line,2); line=""}'|grep -i -w 'Quarterly\|Monthly'|grep -i -v 'n01nas01' )

echo "$BKPOUTPUT" > $BACKUPOUTPUTLOG

 IFS=$'\n';
        for BKPCHECK in `cat $BACKUPOUTPUTLOG`;
         do
                BACKUPID=$(echo $BKPCHECK |awk -F ":" '{print $2}'|awk '{print $1}')
                COPIESNUM=$(echo $BKPCHECK |awk '{print $NF}')
                if [ "$COPIESNUM" == 1 ]
                then

                        echo "$BACKUPID " >> $BACKUPLOG
                else
                             echo "$BACKUPID " >> $DUPBACKUPLOG
                fi
         done
}
####################################################################################
## Count of total duplicate backup
dupBackupCount() {

#DUPCOUNT=$(cat $DUPBACKUPLOG |wc -l) &>/dev/null
#BKPCOUNT=$(cat $BACKUPLOG |wc -l)
if [ -f $DUPBACKUPLOG ]
then
        DUPCOUNT=$(cat $DUPBACKUPLOG |wc -l) &>/dev/null
                echo -e "No of Backup images successfully  duplicated  to Cloud = $DUPCOUNT          " >> $COUNTLOG
        else
                echo -e "No of Backup images successfully duplicated  to Cloud = 00                  " >> $COUNTLOG
        fi

}
####################################################################################
#### total number of successfull backup

backupCount() {
#DUPCOUNT=$(cat $DUPBACKUPLOG |wc -l)
#BKPCOUNT=$(cat $BACKUPLOG |wc -l) &>/dev/null
if [ -f $BACKUPLOG ]
then
                BKPCOUNT=$(cat $BACKUPLOG |wc -l) &>/dev/null
                echo -e "No of Backup images not duplicated to Cloud = $BKPCOUNT                    " >> $COUNTLOG

        else
                echo -e "No of Backup images not duplicated to Cloud = 00                           " >> $COUNTLOG

fi

}


#echo -e "No of Backup images not duplicated  to Cloud = $DUPCOUNT" >> $COUNTLOG
#echo -e "No of Backup images successfully duplicated to Cloud = $BKPCOUNT" >> $COUNTLOG


####################################################################################
##  Totla size of duplicate backup

duplicateBackupSize() {
if [ -f $DUPBACKUPLOG ]
  then
        for DUPSIZES in `cat $DUPBACKUPLOG`;
        do
                bpimagelist -backupid $DUPSIZES -U | grep -v "^[KB-]" | awk '{ print $5 }'  >> $DUPSIZE;
        done
                awk '{ sum += $1 } END { print "Size of images duplicated = "sum/1024/1024/1024 " TB                " }' $DUPSIZE >> $DUPBKPLOG
  else
               echo -e "Size of images  duplicated = 00                          " >>$DUPBKPLOG

fi

}


####################################################################################
##  Totla size of successfull backup
backupSize() {

if [ -f $BACKUPLOG ]
  then
        for BKPSIZE in `cat $BACKUPLOG`;
        do
                bpimagelist -backupid $BKPSIZE -U | grep -v "^[KB-]" | awk '{ print $5 }'  >> $BKP_SIZE;
        done
                awk '{ sum += $1 } END { print "Size of images not duplicated = " sum/1024/1024/1024 " TB               "}' $BKP_SIZE >> $BKPLOG
  else
               echo -e "Size of images not duplicated = 00                      " >>$BKPLOG
fi

}

####################################################################################
##  Totla size of duplicate backup + duplicate backup

totalSize() {

if [[ -f $BKP_SIZE && -f $DUPSIZE ]]
then
        awk '{ sum += $1 } END { print "Total Size = "sum/1024/1024/1024 " TB           "}' $BKP_SIZE $DUPSIZE >> $TOTALSIZE
elif [[ ! -f $BKP_SIZE && -f $DUPSIZE ]]
then
        awk '{ sum += $1 } END { print "Total Size = "sum/1024/1024/1024 " TB           "}'  $DUPSIZE >> $TOTALSIZE
elif [[ ! -f $DUPSIZE  && -f $BKP_SIZE ]]
then
        awk '{ sum += $1 } END { print "Total Size = "sum/1024/1024/1024 " TB            "}'  $BKP_SIZE >> $TOTALSIZE
else
        echo -e "No data exist!" >> $TOTALSIZE
fi
}


logshow() {
logs=($STARTC $COUNTLOG $ENDC $DUPBKPLOG $BKPLOG $TOTALSIZE)
for logType in "${logs[@]}"
do
if [ -f $logType ]
then
        if [ -s $logType ]
        then
                        cat $logType >> $INFOLOG
                fi
fi
done
}



#cleanupdir
backupDupCheck
dupBackupCount
backupCount
duplicateBackupSize
backupSize
totalSize
logshow

####################################################################################

mailx -s "Cloud Duplication Report" -a $BACKUPLOG -a $DUPBACKUPLOG  naveenvk88@gmail.com < $INFOLOG
