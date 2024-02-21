#!/bin/bash

create_table(){

    while true; 
    do
        read -p "Enter Table name: " table_name

        if [[ -z "$table_name" ]]; 
        then
            echo "Table name cannot be empty, please enter a valid name."
            continue
        fi

        table_name=$(echo "$table_name" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') #Trim the begin and end spaces

        #check spaces within the name
        if [[ "$table_name" =~ [[:space:]] ]]; 
        then
            echo "Table name cannot contain spaces, please enter a valid name."
            continue
        fi

        #entire name is not a number
        if [[ "$table_name" =~ ^[0-9]+$ ]]; 
        then
            echo "Table name cannot consist only of numbers, please enter a valid name."
            continue
        fi

        if [[ -f "$table_name.csv" ]]; 
        then
            echo "Table '$table_name' already exists, please choose a different name."
            continue
        fi

        break
    done
    
    touch $table_name.csv

     while true; do
        read -p "Enter number of columns: " num_columns

        if [[ -z "$num_columns" ]]; 
        then
            echo "number of columns cannot be empty, please enter a valid number."
            continue
        fi

        num_columns=$(echo "$num_columns" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        if ! [[ "$num_columns" =~ ^[0-9]+$ ]]; 
        then
            echo "invalid input, please enter a valid number."
            continue
        fi

        break
    done
 
    echo "Creating table with name: $table_name and $num_columns columns"
    

    declare -a column_names
    declare -a data_types
    declare primary_key

    for((i = 0; i < $num_columns; i++));
    do
        while true; 
        do
            read -p "Enter name of column number $(($i+1)): " column_name

            column_name="${column_name,,}"  # Convert to lowercase

            if [[ -z "$column_name" ]]; 
            then
                echo "Column name cannot be empty, please enter a valid name."
                continue
            fi

            column_name=$(echo "$column_name" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') 

            if [[ "$column_name" =~ [[:space:]] ]]; 
            then
                echo "column name cannot contain spaces, please enter a valid name."
                continue
            fi

            if [[ "$column_name" =~ ^[0-9]+$ ]]; 
            then
                echo "column name cannot consist only of numbers, please enter a valid name."
                continue
            fi

           for existing_column in "${column_names[@]}"; 
           do
                if [[ "$existing_column" == "$column_name" ]]; then
                    echo "Column name '$column_name' already exists, please choose a different name."
                    continue 2  # Skip to outer loop (break out completely)
                fi
            done
            break
        done

        column_names[$i]=$column_name
        
        while true;
        do  
            echo "-------------------------------"
            echo "Choose your column data type: "
            echo "-------------------------------"
            select option in "String" "Number";
            do
                case $REPLY in
                    1)
                        data_types[$i]="string"
                        break
                    ;;
                    2) 
                        data_types[$i]="number"
                        break
                    ;;
                    *)
                        echo "invalid data type, please enter nubmer 1 or 2."
                    ;;
                esac
            done
            break
        done
    done

    declare -a cols_options
    for ((i = 0; i < $num_columns; i++)); 
    do
        cols_options[$i]=${column_names[$i]}
    done


    while true; 
    do
        echo "----------------------------------"
        echo "Select the primary key column (or 'N' for none):"
        echo "----------------------------------"

        select primary_key_index in "${cols_options[@]}" "N"; 
        do
            case $primary_key_index in
                "N") primary_key=""; 
                break 
                ;;
                *) 
                    if [[ ! " ${column_names[@]} " =~ " $primary_key_index " ]]; then
                        echo "Invalid choice. Please enter a number from 1 to $num_columns or 'N'."
                        continue
                    else
                        primary_key=$primary_key_index
                    fi
                break 
                ;;
                esac
        done
        break
    done

    declare -a nulls_cols

    while true; do
        echo "----------------------------------"
        echo "Available columns:"
        for ((i=0; i<${#column_names[@]}; i++)); 
        do
            if ! [[ "${column_names[$i]}" == "$primary_key" ]]; then
                echo "$(($i+1)). ${column_names[$i]}"
            fi
        done
        echo "----------------------------------"
        echo "Select the columns that accept null as default value, separate between columns by space (or 'N' for none):"
        echo "----------------------------------"

        read -r -p "Enter column numbers separated by spaces (or 'N' for none): " selected_indices
        
        if [[ $selected_indices == "N" ]]; then
            break
        fi
        
        IFS=' ' read -r -a selected_indices_array <<< "$selected_indices"
        
        for index in "${selected_indices_array[@]}"; 
        do
            if ! [[ "$index" =~ ^[0-9]+$ ]] || ((index < 1 || index > ${#column_names[@]})); then
                #check for that the index not equal to the index of the primary key.
                echo "Invalid column number: $index"
                continue
            fi
            nulls_cols+=("${column_names[$((index-1))]}")
        done
        break
    done

    for ((i=0; i<$num_columns; i++)); 
    do
        if [ "${column_names[$i]}" == "$primary_key" ]; then
            echo "$table_name:${column_names[$i]}:${data_types[$i]}:1:0" >> metadata
        else
            if [[ " ${nulls_cols[@]} " =~ " ${column_names[$i]} " ]]; then
                echo "$table_name:${column_names[$i]}:${data_types[$i]}:0:1" >> metadata
            else
                echo "$table_name:${column_names[$i]}:${data_types[$i]}:0:0" >> metadata
            fi
        fi
    done

    
    
    for col_name in "${column_names[@]}"; do
        echo -n "$col_name," >> "$table_name.csv"
    done
    
    echo " " >> "${table_name}.csv"

    sed -i 's/,$//' "$table_name.csv"

    echo "cols: "${column_names[@]}
    echo "data types: "${data_types[@]}
    echo "PK: "$primary_key
    echo "nulls: "${nulls_cols[@]}

}


drop_table() {
    
    table_names=($(awk -F: '{print $1}' metadata | sort -u))

    declare table_name_drop

    while true; 
    do
        echo "----------------------------------"
        echo "Select the table name to drop (or 'N' for none):"
        echo "----------------------------------"

        select table in "${table_names[@]}" "N"; 
        do
            case $table in
                "N") 
                return
                ;;
                *) 
                    if [[ ! " ${table_names[@]} " =~ " $table " ]]; then
                        echo "Invalid choice. Please enter a number from 1 to ${#column_names[@]} or 'N'."
                        continue
                    else
                        table_name_drop=$table
                    fi
                break 
                ;;
                esac
        done
        break
    done


    if [ -f "$table_name_drop.csv" ]; then
        rm "$table_name_drop.csv"
        echo "Table file '$table_name_drop.csv' removed."
    else
        echo "Table file '$table_name_drop.csv' does not exist."
    fi

    awk -v table="$table_name_drop" -F: '$1 != table' metadata > metadata_temp
    mv metadata_temp metadata

}



display_menu() {

    while true; do
        echo "-----------------------"
        echo "Table DDL Menu: "
        echo "-----------------------"
        select option in "Create Table" "List Tables" "Show Database Metadata" "Drop Table" "DML Menu" "DB DDL Menu" "Disconnect from DB" "Exit"; 
        do
            if [[ -z "$REPLY" ]]; then
                echo "You entered an empty choice, please enter an input."
                continue
            fi

            case $REPLY in
                1)
                    echo "*********************"
                    echo "Create Table"
                    echo "*********************"
                    create_table
                    break
                ;;
                2)
                    echo "*********************"
                    echo "List Tables"
                    echo "*********************"
                    ls -p | grep -E '*\.csv$' | awk '{gsub(/\.csv$/, "", $0); print $0}'
                    break
                ;;
                3)
                    echo "*********************"
                    echo "Show Database Metadata"
                    echo "*********************"
                    cat metadata
                    break
                ;;
                4)
                    echo "*********************"
                    echo "Drop Table"
                    echo "*********************"
                    drop_table
                    break
                ;;
                5)
                    echo "--------------------------------------------------"
                    echo "Go to DML Table"
                    source ../../table_DML.sh
                ;;
                6)
                    echo "--------------------------------------------------"
                    echo "***************Database DDL Menu******************"
                    echo "--------------------------------------------------"
                    cd ..
                    ls .
                    source ../DB_DDL.sh
                ;;
                7)
                    echo "Disconnect done successfully...."
                    cd ..
                    pwd
                    source ../DB_DDL.sh
                    break 2
                ;;
                8)
                    echo "Exiting....";
                    exit 0
                ;;
                *)
                    echo "Incorrect choice, please enter a number between 1 and 6"
                    continue 2
                ;;
            esac
        done
    done
}

display_menu