#!/usr/bin/env bash


if [ -f /etc/neo4j/neo4j.conf ]
then
    echo "Neo4j already installed."
    exit 0
fi

wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee -a /etc/apt/sources.list.d/neo4j.list
apt-get update

# Install Neo4j Community Edition
apt-get install -y neo4j=1:3.3.5

# Configure Neo4j Remote Access
sed -i "s/#dbms.connectors.default_listen_address=0.0.0.0/dbms.connectors.default_listen_address=0.0.0.0/" /etc/neo4j/neo4j.conf

# Enable Neo4j as system service
systemctl enable neo4j
systemctl start neo4j

# Add new Neo4j user
cypher-shell -u neo4j -p neo4j "CALL dbms.changePassword('secret');"
cypher-shell -u neo4j -p secret "CALL dbms.security.createUser('homestead', 'secret', false);"

# Delete default Neo4j user
cypher-shell -u homestead -p secret "CALL dbms.security.deleteUser('neo4j');"