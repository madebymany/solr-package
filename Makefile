SOLR_VERSION:=4.8.1
SOLR_EXTRACT_DIR:=solr-$(SOLR_VERSION)
SOLR_TARBALL:=$(SOLR_EXTRACT_DIR).tgz

SOLR_HOME:=/var/lib/solr
SOLR_SOURCE_URL:=http://mirror.vorboss.net/apache/lucene/solr/$(SOLR_VERSION)/$(SOLR_TARBALL)
SOLR_CHECKSUM:=https://archive.apache.org/dist/lucene/solr/$(SOLR_VERSION)/$(SOLR_TARBALL).asc
SOLR_KEYS:=https://archive.apache.org/dist/lucene/solr/$(SOLR_VERSION)/KEYS

JTS_VERSION:=1.13
JTS_ZIP:=jts-$(JTS_VERSION).zip
JTS_EXTRACT_DIR:=jts-$(JTS_VERSION)
JTS_SOURCE_URL:=http://sourceforge.net/projects/jts-topo-suite/files/jts/$(JTS_VERSION)/$(JTS_ZIP)/download
JTS_JARS:="lib/acme.jar" "lib/jdom.jar" "lib/jts-1.13.jar" "lib/jtsio-1.13.jar" "lib/xerces.jar"

JTS_CHECKSUM:=$(JTS_ZIP).sha1

DEPENDENCIES:=curl openjdk-7-jre
CURL := curl -LSs

all: apt | $(SOLR_EXTRACT_DIR) update_solr_war

apt:
	apt-get update -qq
	apt-get install -qy $(DEPENDENCIES)

$(SOLR_TARBALL):
	$(CURL) -o "$(SOLR_TARBALL)" "$(SOLR_SOURCE_URL)"
	$(CURL) -O $(SOLR_CHECKSUM)
	$(CURL) -O $(SOLR_KEYS)
	gpg --import KEYS
	gpg --verify "$(SOLR_TARBALL).asc" "$(SOLR_TARBALL)"

$(SOLR_EXTRACT_DIR): $(SOLR_TARBALL)
	tar -xzf "$(SOLR_TARBALL)"

$(JTS_ZIP):
	$(CURL) -o "$(JTS_ZIP)" "$(JTS_SOURCE_URL)"
	sha1sum --quiet --check $(JTS_CHECKSUM)

$(JTS_EXTRACT_DIR): $(JTS_ZIP)
	unzip -q -d "$(SOLR_EXTRACT_DIR)/example/webapps/WEB-INF" "$(JTS_ZIP)" $(JTS_JARS)

update_solr_war: $(JTS_EXTRACT_DIR)
	cd "$(SOLR_EXTRACT_DIR)/example/webapps" && zip -r "solr.war" WEB-INF
	cd "$(SOLR_EXTRACT_DIR)/example/webapps" && rm -rf WEB-INF

install:
	mkdir -p $(SOLR_HOME)
	cp -R $(SOLR_EXTRACT_DIR)/* $(SOLR_HOME)
	mv $(SOLR_HOME)/example $(SOLR_HOME)/node
	cp etc/default/solr /etc/default/solr
	mkdir -p /etc/sv/solr
	cp -R etc/sv/solr/* /etc/sv/solr/

install-default-collection:
	mkdir -p $(SOLR_HOME)
	cp -R $(SOLR_EXTRACT_DIR)/example/solr/collection1 $(SOLR_HOME)/default-collection
	rm $(SOLR_HOME)/default-collection/core.properties

clean:
	rm -rf "$(SOLR_EXTRACT_DIR)" "$(SOLR_TARBALL)" "$(SOLR_CHECKSUM)" "$(SOLR_KEYS)" "$(JTS_ZIP)" "$(JTS_EXTRACT_DIR)"

.PHONY: update_solr_war
