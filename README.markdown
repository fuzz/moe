[![Build Status](https://travis-ci.org/fuzz/moe.png?branch=master)](https://travis-ci.org/fuzz/moe)
[![Code Climate](https://codeclimate.com/github/fuzz/moe.png)](https://codeclimate.com/github/fuzz/moe)
[![Coverage Status](https://coveralls.io/repos/fuzz/moe/badge.png)](https://coveralls.io/r/fuzz/moe)

# Moe

A toolkit for working with DynamoDB at scale

## Features

### Multitable support

Moe provides a table manager to create and rotate tables. Tables may be
mirrored (each write goes to two or more tables) and/or split (reads happen
across multiple tables).

Currently mirroring uses a table with the same capacity as the primary table.
In the future we may add Kinesis support for the mirror table so the mirrored
writes can go to Kinesis first and then trickle into the mirror table so we can
minimize the capacity required. This mill also allow us do Big Data type
realtime procesing as it goes through Kinesis should that be desired. 

There are different approaches to splitting based on the use case. The most
straightforward mechanism is to shut everything down, push out a table change,
start everything back up. This ensures that a set of data will not be written
across multiple tables thus providing the most safety when expiring old tables.
At the other end of the spectrum we can simply write the metadata item as the
first in the sequence so knowledge of the sequence will disappear when the
table its metadata is written on does. At this time the splitting strategy is
determined by the persistence strategy though it would be good to be able to
mix and match.

### Persistence strategies

DynamoDB presents a unique and interesting set of contraints. By designing
persistence strategies around these contraints we can take advantage of useful
patterns that fall out of them. Thus unlike a generalized ORM moe provides a
number of different persistence strategies depending on your use cases and
patterns. Cannot find a pattern that is a good match for your workload? Add
one!

The first persistence strategy available is the one described at
http://fuzz.github.io -- it provides a model where an "owner" has many things
that each have many things using a single DynamoDB table with no indexes. By
comparison a more ruby-typical-but-dynamo-naive implementation might use two
tables plus a GSI at ~3x the cost. Not to mention the additional complexity as
capacity and other operational concerns have to be managed on each table and
the GSI.

### Partitioning

DynamoDB capacity is evenly divided among a number of partitions that
increase/decrease along with capacity. We do not know the number of partitions;
we only know (if we pay attention) when our primary hash key strategy is
insufficently random to spread evenly across all partitions. Moe will provide a
number of partitioning strategies and instrumentation so you can compare your
actual overall throughput to what AWS reports in order to determine the
effectiveness of and tune your key randomization strategy.

## Installation

### JRuby

Moe requires Ruby 2+ so you will need

```
export JRUBY_OPTS=--2.0
```

to run it.

If you want to run the tests you will need to start fake_dynamo manually and

```
bundle exec rake rspec  # use rspec instead of spec to bypass auto fake_dynamo
```
