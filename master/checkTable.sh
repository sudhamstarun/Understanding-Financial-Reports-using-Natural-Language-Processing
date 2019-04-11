#!/bin/bash
for dir in master/*/
do	
			for file in $dir/*
			do (
				 if grep -iq "credit default swap" $file 
				 	# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
				 	then
(cd ../..)
				 		if [ -d m/$(basename $dir) ]
				 		then
				 			(cp $file m/$(basename $dir) )
				 		else
				 		(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
				 		fi
				 	fi


				if grep -iq "notional amount" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi

if grep -iq "amount" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi



                                if grep -iq "creditdefaultswap" $file 
				# 	# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi

				if grep -iq "notionalamount" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi

				if grep -iq "referenceentity" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi


				 if grep -iq "reference entity" $file 
				 	# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
				 	then
(cd ../..)
				 		if [ -d m/$(basename $dir) ]
				 		then
				 			(cp $file m/$(basename $dir) )
				 		else
				 		(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
				 		fi
				 	fi

				 if grep -iq "counterparty" $file 
				 	# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
				 	then
(cd ../..)
				 		if [ -d m/$(basename $dir) ]
				 		then
				 			(cp $file m/$(basename $dir) )
				 		else
				 		(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
				 		fi
				 	fi

				 if grep -iq "expirationdate" $file 
				 	# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
				 	then
(cd ../..)
				 		if [ -d m/$(basename $dir) ]
				 		then
				 			(cp $file m/$(basename $dir) )
				 		else
				 		(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
				 		fi
				 	fi

				 if grep -iq "expiration date" $file 
				 	# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
				 	then
(cd ../..)
				 		if [ -d m/$(basename $dir) ]
				 		then
				 			(cp $file m/$(basename $dir) )
				 		else
				 		(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
				 		fi
				 	fi

              
				if grep -iq "terminationdate" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi

                                if grep -iq "termination date" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file /home2/vvsaripalli/master/m/$(basename $dir))
						fi
					fi


				if grep -iq "fixed rate" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi

				if grep -iq "fixedrate" $file 
					# || grep -iq "counterparty" || grep -iq "notional amount" || grep -iq "reference entity" || grep -iq "expirationdate" || grep -iq "expiration date"
					then
(cd ../..)
						if [ -d m/$(basename $dir) ]
						then
							(cp $file m/$(basename $dir) )
						else
						(cd m && mkdir "$(basename $dir)" && cd ../ && cp $file m/$(basename $dir))
						fi
					fi

		)
			done
	done


