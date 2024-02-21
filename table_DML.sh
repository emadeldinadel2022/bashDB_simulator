#!/bin/bash

select_statement(){
    echo "Available Database"
    ls .
    echo "=========================================="

    while true ; 
    do 
	    select choice in "Select All" "Select Sepcific Columns" "Select With Where Condition" "Back"; do 
		    case $REPLY in
		        1) 
                    echo "Available Tables"
			        ls -p | grep -E '*\.csv$' | awk '{gsub(/\.csv$/, "", $0); print $0}'
			        echo "=========================================="
			        
                    read -p "which table to connect : " table_to_select
		        	
                    if [ -f $table_to_select.csv ]; then
                        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
				        echo "$(awk -F "," 'NR==1 {print}; NR>1 {print}' "$table_to_select.csv")"
                        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                    else
				        echo "such table doesn't exist"
			        fi
			        break 
			    ;;
		      2) 
                echo "Available Tables"
                ls -p | grep -E '*\.csv$' | awk '{gsub(/\.csv$/, "", $0); print $0}'
			    echo "=========================================="
			    
                read -p "which table to connect : " table_to_select
			    
                if [ -f $table_to_select.csv ]; then
			        
                    echo "$(awk -F "," 'NR==1 {print}; NR>1 {print}' "$table_to_select.csv")"
                    typeset -i number_of_fields=$(awk -F "," 'NR==1 {print NF}' "$table_to_select.csv")    
                    read -p "Enter number of columns to view :" number_of_columns
			    
                    while [[ $number_of_columns != +([0-9]) || "$number_of_columns" -eq "0" || $number_of_columns -gt "$number_of_fields" ]]; 
                    do
                    	read -p "Enter a valid number of columns: " number_of_columns
		            done
			   
                    typeset -i element=0
			        
                    for ((i = 0; i < $number_of_columns; i++)); 
                    do
                        read -p "Enter column name: " column_name_selected
                        while [[ $column_name_selected != +([a-zA-Z0-9-()]) ]]; 
                        do
                            read -p "Enter a valid column name: " column_name_selected
                        done
                        
                        # get the number of field of that column
                        field_number=$(awk -F "," 'NR==1 {for(i = 1; i<NF; i++) if($i=="'$column_name_selected'") print i}' "$table_to_select.csv")
                        
                        # put them all in an array
                        if [ $field_number -gt 0 ]; then
                            arr[element]=$field_number
                            element=$element+1
		                else 
			                echo "this column doesn't exist "
		                fi
		            done
		    
                    string = ""
		            
                    for var in ${arr[@]}; 
                    do 
			            string=$string,$var
	                done;
		   
                    cut -d, -f "$(echo "${string:1}" | tr ',' ':')" "$table_to_select.csv"
	            else 
		           echo "Such Table doesn't exist"
			    fi
			    
                break
			    ;;
	          3)
			    #####################################################################################
                echo "======================================================="
                echo "Available tables: "
                ls -p | grep -E '*\.csv$' | awk '{gsub(/\.csv$/, "", $0); print $0}'
                echo "======================================================="
                
                read -p "Which table: " table_to_select
                if [ -f $table_to_select.csv ]; then
                    echo "Available columns: "
                    echo "$(awk -F "," 'NR==1 {print}' "$table_to_select.csv")"
                    
                    # get the column we want as condition
                    read -p "Which column do you want as a condition: " select_column_condition_ww
                    while [[ $select_column_condition_ww != +([a-zA-Z0-9-()]) ]]; 
                    do
                        read -p "Enter a valid column name as a condition: " select_column_condition_ww
                    done
                    
                    # get its number or if it even exists in that table
                    select_column_condition_ww_exist=$(awk -F"," 'NR==1 {for(i=1; i< NF; i++) if($i=="'$select_column_condition_ww'") print i}' "$table_to_select.csv")
                
                    while [ -z "$select_column_condition_ww_exist" ]; 
                    do
                        echo "This column doesn't exist."
                        read -p "Which column do you want as a condition: " select_column_condition_ww
                        while [[ $select_column_condition_ww != +([a-zA-Z0-9-()]) ]]; 
                        do
                            read -p "Enter a valid column name as a condition: " select_column_condition_ww
                        done
                    
                        select_column_condition_ww_exist=$(awk -F"," 'NR==1 {for(i=1; i< NF; i++) if($i=="'$select_column_condition_ww'") print i}' "$table_to_select.csv")
                    done
                
                    # get the update value
                    read -p "Enter the condition column value: " condition_update_value
                    rows_numbers=$(cut -d, -f"$select_column_condition_ww_exist" "$table_to_select.csv" | grep -n -w "$condition_update_value" | cut -d, -f1)
                
                    # print the head of the file
                    awk -F"," 'NR=="1" {print}' "$table_to_select.csv" | column -t -s","
                
                    for ((i = 0; i < ${#rows_numbers}; i ++)); 
                    do
                        # print all the rows
                        awk -F"," 'NR=="'${rows_numbers:$i:1}'" {print}' "$table_to_select.csv" | column -t -s","
                    done
                else
                    echo "Such table doesn't exist"
                fi
                #####################################################################################
                break
            ;;
            4)
	            return
	        ;;
            esac
        done 
    done

}

insert(){

    table_names=($(awk -F: '{print $1}' metadata | sort -u))

    declare table_name
    declare -a table_columns  

    while true;
    do
        echo "----------------------------------"
        echo "Select the table name to insert (or 'N' for none):"
        echo "----------------------------------"

        select table in "${table_names[@]}" "N"; 
        do
          case $table in
                "N") 
                    return 
                ;;
                *) 
                    if [[ ! " ${table_names[@]} " =~ " $table " ]]; then
                        echo "Invalid choice. Please enter a valid table name or 'N' to exit."
                        continue
                    else
                        table_name=$table

                        typeset -i index=0

                        while IFS=':' read -r t col_name data_type pk accept_null; do
                            if [[ "$t" == "$table_name" ]]; then
                                table_columns[$index]="$col_name:$data_type:$pk:$accept_null"
                                ((index++))
                            fi
                        done < metadata
                    fi
                break 
                ;;
                esac
        done
        break
    done

    echo "Columns for $table_name:"
    for key in "${!table_columns[@]}"; do
        echo "${table_columns[$key]}"
    done

    declare record

    while true; 
    do
        echo "----------------------------------------------------"
        echo "Select the option for applying the insert statement"
        echo "----------------------------------------------------"

        select option in "Insert Entire Record" "Return to DML Menu";
        do
            case $REPLY in
                1)
                    echo "Inserting Entire Record for $table_name"
                    
                    first_column=true
                    for key in "${!table_columns[@]}"; do
                        col_info="${table_columns[$key]}"
                        col_name=$(echo "$col_info" | awk -F':' '{print $1}')
                        data_type=$(echo "$col_info" | awk -F':' '{print $2}')
                        pk=$(echo "$col_info" | awk -F':' '{print $3}')
                        accept_null=$(echo "$col_info" | awk -F':' '{print $4}')

                        echo "col info: "$col_info
                        echo "col name: "$col_name
                        echo "dt: "$data_type
                        echo "pk: "$pk
                        echo "null: "$accept_null

                        while true; do
                            read -p "Enter value for $col_name ($data_type): " value

                                if [[ -z "$value" && "$accept_null" == "0" ]]; then
                                echo "Error: Column $col_name does not accept null values."
                                continue
                                elif [[ -z "$value" && "$accept_null" == "1"  ]]; then
                                    value="null"
                                fi

                            if [[ "$accept_null" == "0" ]]; then  
                                case $data_type in
                                    "string")
                                    ;;
                                    "number")
                                            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                                                echo "Error: $value is not a valid number."
                                                continue
                                            fi
                                    ;;
                                    *)
                                        echo "Error: Unsupported data type $data_type"
                                        continue
                                    ;;
                                esac
                            fi

                            
                            if [[ "$pk" == "1" ]]; then
                                primary_keys=($(awk -F',' -v col="$col_name" 'NR==1{for(i=1;i<=NF;i++) if($i==col) col_index=i} NR>1 && col_index {print $col_index}' $table_name.csv))
                                if [[ "${primary_keys[@]}" =~ "$value" ]]; then
                                    echo "Error: $col_name must be unique."
                                    continue
                                fi
                            fi

                            if [ "$first_column" = true ]; then
                                record+="$value"
                                first_column=false
                            else
                                record+=", $value"
                            fi
                    
                            break
                        done
                    done
                        echo "$record" >> "${table_name}.csv"
                        echo "Record inserted successfully."
                    break 2
                ;;
                2)
                    return
                ;;
                *)
                    echo "enter a valid choice"
                    break 
                ;;
            esac
        done
    done
    
}

delete(){

    while true;
    do
        echo "======================================================="
        echo "Available Tables:"
        #get the csv only
        ls -p | grep -E '*\.csv$' | awk '{gsub(/\.csv$/, "", $0); print $0}'
        echo "======================================================="
        read -p "Which table: " table_to_delete_from
        if [ ! -f $table_to_delete_from.csv ]; then
            echo "Such table doesn't exist."
            continue
        fi

        echo "======================================================="
        echo "The Available Columns:"
        echo $(awk -F "," 'NR==1 {print $0}' "$table_to_delete_from.csv")
        echo "======================================================="
        
        total_rows=$(( $(wc -l < "$table_to_delete_from.csv") - 1 ))
        cat  "$table_to_delete_from.csv"      

        echo "Total rows (excluding header) in "$table_to_delete_from.csv": $total_rows"

        read -p "Enter the row number to delete row: " row_number

        if [[ $row_number -lt 1 || $row_number -gt $total_rows ]]; then
            echo "Error: Row number must be between 1 and "$total_rows}"."
            continue
        fi
  
        sed -i "$(($Column_condition))d" "$table_to_delete_from.csv"
        echo "row deleted sucuessfully"
        echo " table after updated "
        cat  "$table_to_delete_from.csv"
        break
    done
}

update() {
    table_names=($(awk -F: '{print $1}' metadata | sort -u))
    
    while true; do
        echo "----------------------------------"
        echo "Select the table name to update (or 'N' for none):"
        echo "----------------------------------"

        select table in "${table_names[@]}" "N"; do
            case $table in
                "N") 
                    return 
                ;;
                *) 
                    if [[ ! " ${table_names[@]} " =~ " $table " ]]; then
                        echo "Invalid choice. Please enter a valid table name or 'N' to exit."
                        continue
                    else
                        table_name=$table

                        typeset -i index=0

                        while IFS=':' read -r t col_name data_type pk accept_null; do
                            if [[ "$t" == "$table_name" ]]; then
                                table_columns[$index]="$col_name:$data_type:$pk:$accept_null"
                                ((index++))
                            fi
                        done < metadata
                    fi
                break 
                ;;
            esac
        done

        declare -a col_names
        declare -a data_types
        declare -a pks
        declare -a nulls
        
        typeset -i index=0

        for key in "${!table_columns[@]}"; do
            col_info="${table_columns[$key]}"
            col_names[index]=$(echo "$col_info" | awk -F':' '{print $1}')
            data_types[index]=$(echo "$col_info" | awk -F':' '{print $2}')
            pks[index]=$(echo "$col_info" | awk -F':' '{print $3}')
            nulls[index]=$(echo "$col_info" | awk -F':' '{print $4}')
        
            ((index++))
        done

        echo "----------------------------------"
        echo "Select the column name to update (or 'N' for none):"
        echo "----------------------------------"
        
        select option in "${col_names[@]}" "N"; 
        do
            case $option in
                "N")
                    break
                ;;
                *)
                    if [[ ! " ${col_names[@]} " =~ " $option " ]]; then
                        echo "Invalid choice. Please enter a valid column name or 'N'."
                        continue
                    else
                        updated_col=$option
                        for i in "${!col_names[@]}"; do
                            if [[ "${col_names[$i]}" == "$updated_col" ]]; then
                                updated_index=$i
                                break
                            fi
                        done
                        echo "index: "$updated_index
                        updated_dt=${data_types[$updated_index]}
                        updated_null=${nulls[$updated_index]}
                        updated_pk=${pks[$updated_index]}
                        break
                    fi
                ;;
            esac
        done

        while true; do
            read -p "Enter value for $updated_col ($updated_dt): " value

            if [[ -z "$value" && "$updated_null" == "0" ]]; then
                echo "Error: Column $updated_col does not accept null values."
                continue
            elif [[ -z "$value" && "$updated_null" == "1" ]]; then
                value="null"
            fi

            if [[ "$updated_null" == "0" ]]; then  
                case $updated_dt in
                    "string")
                        ;;
                    "number")
                        if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                            echo "Error: $value is not a valid number."
                            continue
                        fi
                        ;;
                    *)
                        echo "Error: Unsupported data type $updated_dt"
                        continue
                        ;;
                esac
            fi


            if [[ "$updated_pk" == "1" ]]; then
                primary_keys_values=($(awk -F',' -v col="$updated_col" 'NR==1{for(i=1;i<=NF;i++) if($i==col) col_index=i} NR>1 && col_index {print $col_index}' "$table_name.csv"))
                if [[ "${primary_keys_values[@]}" =~ "$value" ]]; then
                    echo "Error: $updated_col must be unique."
                    continue
                fi
            fi

            total_rows=$(( $(wc -l < "$table_name.csv") - 1 ))
            echo "Total rows (excluding header) in $table_name.csv: $total_rows"

            read -p "Enter the row number to update (between 1 and $total_rows): " row_number

            if [[ $row_number -lt 1 || $row_number -gt $total_rows ]]; then
                echo "Error: Row number must be between 1 and "$total_rows}"."
                continue
            fi

            sed -i "$((row_number + 1))s/[^,]*/$value/$((updated_index + 1))" "$table_name.csv"

            echo "Value updated successfully."
            break
        done
    done
}


display_menu() {

    while true; do
        echo "-----------------------"
        echo "Table DML Menu: "
        echo "-----------------------"
        select option in "Select Query" "Insert Statement" "Update Statement" "Delete Statement" "Return to DDL Menu" "Disconnect DB" "Exit"; 
        do
            if [[ -z "$REPLY" ]]; then
                echo "You entered an empty choice, please enter an input."
                continue
            fi

            case $REPLY in
                1)
                    echo "*********************"
                    echo "Select Query"
                    echo "*********************"
                    select_statement
                    break
                ;;
                2)
                    echo "*********************"
                    echo "Insert Statement"
                    echo "*********************"
                    insert
                    break
                ;;
                3)
                    echo "*********************"
                    echo "Update Statement"
                    echo "*********************"
                    update
                    break
                ;;
                4)
                    echo "*********************"
                    echo "Delete Statement"
                    echo "*********************"
                    delete
                    break
                ;;
                5)
                    echo "--------------------------------------------------"
                    echo "Return to DDL Menu"
                    source ../../table_DDL.sh
                    break 2
                ;;
                6)
                    echo "Disconnect from DB done successfully...."
                    cd ..
                    pwd
                    source ../DB_DDL.sh
                    break 2
                ;;
                7)
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



