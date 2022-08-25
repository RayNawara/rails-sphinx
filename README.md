# Docker MBA Legacy Sphinx

## http://sphinxsearch.com/docs/archives/manual-0.9.9.html

docker build -t mba-legacy-sphinx .

docker run -p 9311:9306 -v /path/to/local/sphinx/conf:/etc/sphinxsearch/ -v /local/data/directory:/var/lib/sphinx -d sphinx ./indexandsearch.sh

