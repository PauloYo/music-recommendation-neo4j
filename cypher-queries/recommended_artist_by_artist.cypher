MATCH (target:Artist {name: "The Weeknd"})
MATCH (target)<-[:FOLLOWS]-(u:User)-[:FOLLOWS]->(recommended:Artist)
WHERE recommended.name <> "The Weeknd"
OPTIONAL MATCH (u)-[listen:LISTENED]->(m:Music)-[:PERFORMED_BY]->(recommended)
RETURN
  recommended.name AS artist,
  count(DISTINCT u) AS usersWhoAlsoFollowed,
  coalesce(sum(listen.times), 0) AS accumulatedListens
ORDER BY accumulatedListens DESC, usersWhoAlsoFollowed DESC, artist;
