#!/bin/bash

### config
# target directory
datadir="/var/lib/munin"
htmldir="/var/www/html/munin"
cgitmpdir="$datadir/cgi-tmp"

### define
cgigraphdir="$cgitmpdir/munin-cgi-graph"
action=(
"rename"
"delete"
"exit"
)
# select menu prompt
PS3="Enter menu number> "
# function
check_munin_process() {
    pcount=`ps aux | grep --color=none -E 'munin-updat[e]|munin-htm[l]' | wc -l`
    return $pcount
}
# simple check (Ubuntu or not)
ubuntu=
if [ -f "/etc/lsb-release" ];then
    ubuntu=true
fi

### execute
if [  ! -d "$datadir" -o ! -d "$htmldir" -o ! -d "$cgitmpdir" ];then
    echo "Please check your setting 'datadir', 'htmldir' and 'cgitmpdir'."
    exit
fi

while : ;do
    echo "Please select the action"
    select act in ${action[@]};do
        case $act in
            "rename")
                while : ;do
                    while : ;do
                        read -e -p "Please enter OLD GROUP name > " old_g
                        if [ "$old_g" = "" ];then
                            continue
                        fi
                        break
                    done
                    while : ;do
                        read -e -p "Please enter OLD NODE name > " old_n
                        if [ "$old_n" = "" ];then
                            continue
                        fi
                        break
                    done
                    while : ;do
                        read -e -p "Please enter NEW GROUP name [$old_g] > " new_g
                        if [ "$new_g" = "" ];then
                            new_g="$old_g"
                        fi
                        break
                    done
                    while : ;do
                        read -e -p "Please enter NEW NODE name [$old_n] > " new_n
                        if [ "$new_n" = "" ];then
                            new_n="$old_n"
                        fi
                        break
                    done
                    # display input data
                    echo
                    echo -e "OLD Group: \e[36m$old_g\e[m"
                    echo -e "OLD Node : \e[36m$old_n\e[m"
                    echo -e "New Group: \e[36m$new_g\e[m"
                    echo -e "New Node : \e[36m$new_n\e[m"
                    echo
                    # confirm
                    while : ;do
                        read -e -p "OK? [y/n]: " answer
                        case $answer in
                            [Nn]|[Nn][Oo]) break ;;
                            [Yy]|[Yy][Ee][Ss]) break 2 ;;
                        esac
                    done
                done

                # check update process
                echo "Waiting for the munin-update and munin-html processes to finish."
                while : ;do
                    check_munin_process
                    if [ $? -gt 0 ];then
                        echo -n '.'
                        sleep 3
                    else
                        echo
                        break
                    fi
                done

                # state files
                echo "move state files:"
                echo -e "\t$datadir/state-$old_g-$old_n.storable >>> $datadir/state-$new_g-$new_n.storable"
                mv -f $datadir/state-$old_g-$old_n.storable $datadir/state-$new_g-$new_n.storable
                # directory exists?
                echo "rename data files:"
                if [ -d "$datadir/$old_g" ];then
                    mkdir $datadir/$new_g > /dev/null 2>&1
                    # data files
                    echo -e "\trename $old_g/$old_n $new_g/$new_n $datadir/$old_g/$old_n-*"
                    if [ $ubuntu ];then
                        rename "s,$old_g/$old_n,$new_g/$new_n," $datadir/$old_g/$old_n-*
                    else
                        rename $old_g/$old_n $new_g/$new_n $datadir/$old_g/$old_n-*
                    fi
                else
                    echo -e "\t$datadir/$old_g: \e[31mNo such file or directory\e[m"
                fi
                # directory exists?
                echo "move html files:"
                if [ -d "$htmldir/$old_g/$old_n" ];then
                    mkdir $htmldir/$new_g > /dev/null 2>&1
                    # html files
                    echo -e "\t$htmldir/$old_g/$old_n/ >>> $htmldir/$new_g/$new_n/"
                    mv -f $htmldir/$old_g/$old_n $htmldir/$new_g/$new_n
                else
                    echo -e "\t$htmldir/$old_g/$old_n: \e[31mNo such file or directory\e[m"
                fi
                # delete old cgigraph directory
                echo "delete graph directory:"
                echo -e "\t$cgigraphdir/$old_g/$old_n/"
                rm -rf $cgigraphdir/$old_g/$old_n/
                echo

                # old data group directory is empty?
                count=`ls $datadir/$old_g 2> /dev/null | wc -l`
                if [ $count -eq 0 ];then
                    echo "delete the empty directory '$datadir/$old_g'"
                    rm -rf $datadir/$old_g
                fi
                # old html directory is empty?
                count=`find $htmldir/$old_g -maxdepth 1 -type d 2> /dev/null | wc -l`
                if [ $count -le 1 ];then
                    echo "delete the empty directory '$htmldir/$old_g'"
                    rm -rf $htmldir/$old_g
                fi
                # old cgi-graph group directory is empty?
                count=`ls $cgigraphdir/$old_g 2> /dev/null | wc -l`
                if [ $count -eq 0 ];then
                    echo "delete the empty directory '$cgigraphdir/$old_g'"
                    rm -rf $cgigraphdir/$old_g
                fi
                echo
                break
                ;;
            "delete")
                while : ;do
                    while : ;do
                        read -e -p "Please enter DELETE GROUP name > " delete_g
                        if [ "$delete_g" = "" ];then
                            continue
                        fi
                        break
                    done
                    while : ;do
                        read -e -p "Please enter DELETE NODE name > " delete_n
                        if [ "$delete_n" = "" ];then
                            continue
                        fi
                        break
                    done
                    # display input data
                    echo
                    echo -e "DELETE Group: \e[36m$delete_g\e[m"
                    echo -e "DELETE Node : \e[36m$delete_n\e[m"
                    echo
                    # confirm
                    while : ;do
                        read -e -p "OK? [y/n]: " answer
                        case $answer in
                            [Nn]|[Nn][Oo]) break ;;
                            [Yy]|[Yy][Ee][Ss]) break 2 ;;
                        esac
                    done
                done

                # check update process
                echo "Waiting for the munin-update and munin-html processes to finish."
                while : ;do
                    check_munin_process
                    if [ $? -gt 0 ];then
                        echo -n '.'
                        sleep 3
                    else
                        echo
                        break
                    fi
                done

                # state files
                echo "delete state files:"
                echo -e "\t$datadir/state-$delete_g-$delete_n.storable"
                rm -f $datadir/state-$delete_g-$delete_n.storable
                # data files
                echo "delete data files:"
                echo -e "\t$datadir/$delete_g/$delete_n-*"
                rm -f $datadir/$delete_g/$delete_n-*
                # html files
                echo "delete html files:"
                echo -e "\t$htmldir/$delete_g/$delete_n/"
                rm -rf $htmldir/$delete_g/$delete_n
                # cgigraph files
                echo "delete graph directory:"
                echo -e "\t$cgigraphdir/$delete_g/$delete_n/"
                rm -rf $cgigraphdir/$delete_g/$delete_n
                echo

                # group directory is empty?
                count=`ls $datadir/$delete_g 2> /dev/null | wc -l`
                if [ $count -eq 0 ];then
                    rm -rf $datadir/$delete_g
                    if [ $? -eq 0 ];then
                        echo "delete the empty directory '$datadir/$delete_g'"
                    fi
                fi
                # html directory is empty?
                count=`find $htmldir/$delete_g -maxdepth 1 -type d 2> /dev/null | wc -l`
                if [ $count -le 1 ];then
                    rm -rf $htmldir/$delete_g
                    if [ $? -eq 0 ];then
                        echo "delete the empty directory '$htmldir/$delete_g'"
                    fi
                fi
                # cgi-graph group directory is empty?
                count=`ls $cgigraphdir/$delete_g 2> /dev/null | wc -l`
                if [ $count -eq 0 ];then
                    echo "delete the empty directory '$cgigraphdir/$delete_g'"
                    rm -rf $cgigraphdir/$delete_g
                fi
                echo
                break
                ;;
            "exit")
                echo "bye"
                exit
                ;;
        esac
    done
done
