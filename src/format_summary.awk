#!/usr/bin/awk -f
BEGIN {
	FS = "\t"
	OFS = ","
	ORS = "\r\n"
	
}
{ 
	printf "**$%.2f** is being spent on **%s**, with an average of **$%.2f** per transaction in this category.\n",$2,$1,$3
}