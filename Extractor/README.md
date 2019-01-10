# SEC-Edgar-CDS-Record-Extractor

SEC Edgar N-Q, N-CSR, N-CSRS，Credit Default Swap，Reference Entity, Holding Position, Notional Amount, Date, Counterparty。  

PIMCO FUNDS 17：  
```
perl ./extract.pl 0001193125-17-056504.txt.gz
```

```
META    KEYWORDS        1426
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      MCDX-27 5-YEAR   INDEX  BUY     USD     400000  CBK
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      DEUTSCHE BANK AG        SELL    EUR     100000  BOA
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      DEUTSCHE BANK AG        SELL    EUR     100000  BPS
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      DEUTSCHE BANK AG        SELL    EUR     100000  BRC
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      DEUTSCHE BANK AG        SELL    EUR     100000  JPM
SKIP-NOCOUNTERPARTY     0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      .       SELL    USD     .       .
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      CANADIAN NATURAL RESOURCES LTD. SELL    USD     1900000 .
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      3-MONTH USD-LIBOR       BUY     USD     76600000        .
ITEM    0001193125      17      056504  0000810893      PIMCO FUNDS     02/24/2017      .       12/31/2016      3-MONTH USD-LIBOR       BUY     USD     20460000
```
