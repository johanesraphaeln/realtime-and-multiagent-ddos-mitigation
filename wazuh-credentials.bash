wazuh-install-files/wazuh-passwords.txt
# Admin user for the web user interface and Wazuh indexer. Use this user to log in to Wazuh dashboard
  indexer_username: 'admin'
  indexer_password: 'onnWuUjO4bsFWT+40iol0ALIm3+ntHC*'

# Wazuh dashboard user for establishing the connection with Wazuh indexer
  indexer_username: 'kibanaserver'
  indexer_password: '3+sOiJ2sV.TogTMvFtP+GQa48n.1EII8'

# Regular Dashboard user, only has read permissions to all indices and all permissions on the .kibana index
  indexer_username: 'kibanaro'
  indexer_password: '2?hdWH9SbSTg*awzq8EWLlRQ2V?uiKgU'

# Filebeat user for CRUD operations on Wazuh indices
  indexer_username: 'logstash'
  indexer_password: 'CG7jN1ZeeJ.Km2?IEtiyjx.6sHB43ghU'

# User with READ access to all indices
  indexer_username: 'readall'
  indexer_password: 's*KWedYKopdL8eY3SrLR3MqZx2zOzp.O'

# User with permissions to perform snapshot and restore operations
  indexer_username: 'snapshotrestore'
  indexer_password: 'eZVQ.s*dAmnGbHv9eB?5iOvTtgsw2V.Z'

# Password for wazuh API user
  api_username: 'wazuh'
  api_password: 'kYNoKxLSn6CbaJEd2vB9*.g?9ttjB?bJ'

# Password for wazuh-wui API user
  api_username: 'wazuh-wui'
  api_password: 'oEOd+qa2uTt6EYJaVnQ+tLftXg5dtDib'