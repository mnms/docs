!!! Note
    By default, we support all of the features provided in LightningDB v1.x, and we only point you to the ones that have been added and changed.

# 1. createTable

- Command
    - "TABLE.META.WRITE" "createTable" "catalog name" "namespace name" "table name" "schema binary"
- Examples
```
127.0.0.1:7389> help "TABLE.META.WRITE" "createTable"

  TABLE.META.WRITE createTable catalog.namespace.table arrow::schema
  summary: Create a new table
  since: 2.0.0
  group: table.meta

127.0.0.1:7389> "TABLE.META.WRITE" "createTable" "cat_1.test.table" "\x10\x00\x00\x00\x00\x00\n\x00\x0e\x00\x06\x00\r\x00\b\x00\n\x00\x00\x00\x00\x00\x04\x00\x10\x00\x00\x00\x00\x01\n\x00\x0c\x00\x00\x00\b\x00\x04\x00\n\x00\x00\x00\b\x00\x00\x00\xc4\x01\x00\x00\t\x00\x00\x00\x80\x01\x00\x00D\x01\x00\x00\x18\x01\x00\x00\xec\x00\x00\x00\xc0\x00\x00\x00\x98\x00\x00\x00h\x00\x00\x00@\x00\x00\x00\x04\x00\x00\x00\xac\xfe\xff\xff\b\x00\x00\x00\x18\x00\x00\x00\x0e\x00\x00\x00127.0.0.1:7389\x00\x00\x13\x00\x00\x00properties.location\x00\xe4\xfe\xff\xff\b\x00\x00\x00\x0c\x00\x00\x00\x03\x00\x00\x00job\x00\x0b\x00\x00\x00partition.1\x00\b\xff\xff\xff\b\x00\x00\x00\x0c\x00\x00\x00\x01\x00\x00\x001\x00\x00\x00\x10\x00\x00\x00internal.version\x00\x00\x00\x004\xff\xff\xff\b\x00\x00\x00\x0c\x00\x00\x00\x03\x00\x00\x00age\x00\x0b\x00\x00\x00partition.0\x00X\xff\xff\xff\b\x00\x00\x00\x0c\x00\x00\x00\x01\x00\x00\x002\x00\x00\x00\x0e\x00\x00\x00partition.size\x00\x00\x80\xff\xff\xff\b\x00\x00\x00\x0c\x00\x00\x00\x03\x00\x00\x00512\x00\x0c\x00\x00\x00cva.capacity\x00\x00\x00\x00\xa8\xff\xff\xff\b\x00\x00\x00\x0c\x00\x00\x00\x02\x00\x00\x0024\x00\x00\x0e\x00\x00\x00properties.ttl\x00\x00\xd0\xff\xff\xff\b\x00\x00\x00\x10\x00\x00\x00\x04\x00\x00\x002560\x00\x00\x00\x00\x11\x00\x00\x00rowgroup.capacity\x00\x00\x00\b\x00\x0c\x00\b\x00\x04\x00\b\x00\x00\x00\b\x00\x00\x00\x18\x00\x00\x00\x0e\x00\x00\x00127.0.0.1:7379\x00\x00\x14\x00\x00\x00properties.metastore\x00\x00\x00\x00\x03\x00\x00\x00\x88\x00\x00\x004\x00\x00\x00\x04\x00\x00\x00\x96\xff\xff\xff\x14\x00\x00\x00\x14\x00\x00\x00\x14\x00\x00\x00\x00\x00\x05\x01\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x84\xff\xff\xff\x03\x00\x00\x00job\x00\xc2\xff\xff\xff\x14\x00\x00\x00\x14\x00\x00\x00\x1c\x00\x00\x00\x00\x00\x02\x01 \x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x0c\x00\b\x00\a\x00\b\x00\x00\x00\x00\x00\x00\x01 \x00\x00\x00\x03\x00\x00\x00age\x00\x00\x00\x12\x00\x18\x00\x14\x00\x13\x00\x12\x00\x0c\x00\x00\x00\b\x00\x04\x00\x12\x00\x00\x00\x14\x00\x00\x00\x14\x00\x00\x00\x18\x00\x00\x00\x00\x00\x05\x01\x14\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x04\x00\x04\x00\x00\x00\x04\x00\x00\x00name\x00\x00\x00\x00"

```


# 2. truncateTable

- Command
    - "TABLE.META.WRITE" "truncateTable" "{catalog name}.{namespace name}.{table name}"
- Examples
```
127.0.0.1:7389> help "TABLE.META.WRITE" "truncateTable"

  TABLE.META.WRITE truncateTable catalog.namespace.table
  summary: Truncate the table(Remove all data in the table)
  since: 2.0.0
  group: table.meta

127.0.0.1:7389>
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table" "*"
 1) "21\x1eSales Manager"
 2) "22\x1eTutor"
 3) "23\x1eBanker"
 4) "23\x1eProfessor"
 5) "23\x1eSales Manager"
 6) "24\x1eStudent"
 7) "26\x1eStudent"
 8) "27\x1eSales Manager"
 9) "29\x1eBanker"
10) "29\x1eProfessor"
11) "32\x1eProfessor"
12) "32\x1eSales Manager"
13) "33\x1eProfessor"
14) "36\x1eProfessor"
15) "41\x1eBanker"
16) "43\x1eSales Manager"
17) "45\x1eBanker"
18) "47\x1eBanker"
19) "48\x1eCEO"
127.0.0.1:7389> TABLE.META.WRITE truncateTable "cat_1.test.table"
"OK"
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table" "*"
(empty list or set)
```

# 3. dropTable

- Command
    - "TABLE.META.WRITE" "dropTable" "{catalog name}.{namespace name}.{table name}"
- Examples
```
127.0.0.1:7389> help "TABLE.META.WRITE" "dropTable"

  TABLE.META.WRITE dropTable catalog.namespace.table
  summary: Drop the table(Remove all data and the schema)
  since: 2.0.0
  group: table.meta

127.0.0.1:7389>

127.0.0.1:7389> TABLE.META.READ showTables
1) "cat_1.test.table"
2) "version: 1"
127.0.0.1:7389> TABLE.META.WRITE dropTable "cat_1.test.table"
"OK"
127.0.0.1:7389> TABLE.META.READ showTables
(empty list or set)
```

# 4. dropAllTables

- Command
    - "TABLE.META.WRITE" "dropAllTables"
- Examples
```
127.0.0.1:7389> help "TABLE.META.WRITE" "dropAllTables"

  TABLE.META.WRITE dropAllTables -
  summary: Drop all tables
  since: 2.0.0
  group: table.meta

127.0.0.1:7389>
127.0.0.1:7389> TABLE.META.READ showTables
1) "cat_1.test.table"
2) "version: 1"
127.0.0.1:7389> TABLE.META.WRITE dropAllTables
1 tables are deleted.
```

# 5. setTableTtl

- Command
    - "TABLE.META.WRITE" "settablettl" "{catalog name}.{namespace name}.{table name}"  "{ttl time(unit: msec)}"
- Example
```
127.0.0.1:7389> help "TABLE.META.WRITE" "seTtableTtl"

  TABLE.META.WRITE setTableTtl catalog.namespace.table ttl(msec)
  summary: Set the ttl of the table
  since: 2.0.0
  group: table.meta

127.0.0.1:7389> TABLE.META.WRITE setTableTtl "cat_1.test.table" 30000
OK
```

# 6. showTables

- Command
    - "TABLE.META.READ" "showTables" 
- Examples
```
127.0.0.1:7389> help TABLE.META.READ showTables

  TABLE.META.READ showTables -
  summary: Get the list of tables with their own version
  since: 2.0.0
  group: table.meta

127.0.0.1:7389>
127.0.0.1:7389> TABLE.META.READ showTables
1) "cat_1.test.table"
2) "version: 1"
```

# 7. describeTable

- Command
    - "TABLE.META.READ" "describeTable" "table name"
- Examples
```
127.0.0.1:7389> help TABLE.META.READ describeTables

  TABLE.META.READ describeTables catalog.namespace.table
  summary: Get all columns and partitions of the table
  since: 2.0.0
  group: table.meta

127.0.0.1:7389>

127.0.0.1:7389> TABLE.META.READ showTables
1) "cat_1.test.table"
2) "version: 1"

127.0.0.1:7389> TABLE.META.READ describeTables "cat_1.test.table"
1) "name: string"
2) "age: int32"
3) "job: string"
4) "[ partitions: age job ]"
```

# 8. getTableTtl

- Command
    - "TABLE.META.READ" gettablettl  "{catalog name}.{namespace name}.{table name}"  
- Examples
```
127.0.0.1:7389> help TABLE.META.READ getTableTtl

  TABLE.META.READ getTableTtl catalog.namespace.table
  summary: Get the ttl of the table
  since: 2.0.0
  group: table.meta

127.0.0.1:7389> TABLE.META.READ getTableTtl *
1) "cat_1.test.network_table"
2) "86400000"
3) "cat_1.test.table"
4) "86400000"
127.0.0.1:7389> TABLE.META.READ getTableTtl cat_1.*
1) "cat_1.test.network_table"
2) "86400000"
3) "cat_1.test.table"
4) "86400000"
127.0.0.1:7389> TABLE.META.READ getTableTtl *.network_table
1) "cat_1.test.network_table"
2) "86400000"
127.0.0.1:7389> TABLE.META.READ getTableTtl cat_1.test.network_table
1) "cat_1.test.network_table"
2) "86400000"
127.0.0.1:7389>
```

# 9. getPartitionTtl

- Command
    - "TABLE.META.READ" getPartitionTtl  "{catalog name}.{namespace name}.{table name}" "partition string with regular expression"
- Examples
```
127.0.0.1:7389> help TABLE.META.READ getPartitionTtl

  TABLE.META.READ getPartitionTtl partition-string
  summary: Get the ttl of the partition in the table
  since: 2.0.0
  group: table.meta

127.0.0.1:7389> TABLE.META.READ getPartitionTtl "cat_1.test.table" "*"
 1) "21\x1eSales Manager"
 2) "86350123"
 3) "22\x1eTutor"
 4) "86350139"
 5) "23\x1eBanker"
 6) "86350126"
 7) "23\x1eProfessor"
 8) "86350125"
 9) "23\x1eSales Manager"
10) "86350137"
11) "24\x1eStudent"
12) "86350121"
13) "26\x1eStudent"
14) "86350124"
15) "27\x1eSales Manager"
16) "86350132"
17) "29\x1eBanker"
18) "86350124"
19) "29\x1eProfessor"
20) "86350125"
21) "32\x1eProfessor"
22) "86350127"
23) "32\x1eSales Manager"
24) "86350123"
25) "33\x1eProfessor"
26) "86350120"
27) "36\x1eProfessor"
28) "86350134"
29) "40\x1eBanker"
30) "86350119"
31) "41\x1eBanker"
32) "86350120"
33) "43\x1eSales Manager"
34) "86350133"
35) "45\x1eBanker"
36) "86350128"
37) "47\x1eBanker"
38) "86350124"
39) "48\x1eCEO"
40) "86350138"
127.0.0.1:7389> TABLE.META.READ getPartitionTtl "cat_1.test.table" "23*"
1) "23\x1eBanker"
2) "86343642"
3) "23\x1eProfessor"
4) "86343641"
5) "23\x1eSales Manager"
6) "86343653"
127.0.0.1:7389> TABLE.META.READ getPartitionTtl "cat_1.test.table" "*CEO"
1) "48\x1eCEO"
2) "86336153"
127.0.0.1:7389> TABLE.META.READ getPartitionTtl "cat_1.test.table" "45\x1eBanker"
1) "45\x1eBanker"
2) "86324848"
127.0.0.1:7389>
```
# 10. insert

- Command
    - "TABLE.DATA.WRITE" "Insert" "{catalog name}.{namespace name}.{table name}" "table version" "partition string" "binaries... ..."
- Examples
```
127.0.0.1:7389> help "TABLE.DATA.WRITE" "Insert"

  TABLE.DATA.WRITE insert catalog.namespace.table table-version partition-string data
  summary: Insert a new data(row)
  since: 2.0.0
  group: table.data

1636425657.602951 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "40\x1eBanker" "Jeannie" "(\x00\x00\x00" "Banker"
1636425657.604043 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "33\x1eProfessor" "Ardith" "!\x00\x00\x00" "Professor"
1636425657.604529 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "41\x1eBanker" "Elena" ")\x00\x00\x00" "Banker"
1636425657.605351 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "24\x1eStudent" "Corliss" "\x18\x00\x00\x00" "Student"
1636425657.607351 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "41\x1eBanker" "Kiyoko" ")\x00\x00\x00" "Banker"
1636425657.608057 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "21\x1eSales Manager" "Hilton" "\x15\x00\x00\x00" "Sales Manager"
1636425657.608455 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "32\x1eSales Manager" "Becky" " \x00\x00\x00" "Sales Manager"
1636425657.609218 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "29\x1eBanker" "Wendie" "\x1d\x00\x00\x00" "Banker"
1636425657.609940 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "26\x1eStudent" "Carolina" "\x1a\x00\x00\x00" "Student"
1636425657.610284 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "47\x1eBanker" "Laquita" "/\x00\x00\x00" "Banker"
1636425657.610638 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "23\x1eProfessor" "Stephani" "\x17\x00\x00\x00" "Professor"
1636425657.610964 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "29\x1eProfessor" "Emile" "\x1d\x00\x00\x00" "Professor"
1636425657.612257 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "23\x1eBanker" "Cherri" "\x17\x00\x00\x00" "Banker"
1636425657.612630 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "47\x1eBanker" "Raleigh" "/\x00\x00\x00" "Banker"
1636425657.612943 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "32\x1eProfessor" "Hollis" " \x00\x00\x00" "Professor"
1636425657.614136 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "45\x1eBanker" "Brigette" "-\x00\x00\x00" "Banker"
1636425657.615558 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "21\x1eSales Manager" "Damian" "\x15\x00\x00\x00" "Sales Manager"
1636425657.617321 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "27\x1eSales Manager" "Star" "\x1b\x00\x00\x00" "Sales Manager"
1636425657.618819 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "43\x1eSales Manager" "Elba" "+\x00\x00\x00" "Sales Manager"
1636425657.619621 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "36\x1eProfessor" "Lourie" "$\x00\x00\x00" "Professor"
1636425657.622977 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "23\x1eSales Manager" "\xea\xb0\x80\xeb\x82\x98\xeb\x82\x98\xeb\x82\x98\xea\xb0\x80\xeb\x82\x98\xeb\x82\x98" "\x17\x00\x00\x00" "Sales Manager"
1636425657.623555 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "48\x1eCEO" "Elon" "0\x00\x00\x00" "CEO"
1636425657.624359 [0 127.0.0.1:53881] "TABLE.DATA.WRITE" "Insert" "cat_1.test.table" "1" "22\x1eTutor" "Kijung" "\x16\x00\x00\x00" "Tutor"
```

# 11. partitions

### a. Query with a pattern
- Commnad
    - "TABLE.DATA.READ" "partitions"  "{catalog name}.{namespace name}.{table name}" "pattern(normaly '*')"
- Examples
```
127.0.0.1:7389> help TABLE.DATA.READ partitions

  TABLE.DATA.READ partitions catalog.namespace.table pattern partition-filter(optional)
  summary: Get the list of partitions with the pattern and filter
  since: 2.0.0
  group: table.data

127.0.0.1:7389>
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table" "*"
 1) "21\x1eSales Manager"
 2) "22\x1eTutor"
 3) "23\x1eBanker"
 4) "23\x1eProfessor"
 5) "23\x1eSales Manager"
 6) "24\x1eStudent"
 7) "26\x1eStudent"
 8) "27\x1eSales Manager"
 9) "29\x1eBanker"
10) "29\x1eProfessor"
11) "32\x1eProfessor"
12) "32\x1eSales Manager"
13) "33\x1eProfessor"
14) "36\x1eProfessor"
15) "40\x1eBanker"
16) "41\x1eBanker"
17) "43\x1eSales Manager"
18) "45\x1eBanker"
19) "47\x1eBanker"
20) "48\x1eCEO"
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table" "29*"
1) "29\x1eBanker"
2) "29\x1eProfessor"
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table" "*Professor"
1) "23\x1eProfessor"
2) "29\x1eProfessor"
3) "32\x1eProfessor"
4) "33\x1eProfessor"
5) "36\x1eProfessor"
```

### b. Query with a pattern and filters
- Command
    - "TABLE.DATA.READ" "partitions" "catalog name" "namespace name" "table name" "pattern(normaly '*')"  "partition filter"
- Examples
```
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table" "*" "age\x1e30\x1eLTE"
 1) "21\x1eSales Manager"
 2) "22\x1eTutor"
 3) "23\x1eBanker"
 4) "23\x1eProfessor"
 5) "23\x1eSales Manager"
 6) "24\x1eStudent"
 7) "26\x1eStudent"
 8) "27\x1eSales Manager"
 9) "29\x1eBanker"
10) "29\x1eProfessor"
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table" "*" "age\x1e32\x1eEQ"
1) "32\x1eProfessor"
2) "32\x1eSales Manager"

127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table"  "*" "age\x1e32\x1eLT\x1ejob\x1eCEO\x1eLTE\x1eAND"
1) "23\x1eBanker"
2) "29\x1eBanker"
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table"  "*" "age\x1e32\x1eLT\x1ejob\x1eCEO\x1eGTE\x1eAND"
1) "21\x1eSales Manager"
2) "22\x1eTutor"
3) "23\x1eProfessor"
4) "23\x1eSales Manager"
5) "24\x1eStudent"
6) "26\x1eStudent"
7) "27\x1eSales Manager"
8) "29\x1eProfessor"
127.0.0.1:7389> TABLE.DATA.READ partitions "cat_1.test.table"  "*" "age\x1e32\x1eGT\x1ejob\x1eCEO\x1eGTE\x1eAND"
1) "33\x1eProfessor"
2) "36\x1eProfessor"
3) "43\x1eSales Manager"
4) "48\x1eCEO"
```

# 12. select

- Command
    - "TABLE.DATA.READ" "select" "catalog name" "namespace name" "table name"  "pattern(normaly '*')"  "partition filter" "data filter" 
- Examples
```
127.0.0.1:7389> help TABLE.DATA.READ select

  TABLE.DATA.READ select catalog.namespace.table projection partition-filter data-filter
  summary: Get the data with the pattern and filter
  since: 2.0.0
  group: table.data

127.0.0.1:7389> TABLE.DATA.READ select xxx ....
```

# 13. getPartitionRowCount

- Command
    - "TABLE.DATA.READ" "getPartitionRowCount"  "{catalog name}.{namespace name}.{table name}"  "partition string with regular expression" 
- Examples
```
127.0.0.1:7389> help TABLE.DATA.READ getPartitionRowCount

  TABLE.DATA.READ getPartitionRowCount catalog.namespace.table partition-string
  summary: Get the count of the rows in the partition
  since: 2.0.0
  group: table.data

127.0.0.1:7389> TABLE.DATA.READ getPartitionRowCount "cat_1.test.table" *
 1) "21\x1eSales Manager"
 2) "2"
 3) "22\x1eTutor"
 4) "1"
 5) "23\x1eBanker"
 6) "1"
 7) "23\x1eProfessor"
 8) "1"
 9) "23\x1eSales Manager"
10) "1"
11) "24\x1eStudent"
12) "1"
13) "26\x1eStudent"
14) "1"
15) "27\x1eSales Manager"
16) "1"
17) "29\x1eBanker"
18) "1"
19) "29\x1eProfessor"
20) "1"
21) "32\x1eProfessor"
22) "1"
23) "32\x1eSales Manager"
24) "1"
25) "33\x1eProfessor"
26) "1"
27) "36\x1eProfessor"
28) "1"
29) "40\x1eBanker"
30) "1"
31) "41\x1eBanker"
32) "2"
33) "43\x1eSales Manager"
34) "1"
35) "45\x1eBanker"
36) "1"
37) "47\x1eBanker"
38) "2"
39) "48\x1eCEO"
40) "1"
127.0.0.1:7389> TABLE.DATA.READ getPartitionRowCount "cat_1.test.table" "23*"
1) "23\x1eBanker"
2) "1"
3) "23\x1eProfessor"
4) "1"
5) "23\x1eSales Manager"
6) "1"
127.0.0.1:7389> TABLE.DATA.READ getPartitionRowCount "cat_1.test.table" "*Professor"
 1) "23\x1eProfessor"
 2) "1"
 3) "29\x1eProfessor"
 4) "1"
 5) "32\x1eProfessor"
 6) "1"
 7) "33\x1eProfessor"
 8) "1"
 9) "36\x1eProfessor"
10) "1"
127.0.0.1:7389> TABLE.DATA.READ getPartitionRowCount "cat_1.test.table" "45\x1eBanker"
1) "45\x1eBanker"
2) "1"

```

# 14. getPartitionRowGroup

- Command
    - "TABLE.DATA.READ" "getPartitionRowGroup" 
 "{catalog name}.{namespace name}.{table name}"  "partition string" 
- Examples
```
127.0.0.1:7389> help TABLE.DATA.READ getPartitionRowGroup

  TABLE.DATA.READ getPartitionRowGroup catalog.namespace.table partition-string
  summary: Get the count of the rows in the each row-group of the partition
  since: 2.0.0
  group: table.data

127.0.0.1:7389> TABLE.DATA.READ getPartitionRowGroup "cat_1.test.table" "21\x1eSales Manager"
1) "0"
2) "1"
3) "1"
4) "2"
127.0.0.1:7389>
```

# 15. getTableRowCount

- Command
    - "TABLE.DATA.READ" "gettablerowcount" "{catalog name}.{namespace name}.{table name} with regular expression"
- Examples
```
127.0.0.1:7389> help TABLE.DATA.READ getTableRowCount

  TABLE.DATA.READ getTableRowCount -
  summary: Get the row count of each table
  since: 2.0.0
  group: table.data

127.0.0.1:7389> TABLE.DATA.READ getTableRowCount *
1) "cat_1.test.network_table"
2) "33229"
3) "cat_1.test.table"
4) "23"
127.0.0.1:7389>
```