#! /bin/awk -f

# Shows hits per hour by default. Assign a value to i to change interval.
# i.e hitsper i=5   is hits per 5 minute interval

BEGIN {


}

{
  if($15 != "" ) {

    if (match($5,/192.240.190.45/)) {

      gsub(/\.[0-9]*$/,"",$3);
      incoming[$3]+=$15

    } else if (match($3,/192.240.190.45/)) {

      gsub(/\.[0-9]*:/,"",$5);
      outgoing[$5]+=$15

    }
  }

}

END {

  WHITE="\033[1;37m"
  BLUE="\033[1;34m"
  GREEN="\033[1;32m"

  PROCINFO["sorted_in"]="@val_num_desc"

  printf "\n\nIncoming:\n";
  for (x in incoming){
		printf("%-16s %dM\n",x, incoming[x]/1024/1024);
  }
  printf "\n\nOutgoing:\n"
  for (x in outgoing){
		printf("%-16s %dM\n",x, outgoing[x]/1024/1024);
  }
	printf "\n";

}
