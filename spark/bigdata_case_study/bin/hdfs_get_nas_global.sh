###########################################################################
#Global Name: hdfs_get_nas_global.sh                                      #
#Description: utitlity HDFS Get script used for getting Files from HDFS to#
#             local nas.                                                  #
#usage      : sh hdfs_get_nas.sh -s <src-hdfs-path> -t <tgt-nas-path>     #
#Scope :      Generic Utility - Global                                    #
#Author:      Biswadeep Upadhyay                                          #
###########################################################################


dtime=`date +"%Y%m%d_%H%M%S"`
var_dt=`date +"%Y%m%d"`

while getopts ":s:t:m:" opt
   do
     case $opt in
        s ) Src_HDFS=$OPTARG;;
        t ) Tgt_Feed=$OPTARG;;
	    m ) v_mode=$OPTARG;;
        \? ) exit 1 ;; 
     esac
   done

if [ `whoami` != "airflow"  ];
then
{
echo $date"::[ERROR]:Please check the executing user . This script runs with airflow user ." 
echo $date"::[ERROR]:The script only runs with airflow user. Exiting with error code 1."
exit 1
}
fi

echo "hdfs feed: "$Src_HDFS
echo "target nas file: "$Tgt_Feed
echo "hdfs get mode: "$v_mode

#the available get modes are : ge : default get , gm : default getmerge , gh : get with header , gw : get without header

if [ $v_mode == "ge" ];
then
   hadoop fs -get -f $Src_HDFS $Tgt_Feed

   if [ $? -eq 0 ]
    then
        date=`date '+%Y/%m/%d %H:%M:%S'`
        echo $date"::[INFO]:HDFS get from $Src_HDFS to $Tgt_Feed: Success."
        exit 0
    else
        date=`date '+%Y/%m/%d %H:%M:%S'`
        echo $date"::[ERROR]:HDFS get from $Src_HDFS to $Tgt_Feed: Failed."
        exit 1
    fi
fi

if [ $v_mode == "gm" ];
then
   hadoop fs -getmerge $Src_HDFS $Tgt_Feed

   if [ $? -eq 0 ]
    then
        date=`date '+%Y/%m/%d %H:%M:%S'`
        echo $date"::[INFO]:HDFS get from $Src_HDFS to $Tgt_Feed: Success."
        exit 0
    else
        date=`date '+%Y/%m/%d %H:%M:%S'`
        echo $date"::[ERROR]:HDFS get from $Src_HDFS to $Tgt_Feed: Failed."
        exit 1
    fi
fi

if [ $v_mode == "gh" ];
then
   header=$(hadoop fs -cat $Src_HDFS* | head -1)
   
   rec_count=$(hadoop fs -cat $Src_HDFS* | wc -l)
   header_count=$(hadoop fs -cat $Src_HDFS* | grep $header | wc -l)

   date=`date '+%Y/%m/%d %H:%M:%S'`
   echo $date"::[INFO]:record Count : "$rec_count
   echo $date"::[INFO]:header Count : "$header_count

   if [ $rec_count -eq $header_count ]
   then
        echo -e $header > $Tgt_Feed 2>/dev/null
        if [ $? -eq 0 ]
            then
                date=`date '+%Y/%m/%d %H:%M:%S'`
                echo $date"::[INFO]:HDFS get from $Src_HDFS to $Tgt_Feed: Success."
                exit 0
            else
                date=`date '+%Y/%m/%d %H:%M:%S'`
                echo $date"::[ERROR]:HDFS get from $Src_HDFS to $Tgt_Feed: Failed."
                exit 1
            fi

   else
        echo -e $header > $Tgt_Feed | hadoop fs -cat $Src_HDFS* | grep -v ^$header >> $Tgt_Feed 2>/dev/null

        if [ $? -eq 0 ]
            then
                date=`date '+%Y/%m/%d %H:%M:%S'`
                echo $date"::[INFO]:HDFS get from $Src_HDFS to $Tgt_Feed: Success."
                exit 0
            else
                date=`date '+%Y/%m/%d %H:%M:%S'`
                echo $date"::[ERROR]:HDFS get from $Src_HDFS to $Tgt_Feed: Failed."
                exit 1
            fi
    fi
fi


if [ $v_mode == "gw" ];
then
   header=$(hadoop fs -cat $Src_HDFS* | head -1)
   hadoop fs -cat $Src_HDFS* | grep -v ^$header > $Tgt_Feed 2>/dev/null

   if [ $? -eq 0 ]
    then
        date=`date '+%Y/%m/%d %H:%M:%S'`
        echo $date"::[INFO]:HDFS get from $Src_HDFS to $Tgt_Feed: Success."
        exit 0
    else
        date=`date '+%Y/%m/%d %H:%M:%S'`
        echo $date"::[ERROR]:HDFS get from $Src_HDFS to $Tgt_Feed: Failed."
        exit 1
    fi
fi
