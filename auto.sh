#!/bin/bash

number_in_file=$(tail -n1 item-number | grep -E -o "[[:digit:]]{4,6}")
incremental_num=$(expr $number_in_file + 1)

function file_creation() {

	 #Appending new item in file "item-number"
        printf "\nType in item category name (in lowercase !):\n"
        
        read item_category_name  
 
        echo $number_in_file
 
        echo $incemental_num
        date=$(date +"%D-%R")
        
        echo $incremental_num,$item_category_name,$date >> item-number

	#Creating new item

	cp website/categories/$item_category_name/items/item-x.html website/categories/$item_category_name/items/item-$incremental_num.html


        printf "\nType in item Name :\n"
	read name

        printf "\nType in item price :\n"
	read price 

        printf "\nType in item color :\n"
	read color

        printf "\nType in item size :\n"
	read size

	sed -i "s|Item-Name|$name|g; s|Item-Price|€$price|g; s|Item-Color|$color|g; s|Item-Size|$size|g; s|pic1|item-$incremental_num-1|g ; s|pic2|item-$incremental_num-2|g" website/categories/$item_category_name/items/item-$incremental_num.html

	# Append item in page
	sed "s|Item-Name|$name|g; s|Item-Price|€$price|g; s|Item-Number|$incremental_num|g; s|Item-Size|$size|g;" default_item_lines > new_item_lines

	sed -i "65 r new_item_lines" website/categories/$item_category_name/pages/page1.html

	 #BrowserCheck
	sleep 3
	firefox website/index.html
}


function file_deletion() {
	printf "\n!!! ALERT - Check Item Number in file 'item-number' - ALERT !!!:\n\n"

	# Deleting category
	printf "\nType category name (in lowercase !):\n\n"

	read category_name

	printf "\nType Item-Number (in lowercase !):\n\n"

	read item_num
	
	 #Files deletion
	rm -rf website/categories/$category_name/items/$item_num*
	
	 #Deleting lines from page.html
	 first_line_number=$(grep -nEA 12 "\--$item_num" website/categories/$category_name/pages/page1.html | grep -o -m1 -E '[[:digit:]]{2,3}:' | tr -d ':')
	echo $first_line_number
	
	last_line_number=$(grep -nEA 12 "\--$item_num" website/categories/$category_name/pages/page1.html | tail -n1 | tr -d '-')
	echo $last_line_number
	
	sed -i "$first_line_number,$last_line_number d" website/categories/$category_name/pages/page1.html
	
	 #BrowserCheck
	sleep 3
	firefox website/categories/$category_name/pages/page1.html
}


function category_deletion() {
	# Deleting category
	printf "\nType category name (in lowercase !):\n\n"

	read del_category_name
	del_upper_case_letter="${del_category_name^}"  #<-- Make the first letter uppercase #
	
	 #Dir deletion
	rm -rf website/categories/$del_category_name
	
	 #Removing category pic
	rm -rf website/assets/images/main-$del_category_name.jpg  
	
	 #Deleting lines from index.html
	first_line_number=$(grep -nA 12 Cat-$del_upper_case_letter website/index.html | grep -o -m1 -E '[[:digit:]]{2,4}')
	echo $first_line_number
	
	last_line_number=$(grep -nA 12 Cat-$del_upper_case_letter website/index.html | grep -o -E '[[:digit:]]{2,4}' | tail -n1)
	echo $last_line_number
	
	sed -i "$first_line_number,$last_line_number d" website/index.html
	
	 #BrowserCheck
	sleep 3
	firefox website/index.html
}

function category_creation() {
	# Creating new category
	printf "\nType category name (in lowercase !):\n\n"

	read new_category_name
	upper_case_letter="${new_category_name^}"  #<-- Make the first letter uppercase #
	
	 #Dir creation
	cp -r website/categories/default-files website/categories/$new_category_name
	
	 #Appending to index.html
	sed "s|cats|$new_category_name|g; s|Cats|$upper_case_letter|g; s|Cat-X|Cat-$upper_case_letter|g" default_lines > category_lines
	sed -i "65 r category_lines" website/index.html  #<-- Appending whole file to line 107 #
	
	 #Setting category pic
	
		#Resize/Rename
	convert -resize 301x400 -gravity center -background "rgb(255,255,255)" -extent 400x400 *.{jpg} main-$new_category_name.jpg
	
		#MoveToDir
	mv main-$new_category_name.jpg website/assets/images
	
		#BrowserCheck
	sleep 3
	firefox website/index.html
}


function options(){

	printf "\n\nChoose option: \n1) Create new category \n2) Delete category \n3) Add item \n4) Delete item \nn) exit\n\n"

        read option

        if [ $option = n ]; 
        then
                exit

        elif [ $option = 1 ]; 
        then
            category_creation    

        elif [ $option = 2 ]; 
        then
            category_deletion

        elif [ $option = 3 ]; 
        then
		file_creation 

        elif [ $option = 4 ]; 
        then
		file_deletion
        fi
}
options

