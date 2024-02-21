# bashDB_simulator
# Database Management Simulator using Bash Scripting

This Bash script provides a simple menu-driven interface for managing databases. It allows users to create, list, connect to, drop databases, crate, drop, list tables in the database, and select, delete, update, insert statements.

## Functionalities

1. Create Database :
    Prompts the user to enter the name of the new database, Checks if a database with the same name already exists, If not, creates a new directory with the provided name.

2. List Databases :
    Lists all existing databases in the current directory.

3. Connect to Database :
    Prompts the user to select a database to connect to, If the selected database exists, navigates into its directory, Executes a script named table_DDL.sh located in the selected database directory.

4. Drop Database :
    Prompts the user to select a database to delete, Asks for confirmation before deleting the selected database, Removes the directory of the selected database if confirmed.

5. Exit :
    Exits the script.

6. Create Table
    Prompts the user to enter a table name, Validates the table name to ensure it is not empty, doesn't contain spaces, and isn't comprised only of numbers, Checks if a table with the same name already exists, Prompts the user to enter the number of columns for the table, For each column, prompts the user to enter the column name and select the data type (string or number), Allows the user to designate a primary key column and specify columns that accept null values, Creates the table file as a CSV and updates the metadata file with table information.

6. Drop Table :
    Lists existing tables and prompts the user to select a table to drop, Removes the corresponding CSV file if it exists and updates the metadata file to remove information about the dropped table.

7. Select Query: 
    Displays a menu for selecting tables and performing SELECT queries. Supports selecting all columns, specific columns, and selecting with WHERE condition.

8. Insert Statement: 
    Guides the user through inserting records into tables. Validates input data based on column constraints.

9. Update Statement: 
    Guides the user through updating records in tables. Validates input data based on column constraints.
11. Delete Statement: 
    Guides the user through deleting records from tables. Validates input data based on row numbers.

12. Return to DDL Menu: 
    Returns to the Database Definition Language (DDL) menu for managing database structure.

13. Disconnect DB: 
    Disconnects from the current database and returns to the main menu.

## Usage


## Usage

1. **Clone the repository**:  
   ```bash
   git clone https://github.com/emadeldinadel2022/bashDB_simulator.git

2. **Make the file executable**:
   ```bash
    chmod +x DB_DDLsh

3. **Run DB_DDL.sh file**:
    ```bash
    ./DB_DDL.sh


