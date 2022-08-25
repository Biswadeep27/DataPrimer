#!/bin/bash
###########################################################################
#Global Name: archive_files_hdp_global.sh                                 #
#Description: Global Script to archive files and Purge old files on hdfs  #
#Usage      :sh archive_files_hdp_global.sh -f <fullfilepath> -n 
#	     <NoOfDaysPurging>  -d <domain Dir> -p <project dir> -j <JobName>            
#Author     :Biswadeep Upadhyay                                           #
###########################################################################

date=`date '+%Y/%m/%d %H:%M:%S'`
v_arg_cnt=$#

###########################################################################
# Input Arguements                                                        #
###########################################################################

while getopts ":d:p:f:j:n:" opt
   do
     case $opt in
        d ) v_proj_dom=$OPTARG;;
	    p ) v_proj_nam=$OPTARG;;
        f ) v_file_path=$OPTARG;;
        j ) v_job_name=$OPTARG;;
        n ) v_no_of_days=$OPTARG;;
        \? ) exit 1 ;; 
     esac
   done

###########################################################################
# Variables			                                          #
###########################################################################

date=`date '+%Y%m%d'`
ts=`date '+%H%M%S'`
v_log_dir="/hadoopData/$v_proj_dom/$v_proj_nam/logs/"
v_archive_dir="/hdfsArchive/$v_proj_dom/$v_proj_nam/$date"

v_src_dir="${v_file_path%/*}"
#filename=$(basename "$fullfilename")
v_file_dir="${v_file_path##*/}"
v_arc_name=$v_file_dir"_"$ts".har"

###########################################################################
# Log File		                                                  #
###########################################################################
date=`date '+%Y/%m/%d %H:%M:%S'`
if [ -d "$v_log_dir" ]; then
    echo "$date::[INFO]:project folder /hdfsData/$v_proj_dom/$v_proj_nam/ validated.";
else
    echo "$date::[ERROR]:project folder /hdfsData/$v_proj_dom/$v_proj_nam/ not found.";
    exit 1;
fi
date=`date '+%Y%m%d_%H%M%S'`
Log_File=$v_log_dir$v_job_name'_GLOBAL_HDP_ARCHIVE_FILES_'$v_file_dir'_'$date'.log'
rm $Log_File 2>/dev/null 

###########################################################################
# Parameter Validation                                                    #
###########################################################################
date=`date '+%Y/%m/%d %H:%M:%S'`
if [[ $# != 10 ]]
then
echo $date"::[ERROR]:Invalid number of Parameters . required 5.Usage:sh archive_files_hdp_global.sh -d <project_domain> -p <project_name> -f <file_dir>
-j <job_name> -n <purging_interval> " >> $Log_File
exit 1
else
echo $date"::[INFO]:Parameter Validation completed successfully." >> $Log_File
fi

###########################################################################
# User Validation                                                         #
###########################################################################
date=`date '+%Y/%m/%d %H:%M:%S'`
echo $v_log_dir
echo $v_archive_dir
echo $v_src_dir
echo $v_file_dir
echo $v_arc_name
echo $Log_File

if [ `whoami` != "airflow"  ];
then
{
echo $date"::[ERROR]:Please check the executing user . This script runs with airflow user ." >> $Log_File
echo "The script only runs with airflow user. Exiting with error code 1."
exit 1
}
fi

###########################################################################
# hdfs file path validation                                               #
###########################################################################
date=`date '+%Y/%m/%d %H:%M:%S'`
if $(hadoop fs -test -d $v_file_path) ;
then
    echo "$date::[INFO]:the file path $v_file_path found for archival." >>  $Log_File
else
    echo "$date::[ERROR]:the file path $v_file_path not found for archival.Failed with exit code 1." >> $Log_File
    exit 1
fi

echo "$date::[INFO]:the archival folder [$v_archive_dir/$v_arc_name] is set for operation." >> $Log_File

###########################################################################
# hdfs archival process                                                   #
###########################################################################
date=`date '+%Y/%m/%d %H:%M:%S'`
echo $date"::[INFO]:Starting the Archival Process." >> $Log_File

hadoop archive -archiveName $v_arc_name -p $v_src_dir $v_file_dir $v_archive_dir >> $Log_File 2>&1
if [ $? -eq 0 ];
then
{
date=`date '+%Y/%m/%d %H:%M:%S'`
echo $date"::[INFO]:the files in $v_file_path successfully archived in $v_archive_dir/$v_arc_name."   >> $Log_File
}
else
{
date=`date '+%Y/%m/%d %H:%M:%S'`
echo $date"::[ERROR]:Unable to archive the files in : $v_file_path. Failed with exit code 1." >> $Log_File
exit 1
}
fi

#hadoop fs -rm -r $v_file_path/* >> $Log_File 2>&1



###########################################################################
# Purging the old files from archive                                      #
###########################################################################
date=`date '+%Y/%m/%d %H:%M:%S'`
echo $date"::[INFO]:Purging the files in all the "$v_file_dir"* directories older than "$v_no_of_days" days."  >> $Log_File
v_regexp=$v_file_dir"*"
v_today=`date +'%s'`
v_purge_folder="/hdfsArchive/$v_proj_dom/$v_proj_nam/"
hadoop fs -ls -R -h $v_purge_folder | grep "^d" | grep $v_regexp | while read line ; 
do
    v_dir_date=$(echo ${line} | awk '{print $6}')
    v_difference=$(( ( ${v_today} - $(date -d ${v_dir_date} +%s) ) / ( 24*60*60 ) ))
    v_purge_path=$(echo ${line} | awk '{print $8}')
    if [ ${v_difference} -gt $v_no_of_days ]; then
        echo "purge path for validation: $v_purge_path"
        hadoop fs -rm -r $v_purge_path >> $Log_File 2>&1
        if [ $? -eq 0 ];
                then
                {
                date=`date '+%Y/%m/%d %H:%M:%S'`
                echo $date"::[INFO]:the files in $v_purge_path has been successfully purged."   >> $Log_File
                }
                else
                {
                date=`date '+%Y/%m/%d %H:%M:%S'`
                echo $date"::[ERROR]:Unable to purge the file : $v_purge_path. purging ignored." >> $Log_File
                }
        fi
    fi    

done | grep ^ || echo "$date::[ERROR]:No file [ $v_file_dir ] found older than $v_no_of_days days. Purging ignored." >> $Log_File


  

###########################################################################
# Empty Date folder cleanup
###########################################################################
date=`date '+%Y/%m/%d %H:%M:%S'`

hadoop fs -ls $v_purge_folder | grep "^d" | while read line;
do
    v_date_dir=$(echo ${line} | awk '{print $8}')
    echo "checking folder cleanup on : $v_date_dir"
    if $(hadoop fs -test -d $v_date_dir) ;
    then
        v_empty=$(hadoop fs -count $v_date_dir | awk '{print $2}')

        if [[ $v_empty -eq 0 ]];then
                hadoop fs -rm -r $v_date_dir >> $Log_File 2>&1
                echo "$date::[INFO]:the empty directory $v_date_dir was cleaned from hdfs." >> $Log_File
        fi
    fi
done
exit 0