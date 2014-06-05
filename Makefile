SOLR_VERSION := 4.8.1
SOLR_EXTRACT_DIR := solr-$(SOLR_VERSION)
SOLR_TARBALL := $(SOLR_EXTRACT_DIR).tgz

SOLR_HOME := /var/lib/solr
SOLR_SOURCE_URL := http://mirror.vorboss.net/apache/lucene/solr/$(SOLR_VERSION)/$(SOLR_TARBALL)
SOLR_CHECKSUM := $(SOLR_TARBALL).asc
SOLR_CHECKSUM_URL := https://archive.apache.org/dist/lucene/solr/$(SOLR_VERSION)/$(SOLR_CHECKSUM)
SOLR_KEYS := https://archive.apache.org/dist/lucene/solr/$(SOLR_VERSION)/KEYS
SOLR_TEMP_GPG_KEYRING := ./solr-keyring # ./ needed otherwise gpg puts it in ~/.gpg

JTS_VERSION := 1.13
JTS_ZIP := jts-$(JTS_VERSION).zip
JTS_EXTRACT_DIR := jts-$(JTS_VERSION)
JTS_SOURCE_URL := http://sourceforge.net/projects/jts-topo-suite/files/jts/$(JTS_VERSION)/$(JTS_ZIP)/download
JTS_JARS := "lib/acme.jar" "lib/jdom.jar" "lib/jts-1.13.jar" "lib/jtsio-1.13.jar" "lib/xerces.jar"

JTS_CHECKSUM := $(JTS_ZIP).sha1

DEPENDENCIES := curl zip
CURL := curl -LSs
GPG := gpg --keyring "$(SOLR_TEMP_GPG_KEYRING)" --no-default-keyring

all: apt update-solr-war

apt:
	apt-get update -qq
	apt-get install -qy $(DEPENDENCIES)

$(SOLR_TARBALL):
	$(CURL) -o "$(SOLR_TARBALL)" "$(SOLR_SOURCE_URL)"
	$(CURL) -o "$(SOLR_CHECKSUM)" "$(SOLR_CHECKSUM_URL)"
	$(CURL) "$(SOLR_KEYS)" | $(GPG) --import -
	$(GPG) --verify "$(SOLR_CHECKSUM)" "$(SOLR_TARBALL)"
	rm "$(SOLR_TEMP_GPG_KEYRING)" "$(SOLR_TEMP_GPG_KEYRING)~"

$(SOLR_EXTRACT_DIR): $(SOLR_TARBALL)
	tar -xzf "$(SOLR_TARBALL)"

$(JTS_ZIP):
	$(CURL) -o "$(JTS_ZIP)" "$(JTS_SOURCE_URL)"
	sha1sum --quiet --check $(JTS_CHECKSUM)

$(JTS_EXTRACT_DIR): $(JTS_ZIP)
	unzip -q -d "$(SOLR_EXTRACT_DIR)/example/webapps/WEB-INF" "$(JTS_ZIP)" $(JTS_JARS)

update-solr-war: | $(SOLR_EXTRACT_DIR) $(JTS_EXTRACT_DIR)
	cd "$(SOLR_EXTRACT_DIR)/example/webapps" && \
		zip -q -r "solr.war" WEB-INF && \
		rm -rf WEB-INF

install:
	cp -R "$(SOLR_EXTRACT_DIR)" "$(SOLR_HOME)"
	mv "$(SOLR_HOME)/example" "$(SOLR_HOME)/node"
	install --mode=0644 --owner=root --group=root \
		etc/default/solr /etc/default/solr
	mkdir -p /etc/sv
	cp -R etc/sv/solr/ /etc/sv/
	chown -R root:root /etc/sv/solr
	mkdir -p /var/log/service
	cp -R var/log/service/solr /var/log/service/
	install --mode=0755 --owner=root --group=root -t /usr/sbin \
		install-solr-collection

install-default-collection:
	mkdir -p "$(SOLR_HOME)"
	cp -R "$(SOLR_EXTRACT_DIR)/example/solr/collection1" "$(SOLR_HOME)/default-collection"
	rm "$(SOLR_HOME)/default-collection/core.properties"

clean:
	rm -rf "$(SOLR_EXTRACT_DIR)" "$(SOLR_TARBALL)" "$(SOLR_CHECKSUM)" "$(JTS_ZIP)" "$(JTS_EXTRACT_DIR)"

.PHONY: update-solr-war install install-default-collection clean
