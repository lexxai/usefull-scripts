#Get-Router-Stats
BASH Scripts for periodic collect staistic by traffic use.

Get authenticated stats information from  WiFi Router TP-Link 740 (TL-WR740N) with default user: admin, password: admin

Used parsing web interface output.

Results saved on same folder with script in plain TXT file.

File `./get-stat-inerf.sh` use Intraface statistic on main page of web interface 


```
./get-stat-inerf.sh
739599306
1768794250
11780542
4978620
IN: 739599306 bytes
OUT: 1768794250 bytes
TOTAL: 2508393556 bytes
------------------------
D IN: 88784208 bytes
D OUT: 2499388 bytes
D TOTAL: 91283596 bytes
------------------------
TOTAL IN:       14214610821B     13556M          13G 0T
TOTAL OUT:      1113780849B      1062M
TOTAL TOT:      15328391670B     14618M          14G 0T
```


File `./get-stat-user.sh` use enabled statictic per clients page
```
./get-stat-user.sh
IN: [152219503]
IN: [121245699]
IN: [2685601418]
IN: []
IN: 2959066620 bytes
------------------------
D IN: 4456454 bytes
------------------------
TOTAL IN: 15452164785B 14736M  14G 0T
```
