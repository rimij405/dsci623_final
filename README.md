# DSCI 623: Final Project

In June 2018, [ProPublica](https://propublica.org/) published an interactive graphic titled [Paying the President](https://projects.propublica.org/paying-the-president/), detailing the pattern of Trump campaign and administration spending millions at his properties. They subsequently released their dataset, title Spending at Trump Properties, to the public and encouraged others to investigate the details themselves.

## Overview

In an attempt to practice exploratory data analysis, students were given this dataset and asked to walk through a series of questions that might interest be of interest to an auditor.

This is a *non-exhaustive* list of the types of questions we were asked:

- How many records are there in the dataset?
- How many actual unique `purposes_scrubbed` are there for this spending?
- How many of these `purposes_scrubbed` actually contain the word "Trump"?
- What is the total being spent on these properties?

I completed the initial analysis using command line tools.

Additional work was completed using the Jupyter notebook.

## Citations

2018, ProPublica. [Spending at Trump Properties](https://www.propublica.org/datastore/dataset/spending-at-trump-properties) [dataset]. ProPublica.org. Accessed on Apr. 24, 2021.

## License

The code used in the process of exploring this dataset has been made publicly available underneath the [Mozilla Public License Version 2.0](https://www.mozilla.org/en-US/MPL/2.0/). You can find the license file here: [licensed](LICENSE).

## Dependencies

The initial analysis took place on an [Amazon Lightsail](https://aws.amazon.com/lightsail/) server running [Ubuntu 20.04](https://releases.ubuntu.com/20.04/), and utilized the following utilities:

[eBay's TSV Utilities](https://github.com/eBay/tsv-utils) - A set of command line tools designed for TSV data files, released under the highly permissive [Boost Software License 1.0](https://www.boost.org/LICENSE_1_0.txt).

[Prof. Sonstein's tsv2json Utility](https://github.com/jsonstein/tsv2json) - A command line utility for converting TSV files into JSON, written and compiled with the D programming language. Shared under the [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

[clarkgrubb's Data Tools](https://github.com/clarkgrubb/data-tools) - Found via eBay's TSV Utiltiies' [other toolkits](https://github.com/eBay/tsv-utils/blob/master/docs/OtherToolkits.md) page, this is a set of data tools that offer small quality-of-life helpers and format converters, in the form of Python and Bash shell scripts. Licensed under the [MIT License](https://opensource.org/licenses/MIT). The `reservoir-sample` command is one that's useful for discovery.

Some of the Python packages that are useful for exploratory data analysis within the context of the Jupyter notebook are:

[`pandas`](https://github.com/pandas-dev/pandas/)
[`numpy`](https://github.com/numpy/numpy)
[`matplotlib`](https://github.com/matplotlib/matplotlib)