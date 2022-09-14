#!/bin/bash
bundle install
rake ts:in
searchd --config shared/config/sphinx.conf