#!/bin/sh
if [ "$1" = "-i" ] && [ "$2" = "-D" ] && [ "$4" = "-V" ] && [ "$6" = "-R" ] && [ "$8" = "-H" ];
then
echo "###########started Initialization mode##############"
if [ "$9" = "md5" ] || [ "$9" = "md" ] || [ "$9" = "sha1" ] || [ "$9" = "sha" ];
then
echo "your hash function is $9"
else
echo "wrong hash function selection"
echo "terminating program :-("
exit
fi
if [ ! -d "$3" ]; then
  echo "monitered directory dose not exists"
  echo "terminating program :-("
  exit
fi
if [ -f "$5" ]; 
then
echo "do you want to rewrite verification file(yes/no)"
read var
if [ "$var" = "yes" ];
then
rm $5
fi
if [ "$var" = "no" ];
then
echo "terminating program :-("
exit
fi
fi
if [ -f "$7" ]; 
then
echo "do you want to rewrite report file(yes/no)"
read var
if [ "$var" = "yes" ];
then
rm $7
fi
if [ "$var" = "no" ];
then
echo "terminating program :-("
exit
fi
fi
start=`date +%s`
echo "siv start time:$start"
find "$3" -type f > checkf 
find "$3" -type d > checkd
filename="checkf"
filename1="checkd"
dcount=`wc -l checkd | awk '{ print $1 }'`
fcount=`wc -l checkf | awk '{ print $1 }'`
while read -r line
do
           filesize=$(stat --format=%s "$line")
           fileuser=$(stat --format=%U "$line")
           filegroup=$(stat --format=%G "$line")
           fileaccess=$(stat --format=%a "$line")
           filemodify=$(stat --format=%y "$line")
           filemodify1=$(stat --format=%n "$line")
           md5=`md5sum ${line} | awk '{ print $1 }'`
           sha1=`sha1sum ${line} | awk '{ print $1 }'`
           if [ "$9" = "md5" ] || [ "$9" = "md" ];
             then
              echo $line,$filesize,$fileuser,$filegroup,$fileaccess,$filemodify,$md5 >> $5
           fi 
           if [ "$9" = "sha1" ] || [ "$9" = "sha" ];
             then
              echo $line,$filesize,$fileuser,$filegroup,$fileaccess,$filemodify,$sha1 >> $5
           fi
done < "$filename"
end=`date +%s`
exe=$((end-start))
echo "monitered directory :$3"
echo "verification file path : $5"
echo "report file path : $7"
echo "hash function : $9"
echo "siv end time : $end"
echo "execution time: $exe"
echo "no of files prased: $fcount"
echo "no of directories prased: $dcount"
echo "initilisation mode compleated :-)"
echo $3,$5,$9,$fcount,$dcount,$end,$start,$exe  >> $7

elif [ "$1" = "-v" ] && [ "$2" = "-D" ] && [ "$4" = "-V" ] && [ "$6" = "-R" ];
then
echo "#############verification mode##############"
if [ ! -d "$3" ]; then
  echo "monitered directory dose not exists"
  echo "terminating program :-("
  exit
fi
if [ -f "$7" ]; 
then
echo "do you want to rewrite report file(yes/no)"
read var
if [ "$var" = "yes" ];
then
rm $7
fi
if [ "$var" = "no" ];
then
echo "terminating program :-("
exit
fi
if [ ! -f "$5" ];
then
echo "verification file dose not exist"
echo "terminating program :-("
exit
fi
if [ -f "$5" ];
then
checkof="checkof"
if [ -f "$checkof" ];
then
rm $checkof
fi 
while read -r lines
do
 user=`echo $lines| awk -F"," '{print $1}'`
 echo $user >> checkof
done < "$5"
start=`date +%s`
find "$3" -type f > checkvf 
find "$3" -type d > checkvd
grep -Fxvf checkof checkvf > newfile
grep -Fxvf checkvf checkof > delfile
grep -Fxvf checkd checkvd > newdir
grep -Fxvf checkvd checkd > deldir
nf=`wc -l newfile | awk '{ print $1 }'`
df=`wc -l delfile | awk '{ print $1 }'`
nd=`wc -l newdir | awk '{ print $1 }'`
dd=`wc -l deldir | awk '{ print $1 }'`
dcount=`wc -l checkvd | awk '{ print $1 }'`
fcount=`wc -l checkvf | awk '{ print $1 }'`
newfile="newfile"
delfile="delfile"
newdir="newdir"
deldir="deldir"
echo "number of new files detected $nf"
if [ $nf != "0" ];
then
echo "new files are:"
while read -r lines
do
echo "$lines"
done < "$newfile"
fi
echo "number of deleated files detected $df"
if [ $df != "0" ];
then
echo "deleated files are:"
while read -r lines
do
echo "$lines"
done < "$delfile"
fi
echo "number of new directories added $nd"
if [ $nd != "0" ];
then
echo "new directories are:"
while read -r lines
do
echo "$lines"
done < "$newdir"
fi
echo "number of deleated directories $dd"
if [ $dd != "0" ];
then
echo "deleated directories are:"
while read -r lines
do
echo "$lines"
done < "$deldir"
fi
filename="checkvf"
filename1="checkvd"
file=$5
change=0
echo $dcount,$fcount
while read -r lines
do
           filesize=$(stat --format=%s "$lines")
           fileuser=$(stat --format=%U "$lines")
           filegroup=$(stat --format=%G "$lines")
           fileaccess=$(stat --format=%a "$lines")
           filemodify=$(stat --format=%y "$lines")
           filemodify1=$(stat --format=%n "$lines")
           md5=`md5sum ${lines} | awk '{ print $1 }'`
           sha1=`sha1sum ${lines} | awk '{ print $1 }'`
while IFS= read line
do
        user=`echo $line| awk -F"," '{print $1}'`
        pass=`echo $line | awk -F"," '{print $2}'`
        pass1=`echo $line | awk -F"," '{print $7}'`
        pass2=`echo $line | awk -F"," '{print $3}'`
        pass3=`echo $line | awk -F"," '{print $4}'`
        pass4=`echo $line | awk -F"," '{print $5}'`
        pass5=`echo $line | awk -F"," '{print $6}'`
        if [ "$user" = "$lines" ];
        then
        #echo $user
        #echo $pass
        if [ "$pass" != "$filesize" ];
        then
         echo "$user,file size detected "
         change=$(($change + 1))
        fi
        if [ "$pass2" != "$fileuser" ];
        then
         echo "$user,user change detected "
         change=$(($change + 1))
        fi
        if [ "$pass3" != "$filegroup" ];
        then
         echo "$user,group change detected "
         change=$(($change + 1))
        fi
        if [ "$pass4" != "$fileaccess" ];
        then
         echo "$user,file access change detected "
         change=$(($change + 1))
        fi
        if [ "$pass5" != "$filemodify" ];
        then
         echo "$user,modified time change detected "
         change=$(($change + 1))
        fi
        if [ "$pass1" = "$md5" ] || [ "$pass1" = "$sha1" ] ;
        then
         echo "$user ,no change"
        else
         echo "$user, change"
         change=$(($change + 1))
        fi
        fi
done <"$file"
done < "$filename"
if [ $change = '0' ];
then
echo "no change in directory detected"
else
echo "${change}'s warnings issued" 
fi
end=`date +%s`
runtime=$((end-start))
echo "monitered directory :$3"
echo "verification file path : $5"
echo "report file path : $7"
echo "siv start time : $start"
echo "siv end time : $end"
echo "execution time: $runtime"
echo "no of files prased: $fcount"
echo "no of directories prased: $dcount"
echo "verification mode compleated :-)"
echo $3,$5,$fcount,$dcount,$nf,$df,$nd,$dd,$end,$change,$start,$runtime  >> $7
fi
fi
elif [ "$1" = "-h" ];
then
        echo "********** help mode ***********"
        echo "siv <-i|-v|-h> –D	<monitored_directory> -V <verification_file> -R	<report_file> -H <hash_function>"
        echo "#######Initialization mode#######"
        echo "siv -i –D	<monitored_directory> -V <verification_file> -R	<report_file> -H <hash_function>"
        echo "   -i Initialization mode"
        echo "   -D directory to be monitered"
        echo "   -V verification file"
        echo "   -R report file"
        echo "   -H hash function"
        echo "######verification mode#######"
        echo "siv -v –D	<monitored_directory> -V <verification_file> -R	<report_file>"
        echo "   -v verification mode"
        echo "   -D directory to be monitered"
        echo "   -V verification file"
        echo "   -R report file"
else 
echo "invalid command :-("
echo "use the command siv -h for more info :-) "
exit
fi
