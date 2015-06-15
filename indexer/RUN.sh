#!/bin/bash
java -classpath libs/lucene-core-4.10.1-SNAPSHOT.jar:libs/lucene-analyzers-common-4.10.1.jar:libs/lucene-queryparser-4.10.1.jar:bin indexer.Indexer $*