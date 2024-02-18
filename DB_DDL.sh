#!/bin/bash

shopt -s extglob
export LC_COLLATE=C

declare dir
dir=databases
current_dir=$(basename "$(pwd)")

if [ "$current_dir" != "$dir" ] && ! [ -d "$dir" ]; then
    mkdir "$dir"
fi

if [ "$current_dir" != "$dir" ]; then
    cd "$dir"
fi 
pwd

while true; do
    echo "--------------------------------------------------"
    echo "***************Database DDL Menu******************"
    echo "--------------------------------------------------"
    select option in "Create DataBase" "List DataBases" "Connect to DataBase" "Drop DataBase" "Exit"; do
        case $REPLY in
            1)
                # want to create a database
                echo "======================================================="
                echo "Available databases: "
                ls .
                echo "======================================================="
                read -p "What's its name: " database_name
                # checks if it exists already
                if [ -d "$database_name" ]; then
                    echo "Such database already exists."
                else
                    mkdir "$database_name"
                    echo "Database created successfully: "
                fi
                break
                ;;
             2)
                # listing databases
                echo "======================================================="
                echo "Available databases: "
                ls .
                echo "======================================================="
                break
                ;;
             3)
                # get into a database
                echo "Available Database:"
                ls .
                read -p "which database to connect :" database_to_connect
                if [ -d "$database_to_connect" ]; then
                    cd "$database_to_connect" 
                    pwd
                    source ../../table_DDL.sh
                else
                    echo "no such database exist $database_to_connect"
                fi
                break
                ;;
             4)
                #drop database
                echo "Available Database:"
                ls .
                read -p "which database to delete :" database_to_delete
                if [ -d "$database_to_delete" ]; then
                    read -p "are you want to delete the database $database_to_delete ? Enter y or n " option
                    case $option in
                        [Yy])
                            rm -r "$database_to_delete"
                            echo "$database_to_delete database deleted successfully"
                            break
                            ;;
                        [Nn])
                            echo "Didn't delete Database "
                            break
                            ;;
                        *)
                            echo "invalid choice"
                            break
                            ;;
                    esac
                else
                    echo "No such database exist"
                fi
                break
                ;;
             5)
                #Exit
                exit 0
                ;;
             *)
                echo "invalid input"
                break
                ;;
        esac
    done
done
