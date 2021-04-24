# [Final Project](#top)

**Table of Contents**
1.  [Recap of Initial Probe](#recap)
2.  [Question 1](#question-1)
3.  [Question 2](#question-2)
4.  [Question 3](#question-3)
5.  [Question 4](#question-4)
6.  [Question 5](#question-5)
7.  [Question 6](#question-6)
8.  [Closing Statements](#conclusion)

## [Recap of Initial Probe](#recap)

Of note, for the work below, I've renamed the `propublica_trump_spending-1.csv` file to be `data.csv`. From there, I followed the steps of the initial scenario, to create a JSON output of the initial dataset.

```bash
# Rename the dataset for convienience.
$> mv propublica_trump_spending-1.csv data.csv

# Save copy of CSV-to-TSV conversion of dataset.
$> csv2tsv < data.csv > data.tsv

# Convert CSV file into a JSON file using pipeline.
$> csv2tsv < data.csv | tsv2json | jq '.' > data.json
```

While I could have saved the output of the `tsv2json` utility as `data.json`, the result would be minified. I filtered it through the `jq '.'` request to have a JSON valid file that is human-readable.

* * *
<div style="page-break-after: always; visibility: hidden">
\pagebreak
</div>

## [Question 1](#question-1)

*How many records are there in the dataset?*

There are **1193** records in the dataset.

```bash
# Convert to TSV, then count all lines after skipping the first one (the header).
$> csv2tsv < data.csv | tail -n +2 | wc -l
1193
```

[Return to the top](#top).

* * *
<div style="page-break-after: always; visibility: hidden">
\pagebreak
</div>

## [Question 2](#question-2)

*How many actual unique `purpose` entries are there for this spending? List what they are.*

There are **8** unique `purposes_scrubbed` in the dataset and they are listed below:

- "Event"
- "Food"
- "Legal"
- "Lodging"
- "Other"
- "Payroll"
- "Rent"
- "Travel"

```bash
# Pipeline for generating list of unique 'purpose_scrubbed' entries, in ascending alphabetical order.
$> cat data.tsv | keep-header -- sort -t $'\t' -k5,5 --ignore-case | tsv-uniq -H -f 5 | tsv-select -H -f 5 > data-purpose_scrubbed.tsv

# Counting the number of unique entries, skipping the header.
$> tail -n +2 data-purpose_scrubbed.tsv | wc -l
8

# Printing list of unique 'purpose_scrubbed' entries to the terminal.
$>  cat data-purpose_scrubbed.tsv
purpose_scrubbed
Event
Food
Legal
Lodging
Other
Payroll
Rent
Travel
```

To compare with the non-scrubbed purpose data, there are **220** unique `purpose` entries in the dataset, including "N/A".

```bash
# Store list of unique purpose entries, sorted in ascending alphabetical order. Matches ignore letter casing when possible.
$> cat data.tsv | keep-header -- sort -t $'\t' -k7,7 --ignore-case | tsv-uniq -H -f 7 --ignore-case | tsv-select -H -f 7 > data-purpose.tsv

# Counting the unique purposes (non-scrubbed).
$> tail -n +2 data-purpose.tsv | wc -l
220

# Print the header, the first five records, a set of ellipses, and the last five records, to preview the contents.
$> (head -n 6; echo '...'; tail -n 5) < data-purpose.tsv
purpose
002 Travel Parking
1ST BANKCARD PMT [SB21B.15922]: EVENT EXPENSE: FACILITY RENTAL/CATERING SERVICES
1ST BANKCARD PMT [SB21B.15922]: FUNDRAISING EXPENSE
1ST BANKCARD PMT [SB21B.18545]: EVENT EXPENSE: FACILITY RENTAL
1ST BANKCARD PMT [SB21B.19723]: MEETING EXPENSE
...
VOIDED CHECK: SERVICES NOT RENDERED
WALSH REIMBURSEMENT [SB21B.15515]: FUNDRAISING EXPENSE
WALSH REIMBURSEMENT [SB21B.15929]: TRAVEL: LODGING
WALSH REIMBURSEMENT [SB21B.4658]: MEETING EXPENSE: MEALS
[MEMO] Travel Expense
```

We can also see what sort of categories were classified as 'Other'.
Should 'parking' have been moved into the 'Travel' category? Questions for another time.

```bash
# Filter source to get a list of only the 'other' category.
$> cat data.tsv | keep-header -- sort -t $'\t' -k7,7 --ignore-case | tsv-uniq -H -f 7 --ignore-case | tsv-select -H -f 5,7 | tsv-filter -H --str-eq=1:"Other" > data-purpose_other.tsv

# Print the header, the first five records, a set of ellipses, and the last five records, to preview the contents.
$> (head -n 6; echo '...'; tail -n 5) < data-purpose_other.tsv
purpose_scrubbed        purpose
Other   002 Travel Parking
Other   AMEX PMT [SB23.1179442]: PARKING EXPENSE
Other   Automobile Parking Lots
Other   DC Occupancy Sales Tax
Other   Eating Places, Restaurants
...
Other   Service charges
Other   Valet Parking
Other   Vehicle towing and storage
Other   VOIDED CHECK: OVERPAYMENT
Other   VOIDED CHECK: SERVICES NOT RENDERED
```

[Return to the top](#top).

* * *
<div style="page-break-after: always; visibility: hidden">
\pagebreak
</div>

## [Question 3](#question-3)

*How much is being spent on each unique `purpose_scrubbed`?*

### Per Category (Purpose)

**$9,282,248.45** is being spent on **Travel**, with an average of **$134,525.34** per transaction in this category.
**$2,956,588.00** is being spent on **Rent**, with an average of **$33,220.09** per transaction in this category.
**$2,132,210.96** is being spent on **Event**s, with an average of **$13,756.20** per transaction in this category.
**$881,461.37** is being spent on **Lodging**, with an average of **$2,012.47** per transaction in this category.
**$168,016.00** is being spent on **Legal**, with an average of **$24,002.29** per transaction in this category.
**$145,054.51** is being spent on **Food**, with an average of **$560.06** per transaction in this category.
**$424,615.83** is being spent on **Payroll**, with an average of **$3,825.37** per transaction in this category.
**$95,716.56** is being spent on **Other**, with an average of **$1,472.57** per transaction in this category.

```bash
# Pipeline with pretty output for calculating total and average spending, grouped by the purpose of the expenditure
# The output is sorted by spending totals (in descending order).
$> cat data.tsv | keep-header -- sort -t $'\t' -k4,4nr | tsv-select -H -f 5,4 | tsv-summarize --header --group-by 1 --sum 2:"Spending (in USD)" --mean 2:"Average (in USD)" | tsv-pretty
purpose_scrubbed  Spending (in USD)  Average (in USD)
Travel                   9282248.45  134525.339855
Rent                     2956588      33220.0898876
Event                    2132210.96   13756.1997419
Lodging                   881461.37    2012.46888128
Legal                     168016      24002.2857143
Food                      145054.51     560.056023166
Payroll                   424615.83    3825.36783784
Other                      95716.56    1472.56246154
```

### Handling Refunds

When interpreting this data, it should be noted that the 'Other' and 'Event' category totals include refunded amounts.

```bash
# Filter for expenditures 'less than' $0.
$> cat data.tsv | keep-header -- sort -t $'\t' -k4,4nr | tsv-select -H -f 5,4,7 | tsv-filter -H --lt=2:0 > data-refunds.tsv
Other   -428.53 VOIDED CHECK: SERVICES NOT RENDERED
Other   -828.26 VOIDED CHECK: OVERPAYMENT
Event   -11541.2        AMEX: REFUND: FACILITY RENTAL [SB23.728560]

# Calculate the total amount in refunds.
$> tsv-summarize --header --sum 2:"Refund Total (in USD)" data-refunds.tsv
Refund Total (in USD)
-12797.99
```

Excluding refunds, **$2,143,752.16** is being spent on **Event**s, with an average of **$13,920.47** per transaction in this category.
Excluding refunds, **$96,973.35** is being spent on **Other**, with an average of **$1,539.26** per transaction in this category.

```bash
$> cat data.tsv | keep-header -- sort -t $'\t' -k4,4nr | tsv-select -H -f 5,4 | tsv-filter -H --ge=2:0 | tsv-summarize --header --group-by 1 --sum 2:"Spending (in USD)" --mean 2:"Average (in USD)" | tsv-pretty
purpose_scrubbed  Spending (in USD)  Average (in USD)
Event                    2143752.16   13920.4685714
Other                      96973.35    1539.25952381
```

If we want to understand the intent behind expenditures, it may be valuable to exclude refunds from our transactions. This may be revisited with future research -- the remaining questions in this report **include** refunds in calculations.

[Return to the top](#top).

* * *
<div style="page-break-after: always; visibility: hidden">
\pagebreak
</div>

## [Question 4](#question-4)

*How many unique `property_scrubbed` entries are there? And how many of these actually contain the word 'Trump'?*

There are **38** unique `property_scrubbed` entries, including the 'Other' category.

```bash
# Pipeline for selecting unique property (scrubbed) entries and storing them in ascending alphabetical order.
$> cat data.tsv | keep-header -- sort -t $'\t' -k6,6 --ignore-case | tsv-uniq -H -f 6 --ignore-case | tsv-select -H -f 6 > data-properties.tsv

# Count of the unique properties.
$> tail -n +2 data-properties.tsv | wc -l
38

# Preview of the contents in the properties file, header included.
$> (head -n 6; echo '...'; tail -n 5) < data-properties.tsv
property_scrubbed
Benjamin Bar & Lounge D.C
BLT Prime D.C
Eric Trump Wine Manufacturing, LLC
Mar-a-Lago Club LLC
Other
...
Trump Plaza LLC
Trump Restaurants LLC
Trump Soho NY
Trump Tower Commercial LLC
Trump Virginia Acquisitions, LLC
```

Of these entries, **33** of the unique `property_scrubbed` entries contain the word "Trump" verbatim:

```bash
# Use grep to search the unique properties for "Trump".
$> grep --color=always Trump data-properties.tsv > data-properties_trump.txt

# Count of the properties that contain "Trump" verbatim.
$> wc -l data-properties_trump.txt
33

# Preview contents of the text file. It should retain the color codes from the grep output.
$> (head -n 5; echo '...'; tail -n 5) < data-properties_trump.txt
Eric Trump Wine Manufacturing, LLC
The Trump Corporation
Trump Cafe NY
Trump CPS LLC
Trump Golf Club
...
Trump Plaza LLC
Trump Restaurants LLC
Trump Soho NY
Trump Tower Commercial LLC
Trump Virginia Acquisitions, LLC
```

[Return to the top](#top).

* * *
<div style="page-break-after: always; visibility: hidden">
\pagebreak
</div>

## [Question 5](#question-5)

*What is the list of how much is being spent at each unique `property_scrubbed` entry?*

### Per Category (Property)

The following is a list of how much is being spent at each of the 38 unique properties in the dataset:

**$9252770.40** is being spent on **Tag Air, Inc.**, with an average of **$486987.92** per transaction in this category.
**$2700562.98** is being spent on **Trump Tower Commercial LLC**, with an average of **$25966.95** per transaction in this category.
**$295125.02** is being spent on **Mar-a-Lago Club LLC**, with an average of **$42160.72** per transaction in this category.
**$535420.07** is being spent on **Trump Hotel Las Vegas**, with an average of **$3367.42** per transaction in this category.
**$262097.32** is being spent on **Trump Restaurants LLC**, with an average of **$5460.36** per transaction in this category.
**$848886.34** is being spent on **Trump Hotel D.C**, with an average of **$4309.07** per transaction in this category.
**$444418.73** is being spent on **Trump Golf Club Miami**, with an average of **$8546.51** per transaction in this category.
**$250621.34** is being spent on **The Trump Corporation**, with an average of **$22783.76** per transaction in this category.
**$141462.99** is being spent on **Trump Hotel D.C.**, with an average of **$2020.90** per transaction in this category.
**$48239.77** is being spent on **Trump Golf Club Westchester**, with an average of **$48239.77** per transaction in this category.
**$61041.80** is being spent on **Trump Golf Club Jupiter**, with an average of **$15260.45** per transaction in this category.
**$77066.94** is being spent on **Trump Golf Club Bedminster**, with an average of **$12844.49** per transaction in this category.
**$163055.66** is being spent on **Trump Golf Club Palm Beach**, with an average of **$4076.39** per transaction in this category.
**$58464.34** is being spent on **Other**, with an average of **$5846.43** per transaction in this category.
**$218546.71** is being spent on **Trump Payroll Corp**, with an average of **$5603.76** per transaction in this category.
**$55664.17** is being spent on **Trump Hotel Chicago**, with an average of **$2530.19** per transaction in this category.
**$15221.10** is being spent on \*\*Trump Golf Club Bedminster \*\*, with an average of **$15221.10** per transaction in this category.
**$38618.97** is being spent on **Trump Hotel Vancouver**, with an average of **$7723.79** per transaction in this category.
**$38552.10** is being spent on **Eric Trump Wine Manufacturing, LLC**, with an average of **$4819.01** per transaction in this category.
**$42219.28** is being spent on **Trump Golf Club D.C**, with an average of **$3015.66** per transaction in this category.
**$27724.32** is being spent on **Trump Golf Club Doonberg**, with an average of **$6931.08** per transaction in this category.
**$79663.26** is being spent on **Trump Hotel NY**, with an average of **$1048.20** per transaction in this category.
**$18279.67** is being spent on **Trump Golf Club Charlotte**, with an average of **$9139.83** per transaction in this category.
**$181250.00** is being spent on **Trump Plaza LLC**, with an average of **$8238.64** per transaction in this category.
**$23000.34** is being spent on **Trump Soho NY**, with an average of **$920.01** per transaction in this category.
**$13307.85** is being spent on **Trump Golf Resort Scotland**, with an average of **$6653.93** per transaction in this category.
**$61463.83** is being spent on **BLT Prime D.C**, with an average of **$788.00** per transaction in this category.
**$72000.00** is being spent on **Trump CPS LLC**, with an average of **$6000.00** per transaction in this category.
**$16625.80** is being spent on **Trump Golf Club**, with an average of **$2770.97** per transaction in this category.
**$8045.58** is being spent on **Trump Golf Club L.A.**, with an average of **$1005.70** per transaction in this category.
**$20778.67** is being spent on **Trump Hotel Panama**, with an average of **$296.84** per transaction in this category.
**$3669.68** is being spent on **Trump Virginia Acquisitions, LLC**, with an average of **$1223.23** per transaction in this category.
**$2946.73** is being spent on **Trump Cafe NY**, with an average of **$196.45** per transaction in this category.
**$5165.41** is being spent on **Trump Ice LLC**, with an average of **$573.93** per transaction in this category.
**$1597.13** is being spent on **Trump Hotel Honolulu**, with an average of **$177.46** per transaction in this category.
**$1001.40** is being spent on **Benjamin Bar & Lounge D.C**, with an average of **$166.90** per transaction in this category.
**$1121.56** is being spent on **Trump Grill NY**, with an average of **$40.06** per transaction in this category.
**$214.42** is being spent on **Trump Golf Club D.C.**, with an average of **$214.42** per transaction in this category.

In order to answer this question, I prepared an intermediary data file to hold the spending organized by property.

```bash
# Pipeline to sort (by spending) and select the property and amount fields.
$> cat data.tsv | keep-header -- sort -t $'\t' -k4,4nr | tsv-select -H -f 6,4 > data-spending_property.tsv

# Preview the contents of the sorted spending by property data file.
$> (head -n 6; echo "..."; tail -n 5) < data-spending_property.tsv | tsv-pretty
property_scrubbed          amount
Tag Air, Inc.          1271944.0
Tag Air, Inc.           783842.0
Tag Air, Inc.           641840.0
Tag Air, Inc.           585470.0
Tag Air, Inc.           537436.0
...
Trump Hotel NY               2.12
Trump Hotel NY               2.08
The Trump Corporation     -428.53
Trump Ice LLC             -828.26
Trump Golf Club Miami   -11541.2
```

I could then use `data-spending_property.tsv` to generate a summary table using the `tsv-summarize` command.

```bash
# Calculate the totals and averages for spending by property, and store it in 'data-spending_property_summary.tsv'
$> tsv-summarize --header --group-by 1 --sum 2:"Total Spending (in USD)" --mean 2:"Average Transaction Expense (in USD)" data-spending_property.tsv > data-spending_property_summary.tsv

# Preview the contents of the summary.
> (head -n 6; echo "..."; tail -n 5) < data-spending_property_summary.tsv | tsv-pretty
property_scrubbed           Total Spending (in USD)  Average Transaction Expense (in USD)
Tag Air, Inc.                            9252770.4                       486987.915789
Trump Tower Commercial LLC               2700562.98                       25966.9517308
Mar-a-Lago Club LLC                       295125.02                       42160.7171429
Trump Hotel Las Vegas                     535420.07                        3367.4218239
Trump Restaurants LLC                     262097.32                        5460.36083333
...
Trump Ice LLC                               5165.41                         573.934444444
Trump Hotel Honolulu                        1597.13                         177.458888889
Benjamin Bar & Lounge D.C                   1001.4                          166.9
Trump Grill NY                              1121.56                         40.0557142857
Trump Golf Club D.C.                         214.42                         214.42
```

Instead of writing the answer out by hand, I simply wrote a quick script to format my output using `awk`. The end result was a markdown file containing the list answering the query.

```sh
# format_summary.awk
#!/usr/bin/awk -f
BEGIN {
    FS = "\t"
    OFS = ","
    ORS = "\r\n"
    
}
{ 
    printf "**%$.2f** is being spent on **%s**, with an average of **$%.2f** per transaction in this category.\n",$2,$1,$3
}
``````bash
# Format report from the data-spending_property_summary table. Note the output as a markdown file.
$> ./format_summary.awk data-spending_property_summary.tsv > data-spending_property_summary.md

# Preview the contents of the summary report.
$> tail -n +2 data-spending_property_summary.md | head -n 5; echo "..."
**$9252770.40** is being spent on **Tag Air, Inc.**, with an average of **$486987.92** per transaction in this category.
**$2700562.98** is being spent on **Trump Tower Commercial LLC**, with an average of **$25966.95** per transaction in this category.
**$295125.02** is being spent on **Mar-a-Lago Club LLC**, with an average of **$42160.72** per transaction in this category.
**$535420.07** is being spent on **Trump Hotel Las Vegas**, with an average of **$3367.42** per transaction in this category.
**$262097.32** is being spent on **Trump Restaurants LLC**, with an average of **$5460.36** per transaction in this category.
...
```

[Return to the top](#top).

* * *
<div style="page-break-after: always; visibility: hidden">
\pagebreak
</div>

## [Question 6](#question-6)

*What is the total being spent on these properties?*

### Summary

In total, **$16,085,911.68** has been spent across all transactions.
The average amount spent per transaction was approximately **$13,484**.

```bash
# Calculate total spending across *all* categories.
$> cat data.tsv | keep-header -- sort -t $'\t' -k4,4nr | tsv-select -H -f 5,4 | tsv-summarize --header --sum 2:"Total Spending (in USD)"
Total Spending (in USD)
16085911.68

# Calculate average expense per transaction across *all* categories.
$> cat data.tsv | keep-header -- sort -t $'\t' -k4,4nr | tsv-select -H -f 5,4 | tsv-summarize --header --mean 2:"Average Transaction Expense (in USD)"
Average Transaction Expense (in USD)
13483.5806203

# We could have calculated the total spending by using the intermediary 
# file created in the previous step: `data-spending_property_summary.tsv`
#
# By using `tsv-summarize` on the summary file, we end up with the same amount.
# Seems like our math checks out.
$> tsv-summarize --header --sum 2:"Grand Total Spending (in USD)" data-spending_property_summary.tsv | tsv-pretty
Grand Total Spending (in USD)
                  16085911.68
```

[Return to the top](#top).

* * *
<div style="page-break-after: always; visibility: hidden">
\pagebreak
</div>

## [Closing Statements](#conclusion)

*Setting up to review the data.*

This short section lays out the preparation work that went into preparing my workstation for the final project and lists references to any external scripts used (including those provided via course material).

### Instance Version

I accomplished the project queries by SSH'ing into my AWS Lightsail instance running Ubuntu 20.04.2 LTS.

```bash
lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 20.04.2 LTS
Release:        20.04
Codename:       focal
```

### Installing Third-Party Tools

In order to organize the scripts I would use for the project, I created two directories: `/bin` and `/lib`.

The `~/lib` directory would house one sub-directory for each collection of related tools. Archives containing scripts would be extracted into their own directories and git repositories could be cloned here directly.

Some tool-sets have scripts that I did not need to use. Instead of exposing the entire `~/lib` on the PATH, I extended my user's PATH to include the `~/bin` directory instead.

Once a tool-set was installed, I would create symbolic links for only the scripts that I needed and placed them in the `~/bin` directory to expose them on the PATH while saving storage space. This also allowed me to create shorter and consistent aliases for lengthy commands.

### Dependencies

I used the following utilities with my project.

#### [eBay's TSV Utilities](https://github.com/eBay/tsv-utils)

A set of command line tools designed for TSV data files, released under the highly permissive [Boost Software License 1.0](https://www.boost.org/LICENSE_1_0.txt).

#### [Prof. Sonstein's tsv2json Utility](https://github.com/jsonstein/tsv2json)

A command line utility for converting TSV files into JSON, written and compiled with the D programming language. Shared under the [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

#### [clarkgrubb's Data Tools](https://github.com/clarkgrubb/data-tools)

Found via eBay's TSV Utiltiies' [other toolkits](https://github.com/eBay/tsv-utils/blob/master/docs/OtherToolkits.md) page, this is a set of data tools that offer small quality-of-life helpers and format converters, in the form of Python and Bash shell scripts. Licensed under the [MIT License](https://opensource.org/licenses/MIT). The `reservoir-sample` command is one that's useful for discovery.

[Return to the top](#top).