from qdrant_client import QdrantClient
from qdrant_client.models import *

client = QdrantClient(host="localhost", port=6333)

client.create_payload_index("articles", "category", field_schema="keyword")
client.create_payload_index("articles", "rating", field_schema="float")
client.create_payload_index("articles", "published_at", field_schema="keyword")
client.create_payload_index("articles", "views", field_schema="integer")

print("Indexes created")