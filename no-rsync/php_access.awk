#! /bin/awk -f

BEGIN {

}

{
	gsub(/\?.*/,"",$23);

	if(match($23,"/")) {
    totals[$23]+=$2;
    count[$23]+=1;
	}
}

END {

  for (x in totals){
    if ( count[x] > 2 ) {
      printf("%10.2f\t%d\t%s\n",totals[x]/count[x],count[x],x);
    }
  }

}
